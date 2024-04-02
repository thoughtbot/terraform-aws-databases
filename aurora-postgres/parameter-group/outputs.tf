output "engine_version" {
  description = "Version of Postgres used by this configuration"
  value       = var.engine_version
}

output "parameter_group_name" {
  description = "Name of the created parameter group"
  value       = aws_db_parameter_group.this.name
}
