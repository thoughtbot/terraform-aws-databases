module "secret" {
  source = "github.com/thoughtbot/terraform-aws-secrets//secret?ref=v0.9.0"

  admin_principals = var.admin_principals
  description      = "Postgres password for: ${local.full_name}"
  name             = coalesce(var.secret_name, local.full_name)
  read_principals  = var.read_principals
  replica_regions  = var.replica_regions
  resource_tags    = var.tags
  trust_tags       = var.trust_tags

  # The username, password and dbname are seeded from the source (primary)
  # secret -- the promoted database inherited these from the primary at
  # promotion time. The host/port/engine describe the promoted database's own
  # endpoint. After creation the rotation function owns the secret value; the
  # source secret is only read at plan time to seed this initial version.
  initial_value = jsonencode({
    dbname   = local.source.dbname
    engine   = data.aws_db_instance.this.engine
    host     = data.aws_db_instance.this.address
    password = local.source.password
    port     = tostring(data.aws_db_instance.this.port)
    username = local.source.username
  })
}

module "rotation" {
  source = "github.com/thoughtbot/terraform-aws-secrets//secret-rotation-function?ref=v0.9.0"

  handler     = "lambda_function.lambda_handler"
  role_arn    = module.secret.rotation_role_arn
  runtime     = "python3.8"
  secret_arn  = module.secret.arn
  source_file = "${path.module}/rotation/lambda_function.py"
  subnet_ids  = var.subnet_ids

  dependencies = {
    postgres = "${path.module}/rotation/postgres.zip"
  }

  security_group_ids = concat(
    var.security_group_ids,
    [module.security_group.id]
  )

  variables = {
    ALTERNATE_USERNAME = coalesce(var.alternate_username, "${local.source.username}_alt")
    PRIMARY_USERNAME   = local.source.username
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
      "rds:DescribeDBInstances"
    ]
    resources = [data.aws_db_instance.this.db_instance_arn]
  }
}

data "aws_db_instance" "this" {
  db_instance_identifier = var.identifier
}

# Read the source (primary) secret to seed the username, password and dbname.
# Resolved through this module's provider, so a region-local replica of the
# primary secret is read when this module runs in the promoted database's region.
data "aws_secretsmanager_secret_version" "source" {
  secret_id = var.source_secret_arn
}

locals {
  full_name = join("-", ["rds-postgres", var.identifier])
  source    = jsondecode(data.aws_secretsmanager_secret_version.source.secret_string)
}
