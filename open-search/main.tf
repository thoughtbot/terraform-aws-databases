locals {
  kms_key_id = var.kms_key_id == null ? module.kms_key.kms_key_arn : var.kms_key_id

  # We can't have more subnets than nodes
  subnets = slice(
    var.subnet_ids,
    0,
    min(length(var.subnet_ids), var.instance_count)
  )

  zone_awareness_enabled = length(local.subnets) > 1
}

resource "aws_opensearch_domain" "this" {
  domain_name    = var.domain_name
  engine_version = var.engine_version
  tags           = var.tags

  advanced_options = merge(
    # This is the default, but Terraform provides a perpetual diff if this
    # option is left unset.
    { "rest.action.multi.allow_explicit_index" = "true" },
    var.advanced_options
  )

  cluster_config {
    instance_type          = var.instance_type
    instance_count         = var.instance_count
    zone_awareness_enabled = local.zone_awareness_enabled

    dynamic "zone_awareness_config" {
      for_each = local.zone_awareness_enabled ? [true] : []

      content {
        availability_zone_count = length(local.subnets)
      }
    }
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = var.tls_security_policy
  }

  ebs_options {
    ebs_enabled = true
    iops        = var.ebs_volume_iops
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  encrypt_at_rest {
    enabled    = var.encrypt_at_rest
    kms_key_id = var.kms_key_id
  }

  node_to_node_encryption {
    enabled = true
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  vpc_options {
    subnet_ids         = local.subnets
    security_group_ids = [aws_security_group.this.id]
  }
}

resource "aws_opensearch_domain_policy" "es_access_policy" {
  access_policies = data.aws_iam_policy_document.es_access_policy.json
  domain_name     = aws_opensearch_domain.this.domain_name
}

resource "aws_security_group" "this" {
  name        = coalesce(var.security_group_name, var.domain_name)
  description = "Security group for OpenSearch domain: ${var.domain_name}"
  tags        = var.tags
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  cidr_blocks       = var.allowed_cidr_blocks
  description       = "Allow TLS traffic to the cluster"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  to_port           = 443
  type              = "ingress"
}

module "kms_key" {
  source = "github.com/thoughtbot/terraform-aws-secrets//customer-managed-kms?ref=v0.7.0"

  name = "opensearch-${var.domain_name}"
}

data "aws_iam_policy_document" "es_access_policy" {
  statement {
    actions = [
      "es:*",
    ]

    resources = [
      aws_opensearch_domain.this.arn,
      "${aws_opensearch_domain.this.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = distinct(compact(var.admin_principals))
    }
  }
}
