# Based on the template provided by Amazon:
# https://github.com/aws-samples/aws-secrets-manager-rotation-lambdas

import boto3
import json
import logging
import os
import psycopg2

logger = logging.getLogger()
logger.setLevel(logging.INFO)


ALTERNATE_USERNAME = os.environ['ALTERNATE_USERNAME']
PRIMARY_USERNAME = os.environ['PRIMARY_USERNAME']
REPLICA_HOST = os.environ['REPLICA_HOST']


def lambda_handler(event, context):
    """Secrets Manager RDS PostgreSQL Handler

    This handler uses the primary-alt rotation scheme to rotate an RDS
    PostgreSQL user credential. Each rotation alternates between the primary
    username and the alternate username, updating the password each time. If the
    alternate user don't already exist, they will be created when the password
    is rotated for the first time.

    The Secret SecretString is expected to be a JSON string with the following format:
    {
        'engine': <required: must be set to 'postgres'>,
        'host': <required: instance host name>,
        'username': <required: username>,
        'password': <required: password>,
        'dbname': <optional: database name, default to 'postgres'>,
        'port': <optional: if not specified, default port 5432 will be used>,
    }

    Args:
        event (dict): Lambda dictionary of event parameters. These keys must include the following:
            - SecretId: The secret ARN or identifier
            - ClientRequestToken: The ClientRequestToken of the secret version
            - Step: The rotation step (one of createSecret, setSecret, testSecret, or finishSecret)

        context (LambdaContext): The Lambda runtime information

    Raises:
        ResourceNotFoundException: If the secret with the specified arn and stage does not exist

        ValueError: If the secret is not properly configured for rotation

        KeyError: If the secret json does not contain the expected keys

    """
    arn = event['SecretId']
    token = event['ClientRequestToken']
    step = event['Step']

    # Setup the client
    service_client = boto3.client('secretsmanager', endpoint_url=os.environ['SECRETS_MANAGER_ENDPOINT'])

    # Make sure the version is staged correctly
    metadata = service_client.describe_secret(SecretId=arn)
    if "RotationEnabled" in metadata and not metadata['RotationEnabled']:
        logger.error("Secret %s is not enabled for rotation" % arn)
        raise ValueError("Secret %s is not enabled for rotation" % arn)
    versions = metadata['VersionIdsToStages']
    if token not in versions:
        logger.error("Secret version %s has no stage for rotation of secret %s." % (token, arn))
        raise ValueError("Secret version %s has no stage for rotation of secret %s." % (token, arn))
    if "AWSCURRENT" in versions[token]:
        logger.info("Secret version %s already set as AWSCURRENT for secret %s." % (token, arn))
        return
    elif "AWSPENDING" not in versions[token]:
        logger.error("Secret version %s not set as AWSPENDING for rotation of secret %s." % (token, arn))
        raise ValueError("Secret version %s not set as AWSPENDING for rotation of secret %s." % (token, arn))

    # Call the appropriate step
    if step == "createSecret":
        create_secret(service_client, arn, token)

    elif step == "setSecret":
        set_secret(service_client, arn, token)

    elif step == "testSecret":
        test_secret(service_client, arn, token)

    elif step == "finishSecret":
        finish_secret(service_client, arn, token)

    else:
        logger.error("lambda_handler: Invalid step parameter %s for secret %s" % (step, arn))
        raise ValueError("Invalid step parameter %s for secret %s" % (step, arn))


def create_secret(service_client, arn, token):
    """Generate a new secret

    This method first checks for the existence of a secret for the passed in token. If one does not exist, it will generate a
    new secret and put it with the passed in token.

    Args:
        service_client (client): The secrets manager service client

        arn (string): The secret ARN or other identifier

        token (string): The ClientRequestToken associated with the secret version

    Raises:
        ValueError: If the current secret is not valid JSON

        KeyError: If the secret json does not contain the expected keys

    """
    # Make sure the current secret exists
    current_dict = get_secret_dict(service_client, arn, "AWSCURRENT")

    # Now try to get the secret version, if that fails, put a new secret
    try:
        get_secret_dict(service_client, arn, "AWSPENDING", token)
        logger.info("createSecret: Successfully retrieved secret for %s." % arn)
    except service_client.exceptions.ResourceNotFoundException:
        # Get the next username swapping between primary and alternate
        current_dict['username'] = get_alt_username(current_dict['username'])

        # Generate a random password
        passwd = service_client.get_random_password(ExcludePunctuation=True)
        current_dict['password'] = passwd['RandomPassword']

        # Add DATABASE_URL to secret
        current_dict['DATABASE_URL'] = dict_to_url(current_dict, False)

        if REPLICA_HOST:
            # Add DATABASE_REPLICA_URL to secret
            current_dict['DATABASE_REPLICA_URL'] = dict_to_url(current_dict, True)

        # Put the secret
        service_client.put_secret_value(SecretId=arn, ClientRequestToken=token, SecretString=json.dumps(current_dict), VersionStages=['AWSPENDING'])
        logger.info("createSecret: Successfully put secret for ARN %s and version %s." % (arn, token))


