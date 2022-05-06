variable "allowed_security_group_ids" {
  description = "Security group allowed to access the database"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the database"
  type        = list(string)
  default     = []
}

variable "description" {
  description = "Text description for this rule"
  type        = string
}

variable "port" {
  type        = number
  description = "Port to allow"
}

variable "security_group_id" {
  description = "Security group to which rules should be added"
  type        = string
}
