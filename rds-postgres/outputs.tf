locals {
  primary   = aws_db_instance.this[var.name]
  username  = local.primary.username
  password  = coalesce(var.password, random_password.database.result)
  auth      = "${local.username}:${local.password}"
  endpoint  = local.primary.endpoint
  name      = local.primary.name
  endpoints = values(aws_db_instance.this).*.endpoint
}

output "alarms" {
  description = "CloudWatch alarms for monitoring this database"
  value = {
    cpu    = aws_cloudwatch_metric_alarm.cpu
    disk   = aws_cloudwatch_metric_alarm.disk
    memory = aws_cloudwatch_metric_alarm.memory
  }
}

output "password" {
  description = "Password for connecting to this database"
  value       = local.password
}

output "primary" {
  description = "Primary RDS database instance"
  value       = local.primary
}

output "primary_database_url" {
  description = "URL with all details for connecting to primary database"
  value       = "postgres://${local.auth}@${local.endpoint}/${local.name}"
}

output "database_urls" {
  description = "URL with all details for connecting to all instances"
  value = [
    for endpoint in local.endpoints :
    "postgres://${local.auth}@${endpoint}/${local.name}"
  ]
}

output "policies" {
  description = "Required IAM policies"
  value       = []
}

output "secret_data" {
  description = "Kubernetes secret data"

  value = merge(
    {
      DATABASE_URL = "postgres://${local.auth}@${local.endpoint}/${local.name}"
    },
    zipmap(
      keys(aws_db_instance.this),
      [
        for instance in values(aws_db_instance.this) :
        "postgres://${local.auth}@${instance.endpoint}/${local.name}"
      ]
    )
  )
}

output "security_group" {
  description = "Security group for this database instance"
  value       = module.security_group.instance
}
