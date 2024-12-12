# AWS Ingress

Creates a Kafka cluster using AWS managed streaming for Kafka service (MSK).

![AWS managed streaming for Kafka service](https://docs.aws.amazon.com/msk/latest/developerguide/what-is-msk.html)

## Example

```terraform
module "kafka_staging" {
  source = "github.com/thoughtbot/terraform-aws-databases//kafka"

  cluster_name  = "kafka-cluster
  instance_type = "kafka.t3.small"
  kafka_version = "2.6.2"

  private_tags = {subnet_type = "private"} # Private Subnet tags
  public_tags  = {subnet_type = "private"} # Public Subnet tags
  vpc_tags     = {vpc_tag = "sandbox"} # VPC tags
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_additional_vpc"></a> [additional\_vpc](#module\_additional\_vpc) | github.com/thoughtbot/flightdeck//aws/network-data | v0.9.2 |
| <a name="module_network"></a> [network](#module\_network) | github.com/thoughtbot/flightdeck//aws/network-data | v0.9.2 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_msk_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_vpc_tags"></a> [additional\_vpc\_tags](#input\_additional\_vpc\_tags) | Tags to identify an additional VPC | `map(string)` | `{}` | no |
| <a name="input_broker_node_count"></a> [broker\_node\_count](#input\_broker\_node\_count) | The desired total number of broker nodes in the kafka cluster | `number` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the MSK cluster | `string` | n/a | yes |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | The size in GiB of the EBS volume for the data drive on each broker node | `number` | `5` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type to use for the kafka brokers | `string` | n/a | yes |
| <a name="input_kafka_version"></a> [kafka\_version](#input\_kafka\_version) | Desired Kafka version on the MSK cluster | `string` | n/a | yes |
| <a name="input_private_tags"></a> [private\_tags](#input\_private\_tags) | Tags to identify private subnets | `map(string)` | <pre>{<br>  "kubernetes.io/role/internal-elb": "1"<br>}</pre> | no |
| <a name="input_public_tags"></a> [public\_tags](#input\_public\_tags) | Tags to identify public subnets | `map(string)` | <pre>{<br>  "kubernetes.io/role/elb": "1"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to created resources | `map(string)` | `{}` | no |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_tags) | Tags to identify the VPC | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bootstrap_brokers"></a> [bootstrap\_brokers](#output\_bootstrap\_brokers) | Comma separated list of one or more hostname:port pairs of kafka brokers suitable to bootstrap connectivity to the kafka cluster |
| <a name="output_bootstrap_brokers_tls"></a> [bootstrap\_brokers\_tls](#output\_bootstrap\_brokers\_tls) | TLS connection host:port pairs |
| <a name="output_zookeeper_connect_string"></a> [zookeeper\_connect\_string](#output\_zookeeper\_connect\_string) | The connection string to use to connect to the Zookeeper cluster |
<!-- END_TF_DOCS -->