locals {
  username = aws_rds_cluster.this.master_username
  password = coalesce(var.initial_password, random_password.database.result)
}

output "admin_username" {
  description = "Admin username for connecting to this DB cluster"
  value       = local.username
}

output "client_security_group_id" {
  description = "Name of the security group created for clients"
  value       = join("", module.client_security_group.*.id)
}

output "default_database" {
  description = "Name of the default database, if created"
  value       = var.create_default_db ? var.default_database : null
}

output "host" {
  description = "The hostname to use when connecting to this cluster"
  value       = aws_rds_cluster.this.endpoint
}

output "cluster_identifier" {
  description = "Identifier of the created Aurora cluster"
  value       = aws_rds_cluster.this.cluster_identifier
}

output "initial_password" {
  description = "Initial admin password for connecting to this database"
  value       = local.password
}

output "primary_kms_key" {
  description = "KMS key arn in use by primary database instance."
  value       = local.primary_kms_key
}

output "server_security_group_id" {
  description = "Name of the security group created for the server"
  value       = join("", module.server_security_group.*.id)
}
