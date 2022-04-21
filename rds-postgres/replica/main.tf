resource "aws_db_instance" "this" {
  allocated_storage            = var.allocated_storage
  apply_immediately            = var.apply_immediately
  db_subnet_group_name         = var.subnet_group_name
  identifier                   = var.identifier
  instance_class               = var.instance_class
  kms_key_id                   = var.kms_key_id
  max_allocated_storage        = var.max_allocated_storage
  parameter_group_name         = var.parameter_group_name
  performance_insights_enabled = var.performance_insights_enabled
  publicly_accessible          = var.publicly_accessible
  skip_final_snapshot          = true
  storage_encrypted            = var.storage_encrypted
  tags                         = var.tags
  vpc_security_group_ids       = var.vpc_security_group_ids

  name = (
    var.create_default_db ?
    var.default_database :
    null
  )

  replicate_source_db = var.replicate_source_db
}
