# Debezium MSK Connector

Provision an Amazon MSK Connect Debezium PostgreSQL connector, including its execution role, worker configuration, and CloudWatch log group.

## Usage

The module expects three pieces to already exist in the target AWS account:

1. An Amazon MSK cluster with IAM authentication enabled for clients.
2. An MSK Connect custom plugin containing the Debezium PostgreSQL connector and the AWS config providers.
3. A Secrets Manager secret containing PostgreSQL connection details and an SSM parameter containing the MSK IAM bootstrap brokers string.

Available Debezium PostgreSQL connector versions can be found in the upstream Debezium release pages and connector installation docs:

- Debezium releases overview: https://debezium.io/releases/
- Debezium PostgreSQL connector docs: https://debezium.io/documentation/reference/stable/connectors/postgresql.html
- Debezium installation docs for connector archives: https://debezium.io/documentation/reference/stable/install.html

## Build And Upload The Plugin

This is a required initial preparation step. The module cannot be applied until the MSK Connect custom plugin ZIP has been built, uploaded to S3, and registered as an MSK Connect custom plugin in AWS.

An interactive helper script is included at [`scripts/build_upload_plugin.py`](./scripts/build_upload_plugin.py). It automates the full preparation flow by validating the requested Debezium version, downloading the required Debezium and AWS config provider artifacts, packaging them into a single MSK Connect plugin ZIP, and uploading that ZIP to S3.

Use this script as part of the initial setup for any environment that needs this module.

Prerequisites for the script:

- Python 3
- AWS CLI
- AWS credentials, or an AWS profile, or an assumable IAM role with access to the target S3 bucket

The script uses only the Python standard library, so there are no extra Python package dependencies to install.

Default values used by the script:

- Debezium PostgreSQL connector version: `3.5.0`
- AWS MSK config provider version: `0.4.0`

The script will:

1. Request the Debezium PostgreSQL connector version and validate that the archive exists.
2. Show where to find available AWS MSK config provider versions, then request and validate the selected version.
3. Request an authentication mode: current AWS credentials, AWS profile, or IAM role.
4. Request the AWS region, S3 bucket, optional S3 prefix, output ZIP filename, and suggested MSK Connect plugin name.
5. Download and extract the Debezium PostgreSQL connector plugin archive.
6. Download and extract the AWS MSK config provider archive.
7. Package both into a single ZIP file.
8. Upload the ZIP to the requested S3 location.

Run it with `./scripts/build_upload_plugin.py` or `python3 scripts/build_upload_plugin.py`.

At the end, the script prints:

- the uploaded `s3://` object path
- the suggested `custom_plugin_name` value to use in this Terraform module

The packaged ZIP uploaded by the script is the artifact you must register as the MSK Connect custom plugin in AWS before applying this module.

A typical module call looks like this:

```hcl
module "debezium_msk_connector" {
  source = "../debezium-msk-connector"

  cluster_name                             = "example"
  custom_plugin_name                       = "postgresql-msk-debezium-connector-3-5-0"
  bootstrap_brokers_sasl_iam              = aws_msk_cluster.this.bootstrap_brokers_sasl_iam
  kafka_iam_broker_endpoint_parameter_name = "/example/msk/bootstrap-brokers-sasl-iam"
  database_credentials_secret_name         = "example-postgres-debezium"
  table_include_list                       = "public.table_a,public.table_b,public.table_c"

  security_group_ids = [aws_security_group.msk_connect.id]
  subnet_ids         = module.vpc.private_subnets

  tags = {
    Service     = "example"
    ManagedBy   = "terraform"
    Environment = "production"
  }
}
```

## Required Secret Shape

The secret referenced by `database_credentials_secret_name` should expose these keys:

```hcl
{
  host     = "postgres.cluster-abcdefghijkl.us-east-1.rds.amazonaws.com"
  port     = "5432"
  dbname   = "application"
  username = "debezium"
  password = "replace-me"
}
```

## Common Overrides

You can override naming defaults, scaling, logging retention, and selected Debezium connector settings.

