variable "allowed_security_groups" {
  description = "Security group allowed to access the database"
  type        = list(object({ id = string }))
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the database"
  type        = list(string)
  default     = []
}

variable "description" {
  description = "Security group used by the database instance"
  type        = string
  default     = "Postgres security group"
}

variable "name" {
  type        = string
  default     = "postgres"
  description = "Name of the security group"
}

variable "namespace" {
  type        = list(string)
  default     = []
  description = "Prefix to be applied to created resources"
}

variable "port" {
  type        = number
  description = "Port on which to listen"
  default     = 5432
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to created resources"
  default     = {}
}

variable "vpc_id" {
  description = "VPC for the source database security group"
  type        = string
}
