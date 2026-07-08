# RDS Postgres Secondary Admin Login

Automatically rotates the admin password for a database that was **promoted from
a cross-region read replica to an independent primary**.

Unlike [admin-login](../admin-login), which takes the username and initial
password as literal inputs, this module **seeds them from an existing (primary)
secret**. The promoted database inherited the primary's admin user, password and
database name at promotion time, so the new secret is built from:

- `username`, `password` and `dbname` read from `source_secret_arn` (the primary
  admin secret, typically a region-local replica of it), and
- `host`, `port` and `engine` from the promoted database's own endpoint (looked
  up by `identifier`).

Once created, the secret rotates itself with the same standard admin rotation as
[admin-login](../admin-login): the rotation Lambda manages the promoted database
directly (alternating between the primary and `<username>_alt` users). It does
**not** read the source secret at rotation time -- the source secret is only used
at plan/apply time to seed the initial value -- because the promoted database is
now fully independent.

Note that this performs a direct update of the admin password, so it isn't
suitable for application credentials. We recommend you combine this module with
a dedicated user login to create separate admin and user credentials.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rotation"></a> [rotation](#module\_rotation) | github.com/thoughtbot/terraform-aws-secrets//secret-rotation-function?ref=v0.9.0 |  |
| <a name="module_secret"></a> [secret](#module\_secret) | github.com/thoughtbot/terraform-aws-secrets//secret?ref=v0.9.0 |  |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | ../../security-group |  |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.describe_database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.access_admin_login](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_instance) | data source |
| [aws_iam_policy_document.describe_database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_secretsmanager_secret_version.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_principals"></a> [admin\_principals](#input\_admin\_principals) | Principals allowed to peform admin actions (default: current account) | `list(string)` | `null` | no |
| <a name="input_alternate_username"></a> [alternate\_username](#input\_alternate\_username) | Username for the alternate login used during rotation (default: <source username>\_alt) | `string` | `null` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Identifier of the database for which a login will be managed | `string` | n/a | yes |
| <a name="input_read_principals"></a> [read\_principals](#input\_read\_principals) | Principals allowed to read the secret (default: current account) | `list(string)` | `null` | no |
| <a name="input_replica_regions"></a> [replica\_regions](#input\_replica\_regions) | List of regions to replicate the secret to | <pre>list(object({<br>    region     = string<br>    kms_key_id = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | Override the name for this secret | `string` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security groups to attach to the rotation function | `list(string)` | `[]` | no |
| <a name="input_source_secret_arn"></a> [source\_secret\_arn](#input\_source\_secret\_arn) | ARN (or name) of the primary admin secret to seed username, password and dbname from. Must be readable from this module's region (typically a replica of the primary secret). | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets in which the rotation function should run | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to created resources | `map(string)` | `{}` | no |
| <a name="input_trust_tags"></a> [trust\_tags](#input\_trust\_tags) | Tags required on principals accessing the secret | `map(string)` | `{}` | no |
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
