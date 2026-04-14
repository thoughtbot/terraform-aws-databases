resource "aws_elasticache_replication_group" "this" {
  replication_group_id = coalesce(var.replication_group_id, var.name)

  at_rest_encryption_enabled    = var.at_rest_encryption_enabled
  automatic_failover_enabled    = local.replica_enabled
  engine                        = var.engine
  engine_version                = var.engine_version
  kms_key_id                    = var.kms_key == null ? null : var.kms_key.id
  multi_az_enabled              = local.replica_enabled
  node_type                     = var.node_type
  num_cache_clusters            = local.instance_count
  parameter_group_name          = var.parameter_group_name
  port                          = var.port
  description                   = var.description
  security_group_ids            = local.server_security_group_ids
  snapshot_name                 = var.snapshot_name
  snapshot_retention_limit      = var.snapshot_retention_limit
  subnet_group_name             = aws_elasticache_subnet_group.this.name
  transit_encryption_enabled    = var.transit_encryption_enabled

  # Auth tokens aren't supported without TLS
  auth_token = (
    var.transit_encryption_enabled ?
    coalesce(var.initial_auth_token, random_password.auth_token.result) :
    null
  )

  lifecycle {
    ignore_changes = [
      # The token should be rotated externally
      auth_token,
      # Minor upgrades will cause noise in diffs
      engine_version
    ]
  }
}

resource "aws_elasticache_subnet_group" "this" {
  name = coalesce(
    var.subnet_group_name,
    var.replication_group_id,
    var.name
  )

  description = "Redis subnet group"
  subnet_ids  = var.subnet_ids

  lifecycle {
    create_before_destroy = true
  }
}

module "server_security_group" {
  count  = var.create_server_security_group ? 1 : 0
  source = "../../security-group"

  allowed_cidr_blocks = var.allowed_cidr_blocks
  description         = "ElastiCache Redis server: ${var.name}"
  randomize_name      = var.server_security_group_name == ""
  tags                = var.tags
  vpc_id              = var.vpc_id

  allowed_security_group_ids = concat(
    var.allowed_security_group_ids,
    module.client_security_group.*.id
  )

  name = coalesce(
    var.server_security_group_name,
    "${var.name}-server"
  )

  ports = {
    redis = var.port
  }
}

module "client_security_group" {
  count  = var.create_client_security_group ? 1 : 0
  source = "../../security-group"

  allowed_cidr_blocks        = var.allowed_cidr_blocks
  allowed_security_group_ids = var.allowed_security_group_ids
  description                = "ElastiCache Redis client: ${var.name}"
  randomize_name             = var.client_security_group_name == ""
  tags                       = var.tags
  vpc_id                     = var.vpc_id

  name = coalesce(
    var.client_security_group_name,
    "${var.name}-client"
  )
}

resource "random_password" "auth_token" {
  keepers = {
    # Generate a new auth token if we create a new replication group
    replication_group_id = coalesce(var.replication_group_id, var.name)
  }

  length = 32

  # Redis does not allow certain characters in passwords
  special = false
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  count = local.instance_count

  alarm_name          = "${var.name}-${count.index}-high-cpu"
  alarm_description   = "${var.name}-${count.index} is using more than 90% of its CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "60"
  statistic           = "Average"
  threshold           = "90"
  treat_missing_data  = "notBreaching"

  dimensions = {
    CacheClusterId = local.instances[count.index]
  }

  alarm_actions = var.alarm_actions.*.arn
  ok_actions    = var.alarm_actions.*.arn
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  count = local.instance_count

  alarm_name          = "${var.name}-${count.index}-datababase-memory-remaining"
  alarm_description   = "${var.name}-${count.index} has less than ${local.memory_threshold_mb}MiB of memory remaining"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = "60"
  statistic           = "Average"
  threshold           = local.memory_threshold_mb * 1024 * 1024
  treat_missing_data  = "notBreaching"

  dimensions = {
    CacheClusterId = local.instances[count.index]
  }

  alarm_actions = var.alarm_actions.*.arn
  ok_actions    = var.alarm_actions.*.arn
}

locals {
  instance_count            = var.replica_count + 1
  instance_size             = split(".", var.node_type)[2]
  instances                 = sort(aws_elasticache_replication_group.this.member_clusters)
  owned_security_group_ids  = module.server_security_group.*.id
  replica_enabled           = var.replica_count > 0
  shared_security_group_ids = var.server_security_group_ids

  instance_size_thresholds = {
    micro = 128
    small = 768
  }

  memory_threshold_mb = try(
    local.instance_size_thresholds[local.instance_size],
    1024
  )

  server_security_group_ids = concat(
    local.owned_security_group_ids,
    local.shared_security_group_ids
  )
}
