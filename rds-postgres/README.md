# RDS Postgres

Provision a Postgres database using AWS RDS.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.45 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.45 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | ../rds-security-group |  |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.disk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [random_id.snapshot_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.database](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | SNS topcis or other actions to invoke for alarms | `list(object({ arn = string }))` | `[]` | no |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Size in GB for the database instance | `number` | n/a | yes |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | CIDR blocks allowed to access the database | `list(string)` | `[]` | no |
| <a name="input_allowed_security_groups"></a> [allowed\_security\_groups](#input\_allowed\_security\_groups) | Security group allowed to access the database | `list(object({ id = string }))` | `[]` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Set to true to immediately apply changes and cause downtime | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Set to false to disable automatic minor version ugprades | `bool` | `true` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Number of days to retain backups | `number` | `30` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | UTC time range in which backups can be captured, such as 18:00-22:00 | `string` | `null` | no |
| <a name="input_create_default_db"></a> [create\_default\_db](#input\_create\_default\_db) | Set to false to disable creating a default database | `bool` | `true` | no |
| <a name="input_default_database"></a> [default\_database](#input\_default\_database) | Name of the default database | `string` | `"postgres"` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | RDS database engine; defaults to Postgres | `string` | `"postgres"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Version for RDS database engine; defaults to Postgres 12.6 | `string` | `"12.6"` | no |
| <a name="input_force_ssl"></a> [force\_ssl](#input\_force\_ssl) | Set to false to allow unencrypted connections to the database | `bool` | `true` | no |
| <a name="input_identifiers"></a> [identifiers](#input\_identifiers) | Override the identifier for one or more databases | `map(string)` | `{}` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Tier for the database instance | `string` | n/a | yes |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | Custom KMS key to encrypt data at rest | `object({ arn = string })` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | UTC day/time range during which maintenance can be performed, such as Mon:00:00-Mon:03:00 | `string` | `null` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Maximum size GB after autoscaling | `number` | `0` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Whether or not to use a high-availability/multi-availability-zone instance | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for this database | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Prefix to be applied to created resources | `list(string)` | `[]` | no |
| <a name="input_password"></a> [password](#input\_password) | Override the generated password for the master user | `string` | `""` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Set to false to disable performance insights | `bool` | `true` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Set to true to access this database outside the VPC | `bool` | `false` | no |
| <a name="input_replica_names"></a> [replica\_names](#input\_replica\_names) | Read-only replicas to create for this database | `list(string)` | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Override the name for the security group | `string` | `""` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Set to false to disable on-disk encryption | `bool` | `true` | no |
| <a name="input_subnet_group_name"></a> [subnet\_group\_name](#input\_subnet\_group\_name) | Override the name for the subnet group | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets connected to the database | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to created resources | `map(string)` | `{}` | no |
| <a name="input_username"></a> [username](#input\_username) | Override the master username for the master user | `string` | `"postgres"` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | VPC for the database instance | `object({ id = string })` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarms"></a> [alarms](#output\_alarms) | CloudWatch alarms for monitoring this database |
| <a name="output_database_urls"></a> [database\_urls](#output\_database\_urls) | URL with all details for connecting to all instances |
| <a name="output_password"></a> [password](#output\_password) | Password for connecting to this database |
| <a name="output_policies"></a> [policies](#output\_policies) | Required IAM policies |
| <a name="output_primary"></a> [primary](#output\_primary) | Primary RDS database instance |
| <a name="output_primary_database_url"></a> [primary\_database\_url](#output\_primary\_database\_url) | URL with all details for connecting to primary database |
| <a name="output_secret_data"></a> [secret\_data](#output\_secret\_data) | Kubernetes secret data |
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | Security group for this database instance |
<!-- END_TF_DOCS -->
