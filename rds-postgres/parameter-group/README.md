# RDS Parameter Group

Provision a Postgres-compatible RDS parameter group.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_db_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Version for RDS database engine | `string` | n/a | yes |
| <a name="input_force_ssl"></a> [force\_ssl](#input\_force\_ssl) | Set to false to allow unencrypted connections to the database | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the parameter group | `string` | n/a | yes |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Parameters to the applied to the database | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to created resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_engine_version"></a> [engine\_version](#output\_engine\_version) | Version of Postgres used by this configuration |
| <a name="output_parameter_group_name"></a> [parameter\_group\_name](#output\_parameter\_group\_name) | Name of the created parameter group |
<!-- END_TF_DOCS -->
