# RDS Postgres Replica

Provision a Postgres database configured as a replica using AWS RDS.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.23.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alarms"></a> [alarms](#module\_alarms) | ../cloudwatch-alarms | n/a |
| <a name="module_parameter_group"></a> [parameter\_group](#module\_parameter\_group) | ../parameter-group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | SNS topic ARNs or other actions to invoke for alarms | `list(string)` | `[]` | no |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Size in GB for the database instance | `number` | n/a | yes |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Set to true to immediately apply changes and cause downtime | `bool` | `false` | no |
| <a name="input_create_cloudwatch_alarms"></a> [create\_cloudwatch\_alarms](#input\_create\_cloudwatch\_alarms) | Set to false to disable creation of CloudWatch alarms | `bool` | `true` | no |
| <a name="input_create_parameter_group"></a> [create\_parameter\_group](#input\_create\_parameter\_group) | Set to false to use existing parameter group | `bool` | `true` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Version for RDS database engine | `string` | n/a | yes |
| <a name="input_force_ssl"></a> [force\_ssl](#input\_force\_ssl) | Set to false to allow unencrypted connections to the database | `bool` | `true` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Unique identifier for this database | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Tier for the database instance | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key to encrypt data at rest | `string` | `null` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Maximum size GB after autoscaling | `number` | `0` | no |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | Name of the RDS parameter group; defaults to identifier | `string` | `""` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Set to false to disable performance insights | `bool` | `true` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Set to true to access this database outside the VPC | `bool` | `false` | no |
| <a name="input_replicate_source_db"></a> [replicate\_source\_db](#input\_replicate\_source\_db) | Identifier of the primary database instance to replicate | `string` | n/a | yes |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Set to false to disable on-disk encryption | `bool` | `true` | no |
| <a name="input_subnet_group_name"></a> [subnet\_group\_name](#input\_subnet\_group\_name) | Name of the RDS subnet group (only for cross-region replication) | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to created resources | `map(string)` | `{}` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | IDs of VPC security groups for this instance (if different from primary) | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_host"></a> [host](#output\_host) | The hostname to use when connecting to this replica |
| <a name="output_identifier"></a> [identifier](#output\_identifier) | Identifier of the created RDS database |
| <a name="output_instance"></a> [instance](#output\_instance) | The created replica |
<!-- END_TF_DOCS -->
