locals {
  # protocol = var.transit_encryption_enabled ? "rediss" : "redis"
  # address  = aws_elasticache_replication_group.this.primary_endpoint_address
  # auth = (
  #   var.transit_encryption_enabled ?
  #   ":${random_password.auth_token.result}@" :
  #   ""
  # )
  # redis_url = "${local.protocol}://${local.auth}${local.address}:${var.port}"
}

output "initial_auth_token" {
  description = "Initial value for the user auth token"
  value       = random_password.auth_token.result
}

output "instance" {
  description = "Elasticache Redis replication group"
  value       = aws_elasticache_replication_group.this
}

# output "redis_url" {
#   description = "URL for connecting to Redis"
#   value       = local.redis_url
# }

output "id" {
  description = "ID of the created replication group"
  value       = aws_elasticache_replication_group.this.replication_group_id
}

output "security_group_id" {
  description = "ID of the security group for this Redis instance"
  value       = module.security_group.instance.id
}
