resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "${var.name}-database-high-cpu"
  alarm_description   = "${var.name} is using more than 90% of its CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "90"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.name
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "disk" {
  alarm_name          = "${var.name}-database-disk-remaining"
  alarm_description   = "${var.name} has less than 10% of disk space remaining"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.allocated_storage * 1024 * 1024 * 1024 / 10
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.name
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  alarm_name          = "${var.name}-datababase-memory-remaining"
  alarm_description   = "${var.name} has less than ${local.memory_threshold_mb}MiB of memory remaining"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = local.memory_threshold_mb * 1024 * 1024
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.name
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
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
