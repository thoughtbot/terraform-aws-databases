# Auth-token secret for a secondary (regional) member of an ElastiCache global
# datastore.
#
# A secondary never owns its auth token -- it always inherits the value from
# the global datastore's primary and cannot rotate it independently, so this
# module does not create a rotation function (unlike the auth-token module).
# It reads the primary's auth-token secret (already replicated into this
# region by the auth-token module's `replica_regions`), reuses its token, and
# writes a new secret scoped to this region with the secondary's own host and
# port.
module "secret" {
  source = "github.com/thoughtbot/terraform-aws-secrets//secret?ref=v0.9.1"

  admin_principals = var.admin_principals
  description      = "Redis auth token for: ${local.full_name}"
  name             = coalesce(var.secret_name, local.full_name)
  read_principals  = var.read_principals
  resource_tags    = var.tags
  trust_tags       = var.trust_tags
  replica_regions  = var.replica_regions

  initial_value = jsonencode({
    host  = data.aws_elasticache_replication_group.this.primary_endpoint_address
    token = local.auth_token
    port  = tostring(data.aws_elasticache_replication_group.this.port)
  })
}

data "aws_elasticache_replication_group" "this" {
  replication_group_id = var.replication_group_id
}

data "aws_secretsmanager_secret_version" "primary_auth_token" {
  secret_id = var.auth_token_secret_name
}

locals {
  full_name  = join("-", ["redis", var.replication_group_id])
  auth_token = jsondecode(data.aws_secretsmanager_secret_version.primary_auth_token.secret_string)["token"]
}
