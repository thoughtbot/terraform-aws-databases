locals {
  username = aws_db_instance.this.username
  password = coalesce(var.initial_password, random_password.database.result)
}

output "admin_username" {
  description = "Admin username for connecting to this database"
  value       = local.username
}

output "default_database" {
  description = "Name of the default database, if created"
  value       = var.create_default_db ? var.default_database : null
}

output "host" {
  description = "The hostname to use when connecting to this database"
  value       = aws_db_instance.this.address
}

output "identifier" {
  description = "Identifier of the created RDS database"
  value       = aws_db_instance.this.identifier
}

output "initial_password" {
  description = "Initial admin password for connecting to this database"
  value       = local.password
}

output "instance" {
  description = "The created RDS database instance"
  value       = aws_db_instance.this
}