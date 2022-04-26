resource "aws_elasticache_replication_group" "this" {
  replication_group_id = coalesce(var.replication_group_id, local.name)

  at_rest_encryption_enabled    = var.at_rest_encryption_enabled
  automatic_failover_enabled    = local.replica_enabled
  engine                        = var.engine
  engine_version                = var.engine_version
  kms_key_id                    = var.kms_key == null ? null : var.kms_key.id
  multi_az_enabled              = local.replica_enabled
  node_type                     = var.node_type
  number_cache_clusters         = local.instance_count
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
  subnet_ids  = var.subnet_ids

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

resource "aws_cloudwatch_metric_alarm" "cpu" {
  count = local.instance_count

  alarm_name          = "${local.name}-${count.index}-high-cpu"
  alarm_description   = "${local.name}-${count.index} is using more than 90% of its CPU"
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

  alarm_name          = "${local.name}-${count.index}-datababase-memory-remaining"
  alarm_description   = "${local.name}-${count.index} has less than ${local.memory_threshold_mb}MiB of memory remaining"
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
  instance_count  = var.replica_count + 1
  instances       = sort(aws_elasticache_replication_group.this.member_clusters)
  instance_size   = split(".", var.node_type)[2]
  name            = join("-", distinct(concat(var.namespace, [var.name])))
  replica_enabled = var.replica_count > 0

  instance_size_thresholds = {
    micro = 128
    small = 768
  }

  memory_threshold_mb = try(
    local.instance_size_thresholds[local.instance_size],
    1024
  )
}
