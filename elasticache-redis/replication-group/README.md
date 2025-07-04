# ElastiCache Redis

Provision a Redis cluster using AWS ElastiCache.

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
| <a name="module_client_security_group"></a> [client\_security\_group](#module\_client\_security\_group) | ../../security-group | n/a |
| <a name="module_customer_kms"></a> [customer\_kms](#module\_customer\_kms) | github.com/thoughtbot/terraform-aws-secrets//customer-managed-kms | v0.8.0 |
| <a name="module_server_security_group"></a> [server\_security\_group](#module\_server\_security\_group) | ../../security-group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.check_cpu_balance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_elasticache_replication_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [random_password.auth_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_ec2_instance_type.instance_attributes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | SNS topcis or other actions to invoke for alarms | `list(object({ arn = string }))` | `[]` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | CIDR blocks allowed to access the database | `list(string)` | `[]` | no |
| <a name="input_allowed_security_group_ids"></a> [allowed\_security\_group\_ids](#input\_allowed\_security\_group\_ids) | Security group allowed to access the database | `list(string)` | `[]` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Set to true to apply changes immediately | `bool` | `false` | no |
| <a name="input_at_rest_encryption_enabled"></a> [at\_rest\_encryption\_enabled](#input\_at\_rest\_encryption\_enabled) | Set to false to disable encryption at rest | `bool` | `true` | no |
| <a name="input_client_security_group_name"></a> [client\_security\_group\_name](#input\_client\_security\_group\_name) | Override the name for the security group; defaults to identifer | `string` | `""` | no |
| <a name="input_create_client_security_group"></a> [create\_client\_security\_group](#input\_create\_client\_security\_group) | Set to false to only use existing security groups | `bool` | `true` | no |
| <a name="input_create_server_security_group"></a> [create\_server\_security\_group](#input\_create\_server\_security\_group) | Set to false to only use existing security groups | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Human-readable description for this replication group | `string` | n/a | yes |
| <a name="input_enable_kms"></a> [enable\_kms](#input\_enable\_kms) | Enable KMS encryption | `bool` | `true` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Elasticache database engine; defaults to Redis | `string` | `"redis"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Version for RDS database engine | `string` | `"7.1"` | no |
| <a name="input_global_replication_group_id"></a> [global\_replication\_group\_id](#input\_global\_replication\_group\_id) | The ID of the global replication group to which this replication group should belong. | `string` | `null` | no |
| <a name="input_initial_auth_token"></a> [initial\_auth\_token](#input\_initial\_auth\_token) | Override the initial auth token | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key to encrypt data at rest | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for this cluster | `string` | n/a | yes |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | Node type for the Elasticache instance | `string` | n/a | yes |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | Parameter group name for the Redis cluster | `string` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | Port on which to listen | `number` | `6379` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of read-only replicas to add to the cluster | `number` | `1` | no |
| <a name="input_replication_group_id"></a> [replication\_group\_id](#input\_replication\_group\_id) | Override the ID for the replication group | `string` | `""` | no |
| <a name="input_server_security_group_ids"></a> [server\_security\_group\_ids](#input\_server\_security\_group\_ids) | IDs of VPC security groups for this instance. One of vpc\_id or server\_security\_group\_ids is required | `list(string)` | `[]` | no |
| <a name="input_server_security_group_name"></a> [server\_security\_group\_name](#input\_server\_security\_group\_name) | Override the name for the security group; defaults to identifer | `string` | `""` | no |
| <a name="input_snapshot_name"></a> [snapshot\_name](#input\_snapshot\_name) | Name of an existing snapshot from which to create a cluster | `string` | `null` | no |
| <a name="input_snapshot_retention_limit"></a> [snapshot\_retention\_limit](#input\_snapshot\_retention\_limit) | Number of days to retain snapshots | `number` | `7` | no |
| <a name="input_subnet_group_name"></a> [subnet\_group\_name](#input\_subnet\_group\_name) | Override the name for the subnet group | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets connected to the database | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to created resources | `map(string)` | `{}` | no |
| <a name="input_transit_encryption_enabled"></a> [transit\_encryption\_enabled](#input\_transit\_encryption\_enabled) | Set to false to disable TLS | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC for this instance. One of vpc\_id or vpc\_security\_group\_ids is required | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_security_group_id"></a> [client\_security\_group\_id](#output\_client\_security\_group\_id) | Name of the security group created for clients |
| <a name="output_id"></a> [id](#output\_id) | ID of the created replication group |
| <a name="output_initial_auth_token"></a> [initial\_auth\_token](#output\_initial\_auth\_token) | Initial value for the user auth token |
| <a name="output_instance"></a> [instance](#output\_instance) | Elasticache Redis replication group |
| <a name="output_server_security_group_id"></a> [server\_security\_group\_id](#output\_server\_security\_group\_id) | Name of the security group created for the server |
<!-- END_TF_DOCS -->
