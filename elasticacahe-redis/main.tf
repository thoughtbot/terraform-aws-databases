locals {
  name            = join("-", distinct(concat(var.namespace, [var.name])))
  replica_enabled = var.replica_count > 0
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = coalesce(var.replication_group_id, local.name)

  at_rest_encryption_enabled    = var.at_rest_encryption_enabled
  automatic_failover_enabled    = local.replica_enabled
  engine                        = var.engine
  engine_version                = var.engine_version
  kms_key_id                    = var.kms_key == null ? null : var.kms_key.id
  multi_az_enabled              = local.replica_enabled
  node_type                     = var.node_type
  number_cache_clusters         = var.replica_count + 1
  parameter_group_name          = var.parameter_group_name
  port                          = var.port
  replication_group_description = var.description
  security_group_ids            = [module.security_group.instance.id]
  snapshot_retention_limit      = var.snapshot_retention_limit
  subnet_group_name             = aws_elasticache_subnet_group.this.name
  transit_encryption_enabled    = var.transit_encryption_enabled

  # Auth tokens aren't supported without TLS
  auth_token = (
    var.transit_encryption_enabled ?
    random_password.auth_token.result :
    null
  )

  lifecycle {
    # Minor upgrades will cause noise in diffs
    ignore_changes = [engine_version]
  }
}

resource "aws_elasticache_subnet_group" "this" {
  name = coalesce(
    var.subnet_group_name,
    var.replication_group_id,
    local.name
  )

  description = "Redis subnet group"
  subnet_ids  = values(var.subnets).*.id

  lifecycle {
    create_before_destroy = true
  }
}

module "security_group" {
  source = "../rds-security-group"

  allowed_cidr_blocks     = var.allowed_cidr_blocks
  allowed_security_groups = var.allowed_security_groups
  description             = "Redis security group"
  name                    = join("-", [var.name, "redis"])
  namespace               = var.namespace
  port                    = var.port
  tags                    = var.tags
  vpc                     = var.vpc
}

resource "aws_security_group_rule" "intracluster" {
  security_group_id = module.security_group.instance.id

  from_port = 0
  to_port   = 0
  protocol  = "-1"
  self      = true
  type      = "ingress"
}

resource "random_password" "auth_token" {
  keepers = {
    # Generate a new auth token if we create a new replication group
    replication_group_id = coalesce(var.replication_group_id, local.name)
  }

  length = 32

  # Redis does not allow certain characters in passwords
  special = false
}
