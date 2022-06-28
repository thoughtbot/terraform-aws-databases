resource "aws_db_instance" "this" {
  allocated_storage            = var.allocated_storage
  apply_immediately            = var.apply_immediately
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  backup_retention_period      = var.backup_retention_period
  backup_window                = var.backup_window
  db_subnet_group_name         = local.subnet_group_name
  engine                       = var.engine
  engine_version               = var.engine_version
  identifier                   = var.identifier
  instance_class               = var.instance_class
  iops                         = var.iops
  kms_key_id                   = var.kms_key_id
  maintenance_window           = var.maintenance_window
  max_allocated_storage        = var.max_allocated_storage
  multi_az                     = var.multi_az
  parameter_group_name         = local.parameter_group_name
  performance_insights_enabled = var.performance_insights_enabled
  publicly_accessible          = var.publicly_accessible
  skip_final_snapshot          = var.skip_final_snapshot
  snapshot_identifier          = var.snapshot_identifier
  storage_encrypted            = var.storage_encrypted
  storage_type                 = var.storage_type
  tags                         = var.tags
  username                     = var.admin_username
  vpc_security_group_ids       = local.server_security_group_ids

  final_snapshot_identifier = join(
    "-",
    [var.identifier, random_id.snapshot_suffix.hex, "final"]
  )

  name = (
    var.create_default_db ?
    var.default_database :
    null
  )

  password = coalesce(var.initial_password, random_password.database.result)

  depends_on = [
    aws_db_subnet_group.this,
    module.parameter_group,
    module.server_security_group,
  ]

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

module "parameter_group" {
  count  = var.create_parameter_group ? 1 : 0
  source = "../parameter-group"

  engine_version = var.engine_version
  force_ssl      = var.force_ssl
  name           = local.parameter_group_name
  tags           = var.tags
}

module "server_security_group" {
  count  = var.create_server_security_group ? 1 : 0
  source = "../../security-group"

  allowed_cidr_blocks = var.allowed_cidr_blocks
  description         = "RDS Postgres server: ${var.identifier}"
  randomize_name      = var.server_security_group_name == ""
  tags                = var.tags
  vpc_id              = var.vpc_id

  allowed_security_group_ids = concat(
    var.allowed_security_group_ids,
    module.client_security_group.*.id
  )

  name = coalesce(
    var.server_security_group_name,
    "${var.identifier}-server"
  )

  ports = {
    postgres = 5432
  }
}

module "client_security_group" {
  count  = var.create_client_security_group ? 1 : 0
  source = "../../security-group"

  allowed_cidr_blocks        = var.allowed_cidr_blocks
  allowed_security_group_ids = var.allowed_security_group_ids
  description                = "RDS Postgres client: ${var.identifier}"
  randomize_name             = var.client_security_group_name == ""
  tags                       = var.tags
  vpc_id                     = var.vpc_id

  name = coalesce(
    var.client_security_group_name,
    "${var.identifier}-client"
  )
}

module "alarms" {
  count  = var.create_cloudwatch_alarms ? 1 : 0
  source = "../cloudwatch-alarms"

  alarm_actions     = var.alarm_actions
  identifier        = aws_db_instance.this.identifier
  instance_class    = aws_db_instance.this.instance_class
  allocated_storage = var.allocated_storage
}

resource "aws_db_subnet_group" "this" {
  count = var.create_subnet_group ? 1 : 0
  name  = local.subnet_group_name

  description = var.subnet_group_description
  subnet_ids  = var.subnet_ids
  tags        = var.tags
}

locals {
  owned_vpc_security_group_ids  = module.server_security_group.*.id
  shared_vpc_security_group_ids = var.server_security_group_ids

  parameter_group_name = coalesce(
    var.parameter_group_name,
    var.identifier
  )

  subnet_group_name = coalesce(
    var.subnet_group_name,
    var.identifier
  )

  server_security_group_ids = concat(
    local.owned_vpc_security_group_ids,
    local.shared_vpc_security_group_ids
  )
}
