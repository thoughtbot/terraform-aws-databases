variable "admin_principals" {
  description = "Principals allowed to peform admin actions (default: current account)"
  type        = list(string)
  default     = null
}

variable "replication_group_id" {
  description = "ID of the group for which the auth token will be managed"
  type        = string
}

variable "initial_auth_token" {
  type        = string
  description = "Inital auth token passed when the group was created"
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

variable "vpc_id" {
  description = "VPC in which the rotation function should run"
  type        = string
}
