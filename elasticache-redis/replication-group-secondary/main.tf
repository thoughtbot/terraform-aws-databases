# Secondary (regional) member of an ElastiCache global datastore.
#
# When `global_replication_group_id` is set, AWS inherits engine,
# engine_version, node_type, encryption, parameter group, snapshots and the
# auth token from the global datastore's primary. The provider enforces this
# with ConflictsWith rules that fire whenever those attributes are *configured*
# at all -- even when set to null -- so this module simply omits them.
resource "aws_elasticache_replication_group" "this" {
  replication_group_id        = coalesce(var.replication_group_id, var.name)
  global_replication_group_id = var.global_replication_group_id

  apply_immediately          = var.apply_immediately
  automatic_failover_enabled = local.replica_enabled
  description                = var.description
  multi_az_enabled           = local.replica_enabled
  num_cache_clusters         = local.instance_count
  security_group_ids         = local.server_security_group_ids
  subnet_group_name          = aws_elasticache_subnet_group.this.name

  # Joining a global datastore whose primary has an auth token requires the
  # CreateReplicationGroup call to pass the matching token; it is not inherited
  # at creation time. transit_encryption_enabled is still inherited and must
  # not be set here. The token is read from the primary's rotated Secrets
  # Manager secret so it stays in sync after rotation.
  auth_token = local.auth_token

  lifecycle {
    ignore_changes = [
      # The token is rotated externally
      auth_token
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
    module.client_security_group[*].id
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
  threshold           = 90 / data.aws_ec2_instance_type.instance_attributes.default_cores
  treat_missing_data  = "notBreaching"

  dimensions = {
    CacheClusterId = local.instances[count.index]
  }

  alarm_actions = var.alarm_actions[*].arn
  ok_actions    = var.alarm_actions[*].arn
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

  alarm_actions = var.alarm_actions[*].arn
  ok_actions    = var.alarm_actions[*].arn
}

resource "aws_cloudwatch_metric_alarm" "check_cpu_balance" {
  count = data.aws_ec2_instance_type.instance_attributes.burstable_performance_supported == true ? local.instance_count : 0

  alarm_name          = "${var.name}-${count.index}-elasticache-low-cpu-credit"
  alarm_description   = "Insufficient CPU credits for ${var.name}-${count.index}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  threshold           = "0"
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_actions[*].arn
  ok_actions    = var.alarm_actions[*].arn

  metric_query {
    id          = "e1"
    expression  = "m1 - m2 - (m3 * 12)"
    label       = "Available CPU Credits"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "CPUCreditBalance"
      namespace   = "AWS/ElastiCache"
      period      = "120"
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        CacheClusterId = local.instances[count.index]
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "CPUSurplusCreditBalance"
      namespace   = "AWS/ElastiCache"
      period      = "120"
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        CacheClusterId = local.instances[count.index]
      }
    }
  }

  metric_query {
    id = "m3"

    metric {
      metric_name = "CPUCreditUsage"
      namespace   = "AWS/ElastiCache"
      period      = "120"
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        CacheClusterId = local.instances[count.index]
      }
    }
  }
}

# The node type is inherited from the global datastore primary and is not set
# on the replication group resource. It is still needed here to size the
# CloudWatch alarms, and must be known at plan time so the burstable-credit
# alarm's count can be evaluated, so it is taken as an input rather than read
# back off the (apply-time) resource attribute.
data "aws_ec2_instance_type" "instance_attributes" {
  instance_type = local.instance_size
}

# The auth token must match the global datastore primary. Read it from the
# primary's rotated Secrets Manager secret (replicated into this region) rather
# than passing the raw value, so the two stay in sync across rotations.
data "aws_secretsmanager_secret_version" "auth_token" {
  count     = var.auth_token_secret_name != null ? 1 : 0
  secret_id = var.auth_token_secret_name
}

locals {
  instance_count            = var.replica_count + 1
  instance_size             = replace(var.node_type, "cache.", "")
  instances                 = sort(aws_elasticache_replication_group.this.member_clusters)
  owned_security_group_ids  = module.server_security_group[*].id
  replica_enabled           = var.replica_count > 0
  shared_security_group_ids = var.server_security_group_ids

  memory_threshold_mb = data.aws_ec2_instance_type.instance_attributes.memory_size

  server_security_group_ids = concat(
    local.owned_security_group_ids,
    local.shared_security_group_ids
  )

  # Prefer the token read from the secret; fall back to a directly-supplied one.
  auth_token = (
    var.auth_token_secret_name != null ?
    jsondecode(data.aws_secretsmanager_secret_version.auth_token[0].secret_string)["token"] :
    var.auth_token
  )
}
