resource "aws_security_group_rule" "ingress_security_groups" {
  count = length(var.allowed_security_group_ids)

  description              = var.description
  from_port                = var.port
  protocol                 = "tcp"
  security_group_id        = var.security_group_id
  source_security_group_id = var.allowed_security_group_ids[count.index]
  to_port                  = var.port
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count = length(var.allowed_cidr_blocks) == 0 ? 0 : 1

  cidr_blocks       = var.allowed_cidr_blocks
  description       = var.description
  from_port         = var.port
  protocol          = "tcp"
  security_group_id = var.security_group_id
  to_port           = var.port
  type              = "ingress"
}
