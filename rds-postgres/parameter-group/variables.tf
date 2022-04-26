variable "engine_version" {
  type        = string
  description = "Version for RDS database engine"
}

variable "name" {
  type        = string
  description = "Name of the parameter group"
}

variable "force_ssl" {
  type        = bool
  description = "Set to false to allow unencrypted connections to the database"
  default     = true
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to created resources"
}
