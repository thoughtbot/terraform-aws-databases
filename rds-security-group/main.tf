resource "aws_security_group" "this" {
  description = var.description
  name        = var.name
  tags        = var.tags
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count = length(var.allowed_security_group_ids)

  security_group_id = aws_security_group.this.id

  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_security_group_ids, count.index)
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count = length(var.allowed_cidr_blocks) == 0 ? 0 : 1

  security_group_id = aws_security_group.this.id

  cidr_blocks = var.allowed_cidr_blocks
  from_port   = var.port
  to_port     = var.port
  protocol    = "tcp"
  type        = "ingress"
}

resource "aws_security_group_rule" "egress_security_groups" {
  count = length(var.allowed_security_group_ids)

  security_group_id = aws_security_group.this.id

  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_security_group_ids, count.index)
  type                     = "egress"
}

resource "aws_security_group_rule" "egress_cidr_blocks" {
  count = length(var.allowed_cidr_blocks) == 0 ? 0 : 1

  security_group_id = aws_security_group.this.id

  cidr_blocks = var.allowed_cidr_blocks
  from_port   = var.port
  to_port     = var.port
  protocol    = "tcp"
  type        = "egress"
}
