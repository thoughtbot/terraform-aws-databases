variable "admin_principals" {
  description = "Principals allowed to peform admin actions (default: current account)"
  type        = list(string)
  default     = null
}

variable "alternate_username" {
  description = "Username for the alternate login used during rotation (default: <source username>_alt)"
  type        = string
  default     = null
}

variable "identifier" {
  description = "Identifier of the database for which a login will be managed"
  type        = string
}

variable "read_principals" {
  description = "Principals allowed to read the secret (default: current account)"
  type        = list(string)
  default     = null
}

variable "replica_regions" {
  description = "List of regions to replicate the secret to"
  type = list(object({
    region     = string
    kms_key_id = optional(string)
  }))
  default = []
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

variable "source_secret_arn" {
  description = "ARN (or name) of the primary admin secret to seed username, password and dbname from. Must be readable from this module's region (typically a replica of the primary secret)."
  type        = string
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