```hcl
module "debezium_msk_connector" {
  source = "../debezium-msk-connector"

  cluster_name                             = "example"
  custom_plugin_name                       = "postgresql-msk-debezium-connector-3-5-0"
  bootstrap_brokers_sasl_iam              = aws_msk_cluster.this.bootstrap_brokers_sasl_iam
  kafka_iam_broker_endpoint_parameter_name = "/example/msk/bootstrap-brokers-sasl-iam"
  database_credentials_secret_name         = "example-postgres-debezium"
  table_include_list                       = "public.table_a,public.table_b"
  security_group_ids                       = [aws_security_group.msk_connect.id]
  subnet_ids                               = module.vpc.private_subnets

  connector_name                    = "example-cdc"
  worker_configuration_name         = "example-cdc-workers"
  log_group_name                    = "/aws/mskconnect/example-cdc"
  schema_history_topic              = "schemahistory.example_cdc"
  mcu_count                         = 2
  min_worker_count                  = 1
  max_worker_count                  = 4
  tasks_max                         = 1
  cloudwatch_log_retention_in_days  = 14

  connector_configuration_overrides = {
    "snapshot.mode"           = "initial"
    "decimal.handling.mode"   = "string"
    "time.precision.mode"     = "connect"
    "tombstones.on.delete"    = "false"
    "include.schema.changes"  = "true"
  }
}
```

## Custom Worker Configuration

If you need to replace the default worker properties entirely, provide `worker_configuration_properties_file_content`.

```hcl
module "debezium_msk_connector" {
  source = "../debezium-msk-connector"

  cluster_name                             = "example"
  custom_plugin_name                       = "postgresql-msk-debezium-connector-3-5-0"
  bootstrap_brokers_sasl_iam              = aws_msk_cluster.this.bootstrap_brokers_sasl_iam
  kafka_iam_broker_endpoint_parameter_name = "/example/msk/bootstrap-brokers-sasl-iam"
  database_credentials_secret_name         = "example-postgres-debezium"
  table_include_list                       = "public.table_a"
  security_group_ids                       = [aws_security_group.msk_connect.id]
  subnet_ids                               = module.vpc.private_subnets

  worker_configuration_properties_file_content = <<-EOT
  key.converter=org.apache.kafka.connect.storage.StringConverter
  value.converter=org.apache.kafka.connect.storage.StringConverter
  config.providers=secretsmanager,ssm
  config.providers.secretsmanager.class=com.amazonaws.kafka.config.providers.SecretsManagerConfigProvider
  config.providers.ssm.class=com.amazonaws.kafka.config.providers.SsmParamStoreConfigProvider
  config.providers.secretsmanager.param.region=us-east-1
  config.providers.ssm.param.region=us-east-1
  EOT
}
```

## Notes

