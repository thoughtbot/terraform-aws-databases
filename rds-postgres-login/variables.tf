variable "admin_login_secret_arn" {
  type        = string
  description = "ARN of a SecretsManager secret containing admin login"
  default     = null
}

variable "admin_login_kms_key_id" {
  type        = string
  description = "ARN of the KMS key used to encrypt the admin login"
}

variable "admin_principals" {
  description = "Principals allowed to peform admin actions (default: current account)"
  type        = list(string)
  default     = null
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

variable "read_principals" {
  description = "Principals allowed to read the secret (default: current account)"
  type        = list(string)
  default     = null
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
