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

variable "database_name" {
  description = "Name of the database to connect to"
  type        = string
}

variable "identifier" {
  description = "Identifier of the database for which a login will be managed"
  type        = string
}

variable "initial_password" {
  type        = string
  description = "ARN of the KMS key used to encrypt the admin login"
}

variable "read_principals" {
  description = "Principals allowed to read the secret (default: current account)"
  type        = list(string)
  default     = null
}

variable "replica_host" {
  description = "Hostname to use when connecting to the database replica"
  type        = string
  default     = null
}

variable "secret_name" {
  description = "Override the name for this secret"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "Security groups to attach to the rotation function"
  type        = list(string)
  default     = []
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
