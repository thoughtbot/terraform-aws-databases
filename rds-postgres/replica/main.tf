resource "aws_db_instance" "this" {
  allocated_storage            = var.allocated_storage
  apply_immediately            = var.apply_immediately
  ca_cert_identifier           = var.ca_cert_id
  db_subnet_group_name         = var.subnet_group_name
  identifier                   = var.identifier
  instance_class               = var.instance_class
  kms_key_id                   = var.kms_key_id
  max_allocated_storage        = var.max_allocated_storage
  parameter_group_name         = local.parameter_group_name
  performance_insights_enabled = var.performance_insights_enabled
  publicly_accessible          = var.publicly_accessible
  replicate_source_db          = var.replicate_source_db
  skip_final_snapshot          = true
  storage_encrypted            = var.storage_encrypted
  tags                         = var.tags
  vpc_security_group_ids       = var.vpc_security_group_ids

  depends_on = [module.parameter_group]
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

locals {
  parameter_group_name = coalesce(
    var.parameter_group_name,
    var.identifier
  )
}
