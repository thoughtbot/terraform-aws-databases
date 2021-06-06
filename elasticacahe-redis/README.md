# ElastiCache Redis

Provision a Redis cluster using AWS ElastiCache.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | ../rds-security-group |  |

## Resources

| Name | Type |
|------|------|
| [aws_elasticache_replication_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_security_group_rule.intracluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [random_password.auth_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | SNS topcis or other actions to invoke for alarms | `list(object({ arn = string }))` | `[]` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | CIDR blocks allowed to access the database | `list(string)` | `[]` | no |
| <a name="input_allowed_security_groups"></a> [allowed\_security\_groups](#input\_allowed\_security\_groups) | Security group allowed to access the database | `list(object({ id = string }))` | `[]` | no |
| <a name="input_at_rest_encryption_enabled"></a> [at\_rest\_encryption\_enabled](#input\_at\_rest\_encryption\_enabled) | Set to false to disable encryption at rest | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Human-readable description for this replication group | `string` | n/a | yes |
| <a name="input_engine"></a> [engine](#input\_engine) | Elasticache database engine; defaults to Redis | `string` | `"redis"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Version for RDS database engine; defaults to Redis 5.0 | `string` | `"5.0.6"` | no |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | Custom KMS key to encrypt data at rest | `object({ arn = string })` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for this cluster | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Prefix to be applied to created resources | `list(string)` | `[]` | no |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | Node type for the Elasticache instance | `string` | n/a | yes |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | Parameter group name for the Redis cluster | `string` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | Port on which to listen | `number` | `6379` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of read-only replicas to add to the cluster | `number` | `1` | no |
| <a name="input_replication_group_id"></a> [replication\_group\_id](#input\_replication\_group\_id) | Override the ID for the replication group | `string` | `""` | no |
| <a name="input_snapshot_retention_limit"></a> [snapshot\_retention\_limit](#input\_snapshot\_retention\_limit) | Number of days to retain snapshots | `number` | `7` | no |
| <a name="input_subnet_group_name"></a> [subnet\_group\_name](#input\_subnet\_group\_name) | Override the name for the subnet group | `string` | `""` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnets connected to the database | `map(object({ id = string }))` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to created resources | `map(string)` | `{}` | no |
| <a name="input_transit_encryption_enabled"></a> [transit\_encryption\_enabled](#input\_transit\_encryption\_enabled) | Set to false to disable TLS | `bool` | `true` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | VPC for the database instance | `object({ id = string })` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance"></a> [instance](#output\_instance) | Elasticache Redis replication group |
| <a name="output_policies"></a> [policies](#output\_policies) | Required IAM policies |
| <a name="output_redis_url"></a> [redis\_url](#output\_redis\_url) | URL for connecting to Redis |
| <a name="output_secret_data"></a> [secret\_data](#output\_secret\_data) | Kubernetes secret data |
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | Security group for this Redis instance |
<!-- END_TF_DOCS -->
