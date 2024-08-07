import json
import boto3
import os
import datetime
import re
import sentry_sdk
import logging
from calendar import timegm
from sentry_sdk.integrations.aws_lambda import AwsLambdaIntegration



# Get SNS Topic ARN from Environment variables
metricName = os.environ['metricName']
metricNamespace = os.environ['metricNamespace']

# Get SNS resource using boto3
snsClient = boto3.client('sns')

# Get Secrets Manager resource using boto3
awsSecretsClient = boto3.client('secretsmanager')

cloudWatchLogsClient = boto3.client('logs')

sentrySecretName = os.environ['sentrySecretName']

sentryEnvironment = os.environ['sentryEnvironment']

awsSecretResponse = awsSecretsClient.get_secret_value(
    SecretId=sentrySecretName,
)

awsSentrySecret = json.loads(awsSecretResponse['SecretString'])

sentryDsn = awsSentrySecret['SENTRY_DSN']

sentry_sdk.init(
    dsn=sentryDsn,
    integrations=[
        AwsLambdaIntegration(),
    ],
    environment=sentryEnvironment
)

def lambda_handler(event, context):

    # Extract Alarm name and subject from Alarm event

    alarmMessage = json.loads(event['Records'][0]['Sns']['Message'])

    # Get metric filters for slowquery
    describeMetricFilterResponse = cloudWatchLogsClient.describe_metric_filters(
        limit = 1,
        metricName = metricName,
        metricNamespace = metricNamespace
    )

    metricFilter = describeMetricFilterResponse['metricFilters'][0]

    alarmTimestamp = datetime.datetime.strptime(alarmMessage['StateChangeTime'], '%Y-%m-%dT%H:%M:%S.%f+0000')

    startTimeStamp = alarmTimestamp - datetime.timedelta(minutes=3)

    # Get log stream message using log filter
    filterMetricLogsResponse = cloudWatchLogsClient.filter_log_events(
        logGroupName=metricFilter['logGroupName'],
        filterPattern=metricFilter['filterPattern'],
        startTime=(timegm(startTimeStamp.utctimetuple()) * 1000),
        endTime=(timegm(alarmTimestamp.utctimetuple()) * 1000),
        limit=1,
    )

    # Get sql query log from log stream message
    rawRdsSqlQueryLog = filterMetricLogsResponse['events'][0]['message']
    
    rdsSqlQueryLog = rawRdsSqlQueryLog.replace('\t', '').replace('\n', '')
    
    print (f"this is the sql query => {rdsSqlQueryLog}")

    matchObject = re.match(r'.* duration: ([0-9.]+) ms .* execute [\w<>]+: (.*)', rdsSqlQueryLog)

    if not matchObject:
        print("No SQL query was found.")
        return
    
    sqlQueryDuration = matchObject.group(1)

    sqlQuery = matchObject.group(2)

    logging.error(f"Slow Query Alert -> {sqlQuery}", extra=dict(query_duration=f"{sqlQueryDuration} ms"))
    
    print("Message published to Sentry sucessfully")