- `table_include_list` must use fully qualified PostgreSQL table names such as `public.table_a`.
- `tasks_max` should generally remain `1` for PostgreSQL Debezium connectors.
- `security_group_ids` and `subnet_ids` must allow connector workers to reach both the MSK brokers and the PostgreSQL instance.
- `connector_configuration_overrides` is merged on top of the module defaults, so conflicting keys there will replace the defaults.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.46.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_mskconnect_connector.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mskconnect_connector) | resource |
| [aws_mskconnect_worker_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mskconnect_worker_configuration) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.msk_connect_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_mskconnect_custom_plugin.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/mskconnect_custom_plugin) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bootstrap_brokers_sasl_iam"></a> [bootstrap\_brokers\_sasl\_iam](#input\_bootstrap\_brokers\_sasl\_iam) | SASL/IAM bootstrap broker connection string for the target Amazon MSK cluster. | `string` | n/a | yes |
| <a name="input_cloudwatch_log_retention_in_days"></a> [cloudwatch\_log\_retention\_in\_days](#input\_cloudwatch\_log\_retention\_in\_days) | Number of days to retain connector worker logs in CloudWatch. | `number` | `30` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Base name used to derive connector, slot, publication, and topic defaults. | `string` | n/a | yes |
| <a name="input_connector_configuration_overrides"></a> [connector\_configuration\_overrides](#input\_connector\_configuration\_overrides) | Additional connector configuration entries to merge over the module defaults. | `map(string)` | `{}` | no |
| <a name="input_connector_name"></a> [connector\_name](#input\_connector\_name) | Explicit name for the MSK Connect connector. Defaults to '<cluster\_name>-postgres-connector'. | `string` | `null` | no |
| <a name="input_custom_plugin_name"></a> [custom\_plugin\_name](#input\_custom\_plugin\_name) | Name of the existing AWS MSK Connect custom plugin that contains the Debezium PostgreSQL connector artifacts. | `string` | n/a | yes |
| <a name="input_database_credentials_secret_name"></a> [database\_credentials\_secret\_name](#input\_database\_credentials\_secret\_name) | Name of the AWS Secrets Manager secret that stores the PostgreSQL connection details with keys `host`, `port`, `dbname`, `username`, and `password`. | `string` | n/a | yes |
| <a name="input_kafka_iam_broker_endpoint_parameter_name"></a> [kafka\_iam\_broker\_endpoint\_parameter\_name](#input\_kafka\_iam\_broker\_endpoint\_parameter\_name) | Name of the SSM parameter that contains the MSK IAM bootstrap broker endpoint. | `string` | n/a | yes |
| <a name="input_kafkaconnect_version"></a> [kafkaconnect\_version](#input\_kafkaconnect\_version) | Kafka Connect runtime version for the MSK Connect connector. | `string` | `"3.7.x"` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | Explicit name for the CloudWatch log group. Defaults to '<connector\_name>-logs'. | `string` | `null` | no |
| <a name="input_max_worker_count"></a> [max\_worker\_count](#input\_max\_worker\_count) | Maximum number of autoscaled workers for the MSK Connect connector. | `number` | `2` | no |
| <a name="input_mcu_count"></a> [mcu\_count](#input\_mcu\_count) | Number of MSK Connect units (MCUs) allocated to each connector worker. | `number` | `1` | no |
| <a name="input_min_worker_count"></a> [min\_worker\_count](#input\_min\_worker\_count) | Minimum number of autoscaled workers for the MSK Connect connector. | `number` | `1` | no |
| <a name="input_schema_history_topic"></a> [schema\_history\_topic](#input\_schema\_history\_topic) | Override for the internal Kafka topic used by Debezium schema history. Defaults to 'schemahistory.<cluster\_name>' with hyphens replaced by underscores. | `string` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security group IDs attached to the MSK Connect connector within the VPC. | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs where the MSK Connect connector workers will run. | `list(string)` | n/a | yes |
| <a name="input_table_include_list"></a> [table\_include\_list](#input\_table\_include\_list) | Comma-separated list of PostgreSQL tables that Debezium should capture. Example: 'public.table\_a,public.table\_b'. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to supported resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_tasks_max"></a> [tasks\_max](#input\_tasks\_max) | Maximum number of connector tasks. PostgreSQL Debezium connectors typically run with a single task. | `number` | `1` | no |
| <a name="input_worker_configuration_name"></a> [worker\_configuration\_name](#input\_worker\_configuration\_name) | Explicit name for the MSK Connect worker configuration. Defaults to '<cluster\_name>-worker-config'. | `string` | `null` | no |
| <a name="input_worker_configuration_properties_file_content"></a> [worker\_configuration\_properties\_file\_content](#input\_worker\_configuration\_properties\_file\_content) | Optional full worker configuration properties content. Defaults to a configuration that enables Secrets Manager and SSM config providers in the current AWS region. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connector"></a> [connector](#output\_connector) | The created MSK Connect connector resource. |
| <a name="output_connector_arn"></a> [connector\_arn](#output\_connector\_arn) | ARN of the created MSK Connect connector. |
| <a name="output_connector_name"></a> [connector\_name](#output\_connector\_name) | Name of the created MSK Connect connector. |
| <a name="output_custom_plugin_arn"></a> [custom\_plugin\_arn](#output\_custom\_plugin\_arn) | ARN of the MSK Connect custom plugin used by the connector. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of the CloudWatch log group receiving connector worker logs. |
| <a name="output_service_execution_role_arn"></a> [service\_execution\_role\_arn](#output\_service\_execution\_role\_arn) | ARN of the IAM role assumed by MSK Connect. |
| <a name="output_worker_configuration_arn"></a> [worker\_configuration\_arn](#output\_worker\_configuration\_arn) | ARN of the worker configuration attached to the connector. |
<!-- END_TF_DOCS -->
