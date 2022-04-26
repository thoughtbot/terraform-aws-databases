module "secret" {
  source = "github.com/thoughtbot/terraform-aws-secrets//secret?ref=v0.1.0"

  admin_principals = var.admin_principals
  description      = "Postgres password for: ${local.full_name}"
  name             = coalesce(var.secret_name, local.full_name)
  read_principals  = var.read_principals
  resource_tags    = var.tags
  trust_tags       = var.trust_tags

  initial_value = jsonencode({
    dbname   = var.database_name
    engine   = data.aws_db_instance.this.engine
    host     = data.aws_db_instance.this.address
    password = ""
    port     = tostring(data.aws_db_instance.this.port)
    username = var.username
  })
}

module "rotation" {
  source = "github.com/thoughtbot/terraform-aws-secrets//secret-rotation-function?ref=v0.1.0"

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
  name        = local.full_name
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
    resources = [data.aws_db_instance.this.db_instance_arn]
  }
}

data "aws_kms_key" "admin_login" {
  key_id = var.admin_login_kms_key_id
}

data "aws_db_instance" "this" {
  db_instance_identifier = var.identifier
}

locals {
  full_name = join("-", ["rds-postgres", var.identifier, var.username])
}
