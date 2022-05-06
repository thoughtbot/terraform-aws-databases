output "client_security_group_id" {
  description = "Name of the security group created for clients"
  value       = join("", module.client_security_group.*.id)
}

output "initial_auth_token" {
  description = "Initial value for the user auth token"
  value       = random_password.auth_token.result
}

output "instance" {
  description = "Elasticache Redis replication group"
  value       = aws_elasticache_replication_group.this
}

output "id" {
  description = "ID of the created replication group"
  value       = aws_elasticache_replication_group.this.replication_group_id
}

output "server_security_group_id" {
  description = "Name of the security group created for the server"
  value       = join("", module.server_security_group.*.id)
}