def set_secret(service_client, arn, token):
    """Set the pending secret in the database

    This method tries to login to the database with the AWSPENDING secret and
    returns on success. If that fails, it tries to login with the credentials in
    the current secret. If this succeeds, it adds all grants for AWSCURRENT user
    to the AWSPENDING user, creating the user and/or setting the password in the
    process. Else, it throws a ValueError.

    Args:
        service_client (client): The secrets manager service client

        arn (string): The secret ARN or other identifier

        token (string): The ClientRequestToken associated with the secret version

    Raises:
        ResourceNotFoundException: If the secret with the specified arn and stage does not exist

        ValueError: If the secret is not valid JSON or valid credentials are found to login to the database

        KeyError: If the secret json does not contain the expected keys

    """
    current_dict = get_secret_dict(service_client, arn, "AWSCURRENT")
    pending_dict = get_secret_dict(service_client, arn, "AWSPENDING", token)

    # First try to login with the pending secret, if it succeeds, return
    conn = get_connection(pending_dict)
    if conn:
        conn.close()
        logger.info("setSecret: AWSPENDING secret is already set as password in PostgreSQL DB for secret arn %s." % arn)
        return

    # Make sure the user from current and pending match
    if get_alt_username(current_dict['username']) != pending_dict['username']:
        logger.error("setSecret: Attempting to modify user %s other than current user alternate %s" % (pending_dict['username'], get_alt_username(current_dict['username'])))
        raise ValueError("Attempting to modify user %s other than current user alternate %s" % (pending_dict['username'], get_alt_username(current_dict['username'])))

    # Make sure the host from current and pending match
    if current_dict['host'] != pending_dict['host']:
        logger.error("setSecret: Attempting to modify user for host %s other than current host %s" % (pending_dict['host'], current_dict['host']))
        raise ValueError("Attempting to modify user for host %s other than current host %s" % (pending_dict['host'], current_dict['host']))

    # Log in with the current credentials
    conn = get_connection(current_dict)
    if not conn:
        logger.error("setSecret: Unable to log into database using current credentials for secret %s" % arn)
        raise ValueError("Unable to log into database using current credentials for secret %s" % arn)

    # Set the password to the pending password
    try:
        with conn.cursor() as cur:
            # Get escaped usernames via quote_ident
            cur.execute("SELECT quote_ident(%s)", (pending_dict['username'],))
            pending_username = cur.fetchone()[0]
            cur.execute("SELECT quote_ident(%s)", (current_dict['username'],))
            current_username = cur.fetchone()[0]

            # Check if the user exists, if not create it and grant it all
            # permissions from the current role. If the user exists, just update
            # the password.
            cur.execute("SELECT 1 FROM pg_roles where rolname = %s", (pending_dict['username'],))
            if len(cur.fetchall()) == 0:
                create_role = "CREATE ROLE %s" % pending_username
                cur.execute(create_role + " WITH LOGIN PASSWORD %s", (pending_dict['password'],))
                cur.execute("GRANT %s TO %s" % (current_username, pending_username))
            else:
                alter_role = "ALTER USER %s" % pending_username
                cur.execute(alter_role + " WITH PASSWORD %s", (pending_dict['password'],))
            conn.commit()
            logger.info("setSecret: Successfully set password for %s in PostgreSQL DB for secret arn %s." % (pending_dict['username'], arn))
    finally:
        conn.close()


def test_secret(service_client, arn, token):
    """Test the pending secret against the database

    This method tries to log into the database with the secrets staged with AWSPENDING and runs
    a permissions check to ensure the user has the correct permissions.

    Args:
        service_client (client): The secrets manager service client

        arn (string): The secret ARN or other identifier

        token (string): The ClientRequestToken associated with the secret version

    Raises:
        ResourceNotFoundException: If the secret with the specified arn and stage does not exist

        ValueError: If the secret is not valid JSON or valid credentials are found to login to the database

        KeyError: If the secret json does not contain the expected keys

    """
    # Try to login with the pending secret, if it succeeds, return
    conn = get_connection(get_secret_dict(service_client, arn, "AWSPENDING", token))
    if conn:
        # This is where the lambda will validate the user's permissions. Uncomment/modify the below lines to
        # tailor these validations to your needs
        try:
            with conn.cursor() as cur:
                cur.execute("SELECT NOW()")
                conn.commit()
        finally:
            conn.close()

        logger.info("testSecret: Successfully signed into PostgreSQL DB with AWSPENDING secret in %s." % arn)
        return
    else:
        logger.error("testSecret: Unable to log into database with pending secret of secret ARN %s" % arn)
        raise ValueError("Unable to log into database with pending secret of secret ARN %s" % arn)


