variable "admin_login_secret_arn" {
  type        = string
  description = "ARN of a SecretsManager secret containing admin login"
  default     = null
}

variable "admin_login_kms_key_id" {
  type        = string
  description = "ARN of the KMS key used to encrypt the admin login"
}

variable "alternate_username" {
  description = "Username for the alternate login used during rotation"
  type        = string
  default     = null
}

variable "database" {
  description = "The database instance for which a login will be managed"

  type = object({
    address    = string
    arn        = string
    engine     = string
    identifier = string
    name       = string
    port       = number
  })
}

variable "grants" {
  description = "List of GRANT statements for this user"
  type        = list(string)
}

variable "secret_name" {
  description = "Override the name for this secret"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets in which the rotation function should run"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be applied to created resources"
  type        = map(string)
  default     = {}
}

variable "trust_principal" {
  description = "Principal allowed to access the secret (default: current account)"
  type        = string
  default     = null
}

variable "trust_tags" {
  description = "Tags required on principals accessing the secret"
  type        = map(string)
  default     = {}
}

variable "username" {
  description = "The username for which a login will be managed"
  type        = string
}

variable "vpc_id" {
  description = "VPC in which the rotation function should run"
  type        = string
}
