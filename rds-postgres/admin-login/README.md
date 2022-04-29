# RDS Postgres Admin Login

Automatically rotates the admin password for an RDS secret.

The database details and initial password will be written to an AWS Secrets
Manager secret. Once created, the secret will automatically rotate itself using
a Lambda function.

Note that this performs a direct update of the admin password, so it isn't
suitable for application credentials. We recommend you combine this module with
[user-login](../user-login) to create separate admin and user credentials.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.45 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.45 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rotation"></a> [rotation](#module\_rotation) | github.com/thoughtbot/terraform-aws-secrets//secret-rotation-function?ref=v0.2.0 |  |
| <a name="module_secret"></a> [secret](#module\_secret) | github.com/thoughtbot/terraform-aws-secrets//secret?ref=v0.2.0 |  |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.describe_database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.access_admin_login](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.function_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_instance) | data source |
| [aws_iam_policy_document.describe_database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_principals"></a> [admin\_principals](#input\_admin\_principals) | Principals allowed to peform admin actions (default: current account) | `list(string)` | `null` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the database to connect to | `string` | n/a | yes |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Identifier of the database for which a login will be managed | `string` | n/a | yes |
| <a name="input_initial_password"></a> [initial\_password](#input\_initial\_password) | ARN of the KMS key used to encrypt the admin login | `string` | n/a | yes |
| <a name="input_read_principals"></a> [read\_principals](#input\_read\_principals) | Principals allowed to read the secret (default: current account) | `list(string)` | `null` | no |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | Override the name for this secret | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets in which the rotation function should run | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to created resources | `map(string)` | `{}` | no |
| <a name="input_trust_tags"></a> [trust\_tags](#input\_trust\_tags) | Tags required on principals accessing the secret | `map(string)` | `{}` | no |
| <a name="input_username"></a> [username](#input\_username) | The username for which a login will be managed | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC in which the rotation function should run | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ID of the KMS key used to encrypt the secret |
| <a name="output_policy_json"></a> [policy\_json](#output\_policy\_json) | Required IAM policies |
| <a name="output_rotation_role_arn"></a> [rotation\_role\_arn](#output\_rotation\_role\_arn) | ARN of the IAM role allowed to rotate this secret |
| <a name="output_rotation_role_name"></a> [rotation\_role\_name](#output\_rotation\_role\_name) | Name of the IAM role allowed to rotate this secret |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | ARN of the secrets manager secret containing credentials |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | Name of the secrets manager secret containing credentials |
<!-- END_TF_DOCS -->
