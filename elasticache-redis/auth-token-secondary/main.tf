# Auth-token secret for a secondary (regional) member of an ElastiCache global
# datastore.
#
# A secondary never owns its auth token -- it always inherits the value from
# the global datastore's primary and cannot rotate it via the ElastiCache API
# (unlike the auth-token module, which calls ModifyReplicationGroup). Instead,
# the rotation function here reads the primary's current token straight out
# of its Secrets Manager secret (as replicated into this region by the
# auth-token module's `replica_regions`) and republishes it under this
# region's own host/port.
module "secret" {
  source = "github.com/thoughtbot/terraform-aws-secrets//secret?ref=v0.9.1"

  admin_principals = var.admin_principals
  description      = "Redis auth token for: ${local.full_name}"
  name             = coalesce(var.secret_name, local.full_name)
  read_principals  = var.read_principals
  resource_tags    = var.tags
  trust_tags       = var.trust_tags
  replica_regions  = var.replica_regions

  initial_value = jsonencode({
    host  = data.aws_elasticache_replication_group.this.primary_endpoint_address
    token = local.auth_token
    port  = tostring(data.aws_elasticache_replication_group.this.port)
  })
}

module "rotation" {
  source = "github.com/thoughtbot/terraform-aws-secrets//secret-rotation-function?ref=v0.9.1"

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
    PRIMARY_AUTH_TOKEN_SECRET_ARN = data.aws_secretsmanager_secret_version.primary_auth_token.secret_arn
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

# The rotation function only needs to read this region's replica of the
# primary's auth-token secret; module.secret already grants it read/write on
# its own secret.
resource "aws_iam_role_policy_attachment" "read_primary_auth_token" {
  policy_arn = aws_iam_policy.read_primary_auth_token.arn
  role       = module.secret.rotation_role_name
}

resource "aws_iam_policy" "read_primary_auth_token" {
  name   = local.full_name
  policy = data.aws_iam_policy_document.read_primary_auth_token.json
}

data "aws_iam_policy_document" "read_primary_auth_token" {
  statement {
    sid = "ReadPrimaryAuthToken"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
    ]
    resources = [data.aws_secretsmanager_secret_version.primary_auth_token.secret_arn]
  }

  statement {
    sid       = "DecryptPrimaryAuthToken"
    actions   = ["kms:Decrypt"]
    resources = [data.aws_kms_key.primary_auth_token.arn]
  }
}

data "aws_elasticache_replication_group" "this" {
  replication_group_id = var.replication_group_id
}

# Resolved through this region's provider, so this is the local replica of
# the primary's secret -- both the ARN and the value are region-scoped.
data "aws_secretsmanager_secret_version" "primary_auth_token" {
  secret_id = var.auth_token_secret_name
}

data "aws_secretsmanager_secret" "primary_auth_token" {
  arn = data.aws_secretsmanager_secret_version.primary_auth_token.secret_arn
}

data "aws_kms_key" "primary_auth_token" {
  key_id = data.aws_secretsmanager_secret.primary_auth_token.kms_key_id
}

locals {
  full_name  = join("-", ["redis", var.replication_group_id])
  auth_token = jsondecode(data.aws_secretsmanager_secret_version.primary_auth_token.secret_string)["token"]
}
