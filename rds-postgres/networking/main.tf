resource "aws_db_subnet_group" "this" {
  name = coalesce(
    coalesce(
      var.subnet_group_name,
      var.name
    )
  )

  description = var.subnet_group_description
  subnet_ids  = var.subnet_ids
  tags        = var.tags
}

module "security_group" {
  source = "../../rds-security-group"

  name = coalesce(
    var.security_group_name,
    var.name
  )

  allowed_cidr_blocks     = var.allowed_cidr_blocks
  allowed_security_groups = var.allowed_security_groups
  tags                    = var.tags
  vpc_id                  = var.vpc_id
}
