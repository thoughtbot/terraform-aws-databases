module "secret" {
  source = "github.com/thoughtbot/terraform-aws-secrets//secret?ref=v0.8.0"

  admin_principals = var.admin_principals
  description      = "Redis auth token for: ${local.full_name}"
  name             = coalesce(var.secret_name, local.full_name)
  read_principals  = var.read_principals
  resource_tags    = var.tags
  trust_tags       = var.trust_tags

  initial_value = jsonencode({
    host  = data.aws_elasticache_replication_group.this.primary_endpoint_address
    token = var.initial_auth_token
    port  = tostring(data.aws_elasticache_replication_group.this.port)
  })
}

module "rotation" {
  source = "github.com/thoughtbot/terraform-aws-secrets//secret-rotation-function?ref=v0.8.0"

  handler     = "lambda_function.lambda_handler"
  role_arn    = module.secret.rotation_role_arn
  runtime     = "python3.8"
  secret_arn  = module.secret.arn
  source_file = "${path.module}/rotation/lambda_function.py"
  subnet_ids  = var.subnet_ids

  dependencies = {
    redis = "${path.module}/rotation/redis.zip"
  }

  security_group_ids = concat(
    var.security_group_ids,
    [module.security_group.id]
  )

  variables = {
    REPLICATION_GROUP_ID = data.aws_elasticache_replication_group.this.replication_group_id
  }
}

module "security_group" {
  source = "../../security-group"

  allow_all_egress = true
  description      = "Security group for rotating ${local.full_name}"
  name             = "${local.full_name}-rotation"
  tags             = var.tags
  vpc_id           = var.vpc_id
}

resource "aws_iam_role_policy_attachment" "access_admin_login" {
  policy_arn = aws_iam_policy.describe_database.arn
  role       = module.secret.rotation_role_name
}

resource "aws_iam_policy" "describe_database" {
  name   = local.full_name
  policy = data.aws_iam_policy_document.describe_database.json
}

data "aws_iam_policy_document" "describe_database" {
  statement {
    sid = "DescribeDatabase"
    actions = [
      "elasticache:ModifyReplicationGroup"
    ]
    resources = [data.aws_elasticache_replication_group.this.arn]
  }
}

data "aws_elasticache_replication_group" "this" {
  replication_group_id = var.replication_group_id
}

locals {
  full_name = join("-", ["redis", var.replication_group_id])
}
