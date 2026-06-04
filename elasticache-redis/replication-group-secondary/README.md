# ElastiCache Redis (Global Datastore Secondary)

Provision a secondary (regional) member of an ElastiCache global datastore.

Use this module instead of `replication-group` when joining an existing global
datastore via `global_replication_group_id`. A secondary member inherits the
engine, engine version, node type, encryption settings, parameter group,
snapshots, and auth token from the global datastore's primary, so those
arguments are intentionally omitted here -- the AWS provider rejects them when
`global_replication_group_id` is set.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_client_security_group"></a> [client\_security\_group](#module\_client\_security\_group) | ../../security-group | n/a |
| <a name="module_server_security_group"></a> [server\_security\_group](#module\_server\_security\_group) | ../../security-group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.check_cpu_balance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_elasticache_replication_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_ec2_instance_type.instance_attributes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type) | data source |
| [aws_secretsmanager_secret_version.auth_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | SNS topics or other actions to invoke for alarms | `list(object({ arn = string }))` | `[]` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | CIDR blocks allowed to access the database | `list(string)` | `[]` | no |
| <a name="input_allowed_security_group_ids"></a> [allowed\_security\_group\_ids](#input\_allowed\_security\_group\_ids) | Security group allowed to access the database | `list(string)` | `[]` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Set to true to apply changes immediately | `bool` | `false` | no |
| <a name="input_auth_token"></a> [auth\_token](#input\_auth\_token) | Auth token of the global datastore primary, supplied directly. Used only when auth\_token\_secret\_name is not set. Must match the primary exactly; it is not inherited at creation time. | `string` | `null` | no |
| <a name="input_auth_token_secret_name"></a> [auth\_token\_secret\_name](#input\_auth\_token\_secret\_name) | Name (or ARN) of the Secrets Manager secret holding the global datastore primary's auth token, as a JSON object with a `token` key (the format written by the auth-token module). The secret must be readable from this region. Preferred over auth\_token so the value stays in sync across rotations. | `string` | `null` | no |
| <a name="input_client_security_group_name"></a> [client\_security\_group\_name](#input\_client\_security\_group\_name) | Override the name for the security group; defaults to identifer | `string` | `""` | no |
| <a name="input_create_client_security_group"></a> [create\_client\_security\_group](#input\_create\_client\_security\_group) | Set to false to only use existing security groups | `bool` | `true` | no |
| <a name="input_create_server_security_group"></a> [create\_server\_security\_group](#input\_create\_server\_security\_group) | Set to false to only use existing security groups | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Human-readable description for this replication group | `string` | n/a | yes |
| <a name="input_global_replication_group_id"></a> [global\_replication\_group\_id](#input\_global\_replication\_group\_id) | The ID of the global replication group to which this replication group belongs. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name for this cluster | `string` | n/a | yes |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | Node type of the global datastore (used only to size the CloudWatch alarms; not set on the replication group, which inherits it from the primary). Must match the primary's node type. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | Port on which to listen (used for the security group; the replication group itself inherits the port from the global datastore) | `number` | `6379` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of read-only replicas to add to the cluster | `number` | `1` | no |
| <a name="input_replication_group_id"></a> [replication\_group\_id](#input\_replication\_group\_id) | Override the ID for the replication group | `string` | `""` | no |
| <a name="input_server_security_group_ids"></a> [server\_security\_group\_ids](#input\_server\_security\_group\_ids) | IDs of VPC security groups for this instance. One of vpc\_id or server\_security\_group\_ids is required | `list(string)` | `[]` | no |
| <a name="input_server_security_group_name"></a> [server\_security\_group\_name](#input\_server\_security\_group\_name) | Override the name for the security group; defaults to identifer | `string` | `""` | no |
| <a name="input_subnet_group_name"></a> [subnet\_group\_name](#input\_subnet\_group\_name) | Override the name for the subnet group | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets connected to the database | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to created resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC for this instance. One of vpc\_id or vpc\_security\_group\_ids is required | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_security_group_id"></a> [client\_security\_group\_id](#output\_client\_security\_group\_id) | Name of the security group created for clients |
| <a name="output_id"></a> [id](#output\_id) | ID of the created replication group |
| <a name="output_instance"></a> [instance](#output\_instance) | Elasticache Redis replication group |
| <a name="output_server_security_group_id"></a> [server\_security\_group\_id](#output\_server\_security\_group\_id) | Name of the security group created for the server |
<!-- END_TF_DOCS -->