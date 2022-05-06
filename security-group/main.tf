resource "aws_security_group" "this" {
  description = var.description
  name        = local.full_name
  tags        = var.tags
  vpc_id      = var.vpc_id

  lifecycle {
    # Security groups cannot be deleted before they are attached. Terraform
    # usually detach old security groups until a new one is attached.
    create_before_destroy = true
  }
}

module "ingress" {
  for_each = var.ports
  source   = "../security-group-ingress"

  allowed_security_group_ids = var.allowed_security_group_ids
  allowed_cidr_blocks        = var.allowed_cidr_blocks
  description                = each.key
  port                       = each.value
  security_group_id          = aws_security_group.this.id
}

resource "aws_security_group_rule" "self" {
  description       = "Intracluster connectivity"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.this.id
  self              = true
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "egress" {
  count = var.allow_all_egress ? 1 : 0

  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all egress"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.this.id
  to_port           = 0
  type              = "egress"
}

resource "random_string" "name_suffix" {
  count = var.randomize_name ? 1 : 0

  length  = 6
  special = false

  keepers = {
    # Security groups cannot be renamed
    name = var.name

    # Security groups can't be moved between VPCs
    vpc_id = var.vpc_id
  }
}

locals {
  max_security_group_name_length = 255
  name_suffix                    = join("-", random_string.name_suffix.*.result)

  full_name = (
    var.randomize_name ?
    join("-", [
      substr(
        var.name,
        0,
        local.max_security_group_name_length - length(local.name_suffix)
      ),
      local.name_suffix
    ]) :
    var.name
  )
}
