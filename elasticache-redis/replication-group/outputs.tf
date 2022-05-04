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

output "security_group_id" {
  description = "ID of the security group for this Redis instance"
  value       = module.security_group.instance.id
}