def finish_secret(service_client, arn, token):
    """Finish the rotation by marking the pending secret as current

    This method finishes the secret rotation by staging the secret staged AWSPENDING with the AWSCURRENT stage.

    Args:
        service_client (client): The secrets manager service client

        arn (string): The secret ARN or other identifier

        token (string): The ClientRequestToken associated with the secret version

    """
    # First describe the secret to get the current version
    metadata = service_client.describe_secret(SecretId=arn)
    current_version = None
    for version in metadata["VersionIdsToStages"]:
        if "AWSCURRENT" in metadata["VersionIdsToStages"][version]:
            if version == token:
                # The correct version is already marked as current, return
                logger.info("finishSecret: Version %s already marked as AWSCURRENT for %s" % (version, arn))
                return
            current_version = version
            break

    # Finalize by staging the secret version current
    service_client.update_secret_version_stage(SecretId=arn, VersionStage="AWSCURRENT", MoveToVersionId=token, RemoveFromVersionId=current_version)
    logger.info("finishSecret: Successfully set AWSCURRENT stage to version %s for secret %s." % (token, arn))

def dict_to_url(secret, replica):
    """Reformats connection details as a URL string

    Generate a Heroku-style DATABASE_URL with connection details

    Args:
        secret: Current secret value

    Returns:
        url: DATABASE_URL-style string
    """
    if replica:
        host = secret['host']
    else:
        host = REPLICA_HOST

    return "postgres://%s:%s@%s:%s/%s" % (secret['username'],
            secret['password'], host, secret['port'],
            secret['dbname'])

def get_connection(secret_dict):
    """Gets a connection to PostgreSQL DB from a secret dictionary

    This helper function uses connectivity information from the secret dictionary to initiate
    connection attempt(s) to the database.

    Args:
        secret_dict (dict): The Secret Dictionary

    Returns:
        Connection: The pgdb.Connection object if successful. None otherwise

    Raises:
        KeyError: If the secret json does not contain the expected keys

    """

    # Try to obtain a connection to the db
    try:
        conn = psycopg2.connect(host=secret_dict['host'], user=secret_dict['username'], password=secret_dict['password'], database=secret_dict['dbname'], port=secret_dict['port'], connect_timeout=5, sslmode='require')
        return conn
    except psycopg2.DatabaseError as err:
        logger.info("Postgres error: %s" % err)
        return None


def get_secret_dict(service_client, arn, stage, token=None):
    """Gets the secret dictionary corresponding for the secret arn, stage, and token

    This helper function gets credentials for the arn and stage passed in and returns the dictionary by parsing the JSON string

    Args:
        service_client (client): The secrets manager service client

        arn (string): The secret ARN or other identifier

        token (string): The ClientRequestToken associated with the secret version, or None if no validation is desired

        stage (string): The stage identifying the secret version

    Returns:
        SecretDictionary: Secret dictionary

    Raises:
        ResourceNotFoundException: If the secret with the specified arn and stage does not exist

        ValueError: If the secret is not valid JSON

        KeyError: If the secret json does not contain the expected keys

    """
    required_fields = ['host', 'username', 'password']

    # Only do VersionId validation against the stage if a token is passed in
    if token:
        secret = service_client.get_secret_value(SecretId=arn, VersionId=token, VersionStage=stage)
    else:
        secret = service_client.get_secret_value(SecretId=arn, VersionStage=stage)
    plaintext = secret['SecretString']
    secret_dict = json.loads(plaintext)

    # Run validations against the secret
    if 'engine' not in secret_dict or secret_dict['engine'] != 'postgres':
        raise KeyError("Database engine must be set to 'postgres' in order to use this rotation lambda")
    for field in required_fields:
        if field not in secret_dict:
            raise KeyError("%s key is missing from secret JSON" % field)

    secret_dict['port'] = int(secret_dict['port']) if 'port' in secret_dict else 5432
    secret_dict['dbname'] = secret_dict['dbname'] if 'dbname' in secret_dict else "postgres"

    # Parse and return the secret JSON string
    return secret_dict


def get_alt_username(current_username):
    """Gets the alternate username for the current_username passed in

    This helper function gets the username for the alternate user based on the
    passed in current username.

    Args:
        current_username (client): The current username

    Returns:
        AlternateUsername: Alternate username

    Raises:
        ValueError: If the new username length would exceed the maximum allowed

    """
    if current_username == PRIMARY_USERNAME:
        return ALTERNATE_USERNAME
    elif current_username == ALTERNATE_USERNAME:
        return PRIMARY_USERNAME
    else:
        raise ValueError("Current username is not the primary or alternate username")
