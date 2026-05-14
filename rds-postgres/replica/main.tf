resource "aws_db_instance" "this" {
  allocated_storage               = var.allocated_storage
  apply_immediately               = var.apply_immediately
  db_subnet_group_name            = local.db_subnet_group_name
  identifier                      = var.identifier
  instance_class                  = var.instance_class
  kms_key_id                      = var.kms_key_id
  max_allocated_storage           = var.max_allocated_storage
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  parameter_group_name            = local.parameter_group_name
  performance_insights_enabled    = var.performance_insights_enabled
  publicly_accessible             = var.publicly_accessible
  region                          = var.replica_region
  replicate_source_db             = var.replicate_source_db
  skip_final_snapshot             = true
  storage_encrypted               = var.storage_encrypted
  tags                            = var.tags
  vpc_security_group_ids          = local.server_security_group_ids
  deletion_protection             = var.deletion_protection

  depends_on = [
    aws_db_subnet_group.this,
    module.parameter_group,
    module.server_security_group,
  ]
}

resource "aws_db_subnet_group" "this" {
  count = local.create_subnet_group ? 1 : 0
  name  = local.subnet_group_name

  description = "Postgres replica subnet group"
  region      = var.replica_region
  subnet_ids  = var.subnet_ids
  tags        = var.tags
}

module "alarms" {
  count  = var.create_cloudwatch_alarms ? 1 : 0
  source = "../cloudwatch-alarms"

  alarm_actions     = var.alarm_actions
  identifier        = aws_db_instance.this.identifier
  instance_class    = aws_db_instance.this.instance_class
  allocated_storage = var.allocated_storage
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
  description         = "RDS Postgres replica server: ${var.identifier}"
  name                = "${var.identifier}-server"
  ports = {
    postgres = 5432
  }
  randomize_name = true
  region         = var.replica_region
  tags           = var.tags
  vpc_id         = var.vpc_id
}

locals {
  owned_vpc_security_group_ids = module.server_security_group.*.id
  parameter_group_name = coalesce(
    var.parameter_group_name,
    var.identifier
  )
  create_subnet_group = (
    var.subnet_group_name == null &&
    length(var.subnet_ids) > 0
  )
  subnet_group_name = coalesce(
    var.subnet_group_name,
    var.identifier
  )
  db_subnet_group_name = (
    var.subnet_group_name != null || local.create_subnet_group ?
    local.subnet_group_name :
    null
  )
  server_security_group_ids = concat(
    local.owned_vpc_security_group_ids,
    var.vpc_security_group_ids
  )
}
