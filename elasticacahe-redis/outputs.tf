locals {
  protocol = var.transit_encryption_enabled ? "rediss" : "redis"
  address  = aws_elasticache_replication_group.this.primary_endpoint_address
  auth = (
    var.transit_encryption_enabled ?
    ":${random_password.auth_token.result}@" :
    ""
  )
  redis_url = "${local.protocol}://${local.auth}${local.address}:${var.port}"
}

output "instance" {
  description = "Elasticache Redis replication group"
  value       = aws_elasticache_replication_group.this
}

output "redis_url" {
  description = "URL for connecting to Redis"
  value       = local.redis_url
}

output "security_group" {
  description = "Security group for this Redis instance"
  value       = module.security_group.instance
}

output "policies" {
  description = "Required IAM policies"
  value       = []
}

output "secret_data" {
  description = "Kubernetes secret data"
  value       = { REDIS_URL = local.redis_url }
}
