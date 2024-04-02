resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "${var.identifier}-database-high-cpu"
  alarm_description   = "${var.identifier} is using more than 90% of its CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "90"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.identifier
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "disk" {
  alarm_name          = "${var.identifier}-database-disk-remaining"
  alarm_description   = "${var.identifier} has less than 10% of disk space remaining"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeLocalStorage"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.allocated_storage * 1024 * 1024 * 1024 / 10
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.identifier
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  alarm_name          = "${var.identifier}-datababase-memory-remaining"
  alarm_description   = "${var.identifier} has less than ${local.memory_threshold_mb}MiB of memory remaining"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = local.memory_threshold_mb * 1024 * 1024
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.identifier
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "check_cpu_balance" {
  count = data.aws_ec2_instance_type.instance_attributes.burstable_performance_supported == true ? 1 : 0

  alarm_name          = "${var.identifier}-datababase-low-cpu-credit"
  alarm_description   = "Insufficient CPU credits for ${var.identifier}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  threshold           = "0"
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions

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
      namespace   = "AWS/RDS"
      period      = "120"
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        DBInstanceIdentifier = var.identifier
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "CPUSurplusCreditBalance"
      namespace   = "AWS/RDS"
      period      = "120"
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        DBInstanceIdentifier = var.identifier
      }
    }
  }

  metric_query {
    id = "m3"

    metric {
      metric_name = "CPUCreditUsage"
      namespace   = "AWS/RDS"
      period      = "120"
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        DBInstanceIdentifier = var.identifier
      }
    }
  }

}

resource "aws_cloudwatch_metric_alarm" "db_connections_limit" {
  alarm_name          = "${var.identifier}-database-connections-limit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = local.db_connections_limit_threshold
  alarm_description   = "Average database connections amount reached ${var.db_connections_limit_threshold} percent of the limit, may cause connection disruption"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = var.identifier
  }
}

data "aws_ec2_instance_type" "instance_attributes" {
  instance_type = local.instance_type
}

locals {
  instance_type       = replace(var.instance_class, "db.", "")
  memory_threshold_mb = data.aws_ec2_instance_type.instance_attributes.memory_size * var.db_memory_threshold * 0.01

  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html#RDS_Limits.MaxConnections
  postgres_divisor               = 9531392
  max_connections_limit          = (data.aws_ec2_instance_type.instance_attributes.memory_size * 1048576) / local.postgres_divisor
  db_connections_limit_threshold = min(floor((local.max_connections_limit / 100) * var.db_connections_limit_threshold), 5000)
}
