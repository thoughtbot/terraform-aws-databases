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

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_elasticsearch_secret"></a> [elasticsearch\_secret](#module\_elasticsearch\_secret) | github.com/thoughtbot/terraform-aws-secrets//secret | v0.8.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_opensearch_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain) | resource |
| [aws_opensearch_domain_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain_policy) | resource |
| [aws_opensearch_domain_saml_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain_saml_options) | resource |
| [aws_opensearch_outbound_connection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_outbound_connection) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | IAM policy document specifying the access policies for the domain. Required if `create_access_policy` is `false` | `string` | `null` | no |
| <a name="input_access_policy_override_policy_documents"></a> [access\_policy\_override\_policy\_documents](#input\_access\_policy\_override\_policy\_documents) | List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid` | `list(string)` | `[]` | no |
| <a name="input_access_policy_source_policy_documents"></a> [access\_policy\_source\_policy\_documents](#input\_access\_policy\_source\_policy\_documents) | List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s | `list(string)` | `[]` | no |
| <a name="input_access_policy_statements"></a> [access\_policy\_statements](#input\_access\_policy\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | `any` | `{}` | no |
| <a name="input_admin_principals"></a> [admin\_principals](#input\_admin\_principals) | Principals allowed to peform admin actions (default: current account) | `list(string)` | `null` | no |
| <a name="input_advanced_options"></a> [advanced\_options](#input\_advanced\_options) | Key-value string pairs to specify advanced configuration options. Note that the values for these configuration options must be strings (wrapped in quotes) or they may be wrong and cause a perpetual diff, causing Terraform to want to recreate your Elasticsearch domain on every apply | `map(string)` | `{}` | no |
| <a name="input_advanced_security_options"></a> [advanced\_security\_options](#input\_advanced\_security\_options) | Configuration block for [fine-grained access control](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/fgac.html) | `any` | <pre>{<br>  "anonymous_auth_enabled": false,<br>  "enabled": true<br>}</pre> | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Unique name for the opensearch instance | `string` | `""` | no |
| <a name="input_auto_tune_options"></a> [auto\_tune\_options](#input\_auto\_tune\_options) | Configuration block for the Auto-Tune options of the domain | `any` | <pre>{<br>  "desired_state": "DISABLED"<br>}</pre> | no |
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events | `number` | `60` | no |
| <a name="input_cloudwatch_log_group_skip_destroy"></a> [cloudwatch\_log\_group\_skip\_destroy](#input\_cloudwatch\_log\_group\_skip\_destroy) | Set to true if you do not wish the log group (and any logs it may contain) to be deleted at destroy time, and instead just remove the log group from the Terraform state | `bool` | `null` | no |
| <a name="input_cloudwatch_log_resource_policy_name"></a> [cloudwatch\_log\_resource\_policy\_name](#input\_cloudwatch\_log\_resource\_policy\_name) | Name of the resource policy for OpenSearch to log to CloudWatch | `string` | `null` | no |
| <a name="input_cluster_config"></a> [cluster\_config](#input\_cluster\_config) | Configuration block for the cluster of the domain | `any` | <pre>{<br>  "dedicated_master_enabled": true<br>}</pre> | no |
| <a name="input_cognito_options"></a> [cognito\_options](#input\_cognito\_options) | Configuration block for authenticating Kibana with Cognito | `any` | `{}` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_access_policy"></a> [create\_access\_policy](#input\_create\_access\_policy) | Determines whether an access policy will be created | `bool` | `true` | no |
| <a name="input_create_cloudwatch_log_groups"></a> [create\_cloudwatch\_log\_groups](#input\_create\_cloudwatch\_log\_groups) | Determines whether log groups are created | `bool` | `true` | no |
| <a name="input_create_cloudwatch_log_resource_policy"></a> [create\_cloudwatch\_log\_resource\_policy](#input\_create\_cloudwatch\_log\_resource\_policy) | Determines whether a resource policy will be created for OpenSearch to log to CloudWatch | `bool` | `true` | no |
| <a name="input_create_saml_options"></a> [create\_saml\_options](#input\_create\_saml\_options) | Determines whether SAML options will be created | `bool` | `false` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Determines if a security group is created | `bool` | `true` | no |
| <a name="input_domain_endpoint_options"></a> [domain\_endpoint\_options](#input\_domain\_endpoint\_options) | Configuration block for domain endpoint HTTP(S) related options | `any` | <pre>{<br>  "enforce_https": true,<br>  "tls_security_policy": "Policy-Min-TLS-1-2-2019-07"<br>}</pre> | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Name of the domain | `string` | `""` | no |
| <a name="input_ebs_options"></a> [ebs\_options](#input\_ebs\_options) | Configuration block for EBS related options, may be required based on chosen [instance size](https://aws.amazon.com/elasticsearch-service/pricing/) | `any` | <pre>{<br>  "ebs_enabled": true,<br>  "volume_size": 64,<br>  "volume_type": "gp3"<br>}</pre> | no |
| <a name="input_enable_access_policy"></a> [enable\_access\_policy](#input\_enable\_access\_policy) | Determines whether an access policy will be applied to the domain | `bool` | `true` | no |
| <a name="input_encrypt_at_rest"></a> [encrypt\_at\_rest](#input\_encrypt\_at\_rest) | Configuration block for encrypting at rest | `any` | <pre>{<br>  "enabled": true<br>}</pre> | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Version of the OpenSearch engine to use | `string` | `null` | no |
| <a name="input_log_publishing_options"></a> [log\_publishing\_options](#input\_log\_publishing\_options) | Configuration block for publishing slow and application logs to CloudWatch Logs. This block can be declared multiple times, for each log\_type, within the same resource | `any` | <pre>[<br>  {<br>    "log_type": "INDEX_SLOW_LOGS"<br>  },<br>  {<br>    "log_type": "SEARCH_SLOW_LOGS"<br>  }<br>]</pre> | no |
| <a name="input_node_to_node_encryption"></a> [node\_to\_node\_encryption](#input\_node\_to\_node\_encryption) | Configuration block for node-to-node encryption options | `any` | <pre>{<br>  "enabled": true<br>}</pre> | no |
| <a name="input_outbound_connections"></a> [outbound\_connections](#input\_outbound\_connections) | Map of AWS OpenSearch outbound connections to create | `any` | `{}` | no |
| <a name="input_read_principals"></a> [read\_principals](#input\_read\_principals) | Principals allowed to read the secret (default: current account) | `list(string)` | `null` | no |
| <a name="input_saml_options"></a> [saml\_options](#input\_saml\_options) | SAML authentication options for an AWS OpenSearch Domain | `any` | `{}` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description of the security group created | `string` | `null` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name to use on security group created | `string` | `null` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Security group ingress and egress rules to add to the security group created | `any` | `{}` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | A map of additional tags to add to the security group created | `map(string)` | `{}` | no |
| <a name="input_security_group_use_name_prefix"></a> [security\_group\_use\_name\_prefix](#input\_security\_group\_use\_name\_prefix) | Determines whether the security group name (`security_group_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Create and delete timeout configurations for the domain | `map(string)` | `{}` | no |
| <a name="input_vpc_options"></a> [vpc\_options](#input\_vpc\_options) | Configuration block for VPC related options. Adding or removing this configuration forces a new resource ([documentation](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-vpc.html#es-vpc-limitations)) | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_logs"></a> [cloudwatch\_logs](#output\_cloudwatch\_logs) | Map of CloudWatch log groups created and their attributes |
| <a name="output_domain_arn"></a> [domain\_arn](#output\_domain\_arn) | The Amazon Resource Name (ARN) of the domain |
| <a name="output_domain_dashboard_endpoint"></a> [domain\_dashboard\_endpoint](#output\_domain\_dashboard\_endpoint) | Domain-specific endpoint for Dashboard without https scheme |
| <a name="output_domain_endpoint"></a> [domain\_endpoint](#output\_domain\_endpoint) | Domain-specific endpoint used to submit index, search, and data upload requests |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | The unique identifier for the domain |
| <a name="output_environment_variables"></a> [environment\_variables](#output\_environment\_variables) | Environment variables set by this rotation function |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ID of the KMS key used to encrypt the secret |
| <a name="output_outbound_connections"></a> [outbound\_connections](#output\_outbound\_connections) | Map of outbound connections created and their attributes |
| <a name="output_policy_json"></a> [policy\_json](#output\_policy\_json) | Required IAM policies |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | ARN of the secrets manager secret containing credentials |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | Name of the secrets manager secret containing credentials |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
<!-- END_TF_DOCS -->