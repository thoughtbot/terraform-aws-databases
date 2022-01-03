locals {
  primary  = aws_db_instance.this[var.name]
  username = local.primary.username
  password = coalesce(var.initial_password, random_password.database.result)
}

output "admin_username" {
  description = "Admin username for connecting to this database"
  value       = local.username
}

output "alarms" {
  description = "CloudWatch alarms for monitoring this database"
  value = {
    cpu    = aws_cloudwatch_metric_alarm.cpu
    disk   = aws_cloudwatch_metric_alarm.disk
    memory = aws_cloudwatch_metric_alarm.memory
  }
}

output "initial_password" {
  description = "Initial admin password for connecting to this database"
  value       = local.password
}

output "primary" {
  description = "Primary RDS database instance"
  value       = local.primary
}

output "security_group" {
  description = "Security group for this database instance"
  value       = module.security_group.instance
}
