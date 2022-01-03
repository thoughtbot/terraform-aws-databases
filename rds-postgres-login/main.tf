module "secret" {
  source = "../generic-secret"

  description     = "Postgres password for: ${local.full_name}"
  name            = coalesce(var.secret_name, local.full_name)
  resource_tags   = var.tags
  trust_principal = var.trust_principal
  trust_tags      = var.trust_tags

  initial_value = jsonencode({
    dbname   = var.database.name
    engine   = var.database.engine
    host     = var.database.address
    password = ""
    port     = tostring(var.database.port)
    username = var.username
  })
}

module "rotation" {
  source = "../secret-rotation-function"

  handler            = "lambda_function.lambda_handler"
  role_arn           = module.secret.rotation_role_arn
  runtime            = "python3.8"
  secret_arn         = module.secret.arn
  security_group_ids = [aws_security_group.function.id]
  source_file        = "${path.module}/rotation/lambda_function.py"
  subnet_ids         = var.subnet_ids

  dependencies = {
    postgres = "${path.module}/rotation/postgres.zip"
  }

  variables = {
    ADMIN_LOGIN_SECRET_ARN = var.admin_login_secret_arn
    ALTERNATE_USERNAME     = coalesce(var.alternate_username, "${var.username}_alt")
    GRANTS                 = jsonencode(var.grants)
    PRIMARY_USERNAME       = var.username
  }
}

resource "aws_security_group" "function" {
  description = "Security group for rotating ${local.full_name}"
  name        = "${var.database.identifier}-rotation"
  tags        = var.tags
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "function_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all egress"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.function.id
  to_port           = 0
  type              = "egress"
}

resource "aws_iam_role_policy_attachment" "access_admin_login" {
  policy_arn = aws_iam_policy.access_admin_login.arn
  role       = module.secret.rotation_role_name
}

resource "aws_iam_policy" "access_admin_login" {
  name   = local.full_name
  policy = data.aws_iam_policy_document.access_admin_login.json
}

data "aws_iam_policy_document" "access_admin_login" {
  statement {
    sid = "ReadAdminLogin"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue"
    ]
    resources = [var.admin_login_secret_arn]
  }

  statement {
    sid = "DecryptReadAdminLogin"
    actions = [
      "kms:Decrypt"
    ]
    resources = [data.aws_kms_key.admin_login.arn]
  }

  statement {
    sid = "DescribeDatabase"
    actions = [
      "rds:DescribeDBInstances"
    ]
    resources = [var.database.arn]
  }
}

data "aws_kms_key" "admin_login" {
  key_id = var.admin_login_kms_key_id
}

locals {
  full_name = join("-", ["rds-postgres", var.database.identifier, var.username])
}
