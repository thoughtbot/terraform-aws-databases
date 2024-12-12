# RDS Postgres

Provision a Postgres database using AWS RDS.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alarms"></a> [alarms](#module\_alarms) | ../cloudwatch-alarms | n/a |
| <a name="module_client_security_group"></a> [client\_security\_group](#module\_client\_security\_group) | ../../security-group | n/a |
| <a name="module_customer_kms"></a> [customer\_kms](#module\_customer\_kms) | github.com/thoughtbot/terraform-aws-secrets//customer-managed-kms | v0.8.0 |
| <a name="module_parameter_group"></a> [parameter\_group](#module\_parameter\_group) | ../parameter-group | n/a |
| <a name="module_server_security_group"></a> [server\_security\_group](#module\_server\_security\_group) | ../../security-group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [random_id.snapshot_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.database](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Username for the admin user | `string` | `"postgres"` | no |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | SNS topic ARNs or other actions to invoke for alarms | `list(string)` | `[]` | no |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Size in GB for the database instance | `number` | n/a | yes |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | CIDR blocks allowed to access the database | `list(string)` | `[]` | no |
| <a name="input_allowed_security_group_ids"></a> [allowed\_security\_group\_ids](#input\_allowed\_security\_group\_ids) | Security group allowed to access the database | `list(string)` | `[]` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Set to true to immediately apply changes and cause downtime | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Set to false to disable automatic minor version ugprades | `bool` | `true` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Number of days to retain backups | `number` | `30` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | UTC time range in which backups can be captured, such as 18:00-22:00 | `string` | `null` | no |
| <a name="input_ca_cert_id"></a> [ca\_cert\_id](#input\_ca\_cert\_id) | Certificate authority for RDS database | `string` | `"rds-ca-rsa2048-g1"` | no |
| <a name="input_client_security_group_name"></a> [client\_security\_group\_name](#input\_client\_security\_group\_name) | Override the name for the security group; defaults to identifer | `string` | `""` | no |
| <a name="input_create_client_security_group"></a> [create\_client\_security\_group](#input\_create\_client\_security\_group) | Set to false to only use existing security groups | `bool` | `true` | no |
| <a name="input_create_cloudwatch_alarms"></a> [create\_cloudwatch\_alarms](#input\_create\_cloudwatch\_alarms) | Set to false to disable creation of CloudWatch alarms | `bool` | `true` | no |
| <a name="input_create_default_db"></a> [create\_default\_db](#input\_create\_default\_db) | Set to false to disable creating a default database | `bool` | `true` | no |
| <a name="input_create_parameter_group"></a> [create\_parameter\_group](#input\_create\_parameter\_group) | Set to false to use existing parameter group | `bool` | `true` | no |
| <a name="input_create_server_security_group"></a> [create\_server\_security\_group](#input\_create\_server\_security\_group) | Set to false to only use existing security groups | `bool` | `true` | no |
| <a name="input_create_subnet_group"></a> [create\_subnet\_group](#input\_create\_subnet\_group) | Set to false to use existing subnet group | `bool` | `true` | no |
| <a name="input_default_database"></a> [default\_database](#input\_default\_database) | Name of the default database | `string` | `"postgres"` | no |
| <a name="input_enable_kms"></a> [enable\_kms](#input\_enable\_kms) | Enable KMS encryption | `bool` | `true` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | Set of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported | `list(string)` | `[]` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | RDS database engine; defaults to Postgres | `string` | `"postgres"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Version for RDS database engine | `string` | n/a | yes |
| <a name="input_force_ssl"></a> [force\_ssl](#input\_force\_ssl) | Set to false to allow unencrypted connections to the database | `bool` | `true` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Unique identifier for this database | `string` | n/a | yes |
| <a name="input_initial_password"></a> [initial\_password](#input\_initial\_password) | Override the initial password for the admin user | `string` | `""` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Tier for the database instance | `string` | n/a | yes |
| <a name="input_iops"></a> [iops](#input\_iops) | The amount of provisioned IOPS. Required if storage type is `io1` | `number` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key to encrypt data at rest | `string` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | UTC day/time range during which maintenance can be performed, such as Mon:00:00-Mon:03:00 | `string` | `null` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Maximum size GB after autoscaling | `number` | `0` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Whether or not to use a high-availability/multi-availability-zone instance | `bool` | `false` | no |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | Name of the RDS parameter group; defaults to identifier | `string` | `""` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Set to false to disable performance insights | `bool` | `true` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Set to true to access this database outside the VPC | `bool` | `false` | no |
| <a name="input_server_security_group_ids"></a> [server\_security\_group\_ids](#input\_server\_security\_group\_ids) | IDs of VPC security groups for this instance. One of vpc\_id or server\_security\_group\_ids is required | `list(string)` | `[]` | no |
| <a name="input_server_security_group_name"></a> [server\_security\_group\_name](#input\_server\_security\_group\_name) | Override the name for the security group; defaults to identifer | `string` | `""` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Set to true to skip a snapshot when destroying | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | Set this to create the database from an existing snapshot | `string` | `null` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Set to false to disable on-disk encryption | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Storage type for the EBS volume. One of `standard` (magnetic), `gp2` (general purpose SSD), or `io1` (provisioned IOPS SSD) | `string` | `"gp2"` | no |
| <a name="input_subnet_group_description"></a> [subnet\_group\_description](#input\_subnet\_group\_description) | Set a description for the subnet group | `string` | `"Postgres subnet group"` | no |
| <a name="input_subnet_group_name"></a> [subnet\_group\_name](#input\_subnet\_group\_name) | Name of the RDS subnet group (defaults to identifier) | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets connected to the database; required if creating a subnet group | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to created resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC for this instance. One of vpc\_id or vpc\_security\_group\_ids is required | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | Admin username for connecting to this database |
| <a name="output_client_security_group_id"></a> [client\_security\_group\_id](#output\_client\_security\_group\_id) | Name of the security group created for clients |
| <a name="output_default_database"></a> [default\_database](#output\_default\_database) | Name of the default database, if created |
| <a name="output_host"></a> [host](#output\_host) | The hostname to use when connecting to this database |
| <a name="output_identifier"></a> [identifier](#output\_identifier) | Identifier of the created RDS database |
| <a name="output_initial_password"></a> [initial\_password](#output\_initial\_password) | Initial admin password for connecting to this database |
| <a name="output_instance"></a> [instance](#output\_instance) | The created RDS database instance |
| <a name="output_primary_kms_key"></a> [primary\_kms\_key](#output\_primary\_kms\_key) | KMS key arn in use by primary database instance. |
| <a name="output_server_security_group_id"></a> [server\_security\_group\_id](#output\_server\_security\_group\_id) | Name of the security group created for the server |
<!-- END_TF_DOCS -->
