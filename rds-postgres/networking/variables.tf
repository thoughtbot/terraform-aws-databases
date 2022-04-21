variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the database"
  type        = list(string)
  default     = []
}

variable "allowed_security_groups" {
  description = "Security group allowed to access the database"
  type        = list(object({ id = string }))
  default     = []
}

variable "name" {
  type        = string
  description = "Name for network resources"
}

variable "security_group_name" {
  description = "Override the name for the security group"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnets connected to the database"
  type        = list(string)
}

variable "subnet_group_description" {
  description = "Set a description for the subnet group"
  type        = string
  default     = "Postgres subnet group"
}

variable "subnet_group_name" {
  description = "Override the name for the subnet group"
  type        = string
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to created resources"
  default     = {}
}

variable "vpc_id" {
  description = "VPC for the database instance"
  type        = string
}
