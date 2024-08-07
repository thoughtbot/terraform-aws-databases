variable "cloudwatch_opsgenie_api_key" {
  description = "Opsgenie Cloudwatch integration api key for slow query logs"
  type        = string
  default     = ""
}

variable "rds_identifier" {
  description = "Unique identifier for the rds database to monitor for slow queries"
  type        = string
}

variable "sentry_secret_name" {
  description = "Name of the secrets manager secret containing the sentry credentials"
  type        = string
}

variable "sentry_secret_policy_json" {
  description = "Required IAM policy to read Sentry secret"
  type        = string
}
