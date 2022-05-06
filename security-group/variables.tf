variable "allow_all_egress" {
  description = "Set to true to allow all egress traffic"
  type        = bool
  default     = false
}

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
  description = "Security group used by the database instance"
  type        = string
}

variable "name" {
  type        = string
  description = "Name of the security group"
}

variable "ports" {
  type        = map(number)
  description = "Ports on which to listen"
  default     = {}
}

variable "randomize_name" {
  type        = bool
  description = "Set to false to avoid a randomized suffix"
  default     = true
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
