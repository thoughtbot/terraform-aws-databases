output "connector" {
  description = "The created MSK Connect connector resource."
  value       = aws_mskconnect_connector.this
}

output "connector_arn" {
  description = "ARN of the created MSK Connect connector."
  value       = aws_mskconnect_connector.this.arn
}

output "connector_name" {
  description = "Name of the created MSK Connect connector."
  value       = aws_mskconnect_connector.this.name
}

output "custom_plugin_arn" {
  description = "ARN of the MSK Connect custom plugin used by the connector."
  value       = data.aws_mskconnect_custom_plugin.this.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group receiving connector worker logs."
  value       = aws_cloudwatch_log_group.this.name
}

output "service_execution_role_arn" {
  description = "ARN of the IAM role assumed by MSK Connect."
  value       = aws_iam_role.this.arn
}

output "worker_configuration_arn" {
  description = "ARN of the worker configuration attached to the connector."
  value       = aws_mskconnect_worker_configuration.this.arn
}
