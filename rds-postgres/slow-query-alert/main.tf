
locals {
  function_name        = "update-sql-query-logs-${random_id.unique_id.dec}"
  sentry_function_name = "sql-query-sentry-logs-${random_id.unique_id.dec}"
}

resource "aws_cloudwatch_log_metric_filter" "slowquery_cloudwatch_alarm" {
  name           = "${var.rds_identifier}-slow-query-metric-filter"
  pattern        = "duration"
  log_group_name = "/aws/rds/instance/${var.rds_identifier}/postgresql"

  metric_transformation {
    name          = "SlowQuery"
    namespace     = "AWSPostgreSQL"
    default_value = "0"
    value         = "1"
  }
}

resource "aws_sns_topic" "rds_slowquery_entry" {
  name = "rds-slowquery-entry-topic-${random_id.unique_id.dec}"
}

resource "aws_sns_topic" "slowquery_cloudwatch_sns" {
  name = "RDS-slow-query-topic-${random_id.unique_id.dec}"
}

resource "aws_sns_topic_subscription" "slowquery_cloudwatch_subscription" {
  count = var.cloudwatch_opsgenie_api_key == "" ? 0 : 1

  topic_arn = aws_sns_topic.slowquery_cloudwatch_sns.arn
  protocol  = "https"
  endpoint  = "https://api.opsgenie.com/v1/json/cloudwatch?apiKey=${var.cloudwatch_opsgenie_api_key}"
}

resource "aws_cloudwatch_metric_alarm" "slowquery_cloudwatch_alarm" {
  alarm_name                = "${var.rds_identifier}-slow-sql-query-detected"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "SlowQuery"
  namespace                 = "AWSPostgreSQL"
  threshold                 = "1"
  alarm_description         = "This metric monitors slow RDS queries"
  statistic                 = "Sum"
  period                    = "60"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.rds_slowquery_entry.arn]
  ok_actions                = [aws_sns_topic.rds_slowquery_entry.arn]
}

resource "aws_lambda_function" "sql_query_update" {
  function_name    = local.function_name
  description      = "Lambda function to inject sql query into sns message for for slow query logs"
  filename         = data.archive_file.function.output_path
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.8"
  source_code_hash = data.archive_file.function.output_base64sha256
  timeout          = 60

  environment {
    variables = {
      notificationSNSTopicArn = aws_sns_topic.slowquery_cloudwatch_sns.arn
      metricName              = "SlowQuery"
      metricNamespace         = "AWSPostgreSQL"
    }
  }
  depends_on = [
    aws_cloudwatch_log_group.lambda_logs,
    aws_iam_role.lambda_role
  ]
}

resource "aws_lambda_function" "sql_query_sentry_log" {
  function_name    = local.sentry_function_name
  description      = "Lambda function to send sql query message to Sentry"
  filename         = data.archive_file.sentry_function.output_path
  handler          = "sentry_lambda_logs.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.8"
  source_code_hash = data.archive_file.sentry_function.output_base64sha256
  timeout          = 60
  layers           = [aws_lambda_layer_version.sentry_sdk_layer.arn]

  environment {
    variables = {
      metricName        = "SlowQuery"
      metricNamespace   = "AWSPostgreSQL"
      sentrySecretName  = var.sentry_secret_name
      sentryEnvironment = "production"
    }
  }
  depends_on = [
    aws_cloudwatch_log_group.lambda_logs,
    aws_iam_role.lambda_role
  ]
}

data "aws_iam_policy_document" "assume_role_policy_doc" {
  statement {
    sid    = "AllowAwsToAssumeRole"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${local.function_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_doc.json
}

resource "aws_iam_role_policy" "logs_role_policy" {
  name   = "${local.function_name}-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_role_policy.json
}

data "aws_iam_policy_document" "lambda_role_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.sql_query_filter_policy.json,
    jsondecode(var.sentry_secret_policy_json)
  ]
}

resource "random_id" "unique_id" {
  byte_length = 3
}

data "archive_file" "function" {
  output_path = "lambda_function.zip"
  source_file = "${path.module}/lambda-script/lambda_function.py"
  type        = "zip"
}

data "archive_file" "sentry_function" {
  output_path = "sentry_lambda_logs.zip"
  source_file = "${path.module}/lambda-script/sentry_lambda_logs.py"
  type        = "zip"
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "sentry_lambda_logs" {
  name              = "/aws/lambda/${local.sentry_function_name}"
  retention_in_days = 14
}

data "aws_iam_policy_document" "sql_query_filter_policy" {
  statement {
    sid       = "snspublishnotifiations"
    effect    = "Allow"
    resources = [aws_sns_topic.slowquery_cloudwatch_sns.arn, aws_sns_topic.rds_slowquery_entry.arn]
    actions   = ["sns:Publish"]
  }
  statement {
    sid       = "cloudwatchlambdalogs"
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
    actions = [
      "logs:*"
    ]
  }
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sql_query_update.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.rds_slowquery_entry.arn
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.rds_slowquery_entry.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sql_query_update.arn
}

resource "aws_lambda_permission" "allow_sns_sentry_function" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sql_query_sentry_log.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.rds_slowquery_entry.arn
}

resource "aws_sns_topic_subscription" "lambda_sentry_function" {
  topic_arn = aws_sns_topic.rds_slowquery_entry.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sql_query_sentry_log.arn
}

resource "aws_lambda_layer_version" "sentry_sdk_layer" {

  compatible_runtimes = ["python3.8"]
  description         = "Lambda layer to package sentry sdk dependency"
  filename            = "${path.module}/lambda-script/sentry_sdk.zip"
  layer_name          = "${local.sentry_function_name}-layer"
  source_code_hash    = filebase64sha256("${path.module}/lambda-script/sentry_sdk.zip")
}
