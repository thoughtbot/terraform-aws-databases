# RDS Postgres CloudWatch Alarms

Creates useful CloudWatch Alarms for an RDS Postgres database.

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

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.check_cpu_balance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.db_connections_limit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.disk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ec2_instance_type.instance_attributes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | SNS topic ARNs or other actions to invoke for alarms | `list(string)` | `[]` | no |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Size in GB for the database instance | `number` | n/a | yes |
| <a name="input_db_connections_limit_threshold"></a> [db\_connections\_limit\_threshold](#input\_db\_connections\_limit\_threshold) | The percentage threshold for number of database connections. Default: 80 | `number` | `80` | no |
| <a name="input_db_memory_threshold"></a> [db\_memory\_threshold](#input\_db\_memory\_threshold) | The percentage threshold of FreeableMemory left for the Database. Default: 20 | `number` | `20` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Identifier of the database to monitor | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Tier for the database instance to monitor | `string` | n/a | yes |
<!-- END_TF_DOCS -->
