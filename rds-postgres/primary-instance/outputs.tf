locals {
  username = aws_db_instance.this.username
  password = coalesce(var.initial_password, random_password.database.result)
}

output "admin_username" {
  description = "Admin username for connecting to this database"
  value       = local.username
}

output "initial_password" {
  description = "Initial admin password for connecting to this database"
  value       = local.password
}

output "instance" {
  description = "Primary RDS database instance"
  value       = aws_db_instance.this
}
