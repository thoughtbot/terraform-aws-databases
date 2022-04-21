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
  allocated_storage            = var.allocated_storage
  apply_immediately            = var.apply_immediately
  identifier                   = var.name
  instance_class               = var.instance_class
  kms_key_id                   = var.kms_key == null ? null : var.kms_key.arn
  max_allocated_storage        = var.max_allocated_storage
  parameter_group_name         = aws_db_parameter_group.this.name
  performance_insights_enabled = var.performance_insights_enabled
  publicly_accessible          = var.publicly_accessible
  skip_final_snapshot          = var.replicate_source_db == null
  storage_encrypted            = var.storage_encrypted
  tags                         = var.tags
  vpc_security_group_ids       = var.vpc_security_group_ids

  name = (
    var.create_default_db ?
    var.default_database :
    null
  )

  # Primary attributes

  auto_minor_version_upgrade = (
    var.replicate_source_db == null ?
    var.auto_minor_version_upgrade :
    null
  )

  backup_retention_period = (
    var.replicate_source_db == null ?
    var.backup_retention_period :
    null
  )

  backup_window = (
    var.replicate_source_db == null ?
    var.backup_window :
    null
  )

  db_subnet_group_name = (
    var.replicate_source_db == null ?
    var.db_subnet_group_name :
    null
  )

  engine = (
    var.replicate_source_db == null ?
    var.engine :
    null
  )

  engine_version = (
    var.replicate_source_db == null ?
    var.engine_version :
    null
  )

  final_snapshot_identifier = (
    var.replicate_source_db == null ?
    join(
      "-",
      [var.name, random_id.snapshot_suffix.hex, "final"]
    ) :
    null
  )

  maintenance_window = (
    var.replicate_source_db == null ?
    var.maintenance_window :
    null
  )

  multi_az = (
    var.replicate_source_db == null ?
    var.multi_az :
    null
  )

  password = (
    var.replicate_source_db == null ?
    coalesce(var.initial_password, random_password.database.result) :
    null
  )

  username = (
    var.replicate_source_db == null ?
    var.admin_username :
    null
  )

  lifecycle {
    ignore_changes = [password]
  }
}

resource "aws_db_parameter_group" "this" {
  name   = var.name
  family = local.postgres_family
  tags   = var.tags

  parameter {
    name  = "rds.force_ssl"
    value = var.force_ssl ? "1" : "0"
  }
}

resource "random_id" "snapshot_suffix" {
  byte_length = 4
}

resource "random_password" "database" {
  length  = 128
  special = false
}
