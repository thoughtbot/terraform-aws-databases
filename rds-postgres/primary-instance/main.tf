resource "aws_db_instance" "this" {
  allocated_storage            = var.allocated_storage
  apply_immediately            = var.apply_immediately
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  backup_retention_period      = var.backup_retention_period
  backup_window                = var.backup_window
  db_subnet_group_name         = var.subnet_group_name
  engine                       = var.engine
  engine_version               = var.engine_version
  identifier                   = var.name
  instance_class               = var.instance_class
  kms_key_id                   = var.kms_key_id
  maintenance_window           = var.maintenance_window
  max_allocated_storage        = var.max_allocated_storage
  multi_az                     = var.multi_az
  parameter_group_name         = var.parameter_group_name
  performance_insights_enabled = var.performance_insights_enabled
  publicly_accessible          = var.publicly_accessible
  skip_final_snapshot          = var.skip_final_snapshot
  storage_encrypted            = var.storage_encrypted
  tags                         = var.tags
  username                     = var.admin_username
  vpc_security_group_ids       = var.vpc_security_group_ids

  final_snapshot_identifier = join(
    "-",
    [var.name, random_id.snapshot_suffix.hex, "final"]
  )

  name = (
    var.create_default_db ?
    var.default_database :
    null
  )

  password = coalesce(var.initial_password, random_password.database.result)

  lifecycle {
    ignore_changes = [password]
  }
}

resource "random_id" "snapshot_suffix" {
  byte_length = 4
}

resource "random_password" "database" {
  length  = 128
  special = false
}
