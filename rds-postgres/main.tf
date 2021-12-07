locals {
  version_components = split(".", var.engine_version)
  postgres_family = join(
    "",
    [
      "postgres",
      (
        local.version_components[0] == "9" ?
        join(".", [local.version_components[0], local.version_components[1]]) :
        local.version_components[0]
      )
    ]
  )
}

resource "aws_db_instance" "this" {
  for_each = toset(concat([var.name], var.replica_names))

  # Common attributes

  allocated_storage            = var.allocated_storage
  apply_immediately            = var.apply_immediately
  instance_class               = var.instance_class
  kms_key_id                   = var.kms_key == null ? null : var.kms_key.arn
  max_allocated_storage        = var.max_allocated_storage
  parameter_group_name         = aws_db_parameter_group.this.name
  performance_insights_enabled = var.performance_insights_enabled
  publicly_accessible          = var.publicly_accessible
  skip_final_snapshot          = each.key == var.name
  storage_encrypted            = var.storage_encrypted
  tags                         = var.tags
  vpc_security_group_ids       = [module.security_group.instance.id]

  identifier = lookup(
    var.identifiers,
    each.key,
    join("-", distinct(concat(var.namespace, [each.value])))
  )

  name = (
    var.create_default_db ?
    var.default_database :
    null
  )

  # Primary attributes

  auto_minor_version_upgrade = (
    each.key == var.name ?
    var.auto_minor_version_upgrade :
    null
  )

  backup_retention_period = (
    each.key == var.name ?
    var.backup_retention_period :
    null
  )

  backup_window = (
    each.key == var.name ?
    var.backup_window :
    null
  )

  db_subnet_group_name = (
    each.key == var.name ?
    aws_db_subnet_group.database.name :
    null
  )

  engine = (
    each.key == var.name ?
    var.engine :
    null
  )

  engine_version = (
    each.key == var.name ?
    var.engine_version :
    null
  )

  final_snapshot_identifier = (
    each.key == var.name ?
    join(
      "-",
      concat(var.namespace, [var.name, random_id.snapshot_suffix.hex, "final"])
    ) :
    null
  )

  maintenance_window = (
    each.key == var.name ?
    var.maintenance_window :
    null
  )

  multi_az = (
    each.key == var.name ?
    var.multi_az :
    null
  )

  password = (
    each.key == var.name ?
    coalesce(var.initial_password, random_password.database.result) :
    null
  )

  username = (
    each.key == var.name ?
    var.admin_username :
    null
  )

  # Replica attributes

  replicate_source_db = (
    each.key == var.name ?
    null :
    lookup(
      var.identifiers,
      var.name,
      join("-", distinct(concat(var.namespace, [var.name])))
    )
  )

  lifecycle {
    ignore_changes = [password]
  }
}

resource "aws_db_parameter_group" "this" {
  name   = join("-", distinct(concat(var.namespace, [var.name])))
  family = local.postgres_family
  tags   = var.tags

  parameter {
    name  = "rds.force_ssl"
    value = var.force_ssl ? "1" : "0"
  }
}

locals {
  instances = toset(values(aws_db_instance.this).*.identifier)
}

resource "random_id" "snapshot_suffix" {
  byte_length = 4
}

resource "random_password" "database" {
  length  = 128
  special = false
}

resource "aws_db_subnet_group" "database" {
  name = coalesce(
    coalesce(
      var.subnet_group_name,
      join("-", distinct(concat(var.namespace, [var.name])))
    )
  )

  description = "Postgres subnet group"
  subnet_ids  = var.subnet_ids
  tags        = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

module "security_group" {
  source = "../rds-security-group"

  name = join("-", [
    coalesce(
      var.security_group_name,
      var.name
    ),
    "postgres"
  ])

  allowed_cidr_blocks     = var.allowed_cidr_blocks
  allowed_security_groups = var.allowed_security_groups
  namespace               = var.namespace
  tags                    = var.tags
  vpc                     = var.vpc
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  for_each = local.instances

  alarm_name          = "${each.value}-database-high-cpu"
  alarm_description   = "${each.value} is using more than 90% of its CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "90"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = each.value
  }

  alarm_actions = var.alarm_actions.*.arn
  ok_actions    = var.alarm_actions.*.arn
}

resource "aws_cloudwatch_metric_alarm" "disk" {
  for_each = local.instances

  alarm_name          = "${each.value}-database-disk-remaining"
  alarm_description   = "${each.value} has less than 10% of disk space remaining"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.allocated_storage * 1024 * 1024 * 1024 / 10
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = each.value
  }

  alarm_actions = var.alarm_actions.*.arn
  ok_actions    = var.alarm_actions.*.arn
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  for_each = local.instances

  alarm_name          = "${each.value}-datababase-memory-remaining"
  alarm_description   = "${each.value} has less than ${local.memory_threshold_mb}MiB of memory remaining"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = local.memory_threshold_mb * 1024 * 1024
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = each.value
  }

  alarm_actions = var.alarm_actions.*.arn
  ok_actions    = var.alarm_actions.*.arn
}

locals {
  instance_size = split(".", var.instance_class)[2]
  instance_size_thresholds = {
    micro  = 128
    small  = 256
    medium = 512
  }
  memory_threshold_mb = try(
    local.instance_size_thresholds[local.instance_size],
    1024
  )
}
