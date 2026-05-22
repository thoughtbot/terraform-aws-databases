data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

data "aws_iam_policy_document" "msk_connect_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["kafkaconnect.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = [
      "arn:aws:secretsmanager:${data.aws_region.this.region}:${data.aws_caller_identity.this.account_id}:secret:${var.database_credentials_secret_name}*",
    ]
  }

  statement {
    sid    = "WriteConnectorLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = [
      aws_cloudwatch_log_group.this.arn,
      "${aws_cloudwatch_log_group.this.arn}:*",
    ]
  }

  statement {
    sid    = "MSKClusterConnect"
    effect = "Allow"
    actions = [
      "kafka-cluster:*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "MSKAccess"
    effect = "Allow"
    actions = [
      "kafka:*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SSMAccess"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = [
      "arn:aws:ssm:${data.aws_region.this.region}:${data.aws_caller_identity.this.account_id}:parameter/${trim(var.kafka_iam_broker_endpoint_parameter_name, "/")}",
    ]
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.cluster_name}-msk-connect-role"
  assume_role_policy = data.aws_iam_policy_document.msk_connect_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.cluster_name}-msk-connect-policy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.this.json
}
