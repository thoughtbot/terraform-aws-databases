################################################################################
# Domain
################################################################################

output "domain_arn" {
  description = "The Amazon Resource Name (ARN) of the domain"
  value       = try(aws_opensearch_domain.this[0].arn, null)
}

output "domain_id" {
  description = "The unique identifier for the domain"
  value       = try(aws_opensearch_domain.this[0].domain_id, null)
}

output "domain_endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = try(aws_opensearch_domain.this[0].endpoint, null)
}

output "domain_dashboard_endpoint" {
  description = "Domain-specific endpoint for Dashboard without https scheme"
  value       = try(aws_opensearch_domain.this[0].dashboard_endpoint, null)
}

################################################################################
# Outbound Connections
################################################################################

output "outbound_connections" {
  description = "Map of outbound connections created and their attributes"
  value       = aws_opensearch_outbound_connection.this
}

################################################################################
# CloudWatch Log Groups
################################################################################

output "cloudwatch_logs" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = aws_cloudwatch_log_group.this
}

################################################################################
# Security Group
################################################################################

output "security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = try(aws_security_group.this[0].arn, null)
}

output "security_group_id" {
  description = "ID of the security group"
  value       = try(aws_security_group.this[0].id, null)
}

################################################################################
# Secret details
################################################################################

output "environment_variables" {
  description = "Environment variables set by this rotation function"
  value       = ["AWS_SEARCH_ENDPOINT", "AWS_SEARCH_DASHBOARD_ENDPOINT", "AWS_SEARCH_DOMAIN_ID", "AWS_SEARCH_PASSWORD", "AWS_SEARCH_USER_NAME"]
}

output "secret_name" {
  description = "Name of the secrets manager secret containing credentials"
  value       = module.elasticsearch_secret.name
}

output "policy_json" {
  description = "Required IAM policies"
  value       = module.elasticsearch_secret.policy_json
}

output "kms_key_arn" {
  description = "ID of the KMS key used to encrypt the secret"
  value       = module.elasticsearch_secret.kms_key_arn
}

output "secret_arn" {
  description = "ARN of the secrets manager secret containing credentials"
  value       = module.elasticsearch_secret.arn
}
