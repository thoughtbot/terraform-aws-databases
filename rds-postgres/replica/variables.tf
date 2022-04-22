variable "allocated_storage" {
  description = "Size in GB for the database instance"
  type        = number
}

variable "apply_immediately" {
  description = "Set to true to immediately apply changes and cause downtime"
  type        = bool
  default     = false
}

variable "create_default_db" {
  type        = bool
  description = "Set to false to disable creating a default database"
  default     = true
}

variable "default_database" {
  type        = string
  description = "Name of the default database"
  default     = "postgres"
}

variable "identifier" {
  type        = string
  description = "Unique identifier for this database"
}

variable "instance_class" {
  description = "Tier for the database instance"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key to encrypt data at rest"
  type        = string
  default     = null
}

variable "max_allocated_storage" {
  type        = number
  description = "Maximum size GB after autoscaling"
  default     = 0
}

variable "parameter_group_name" {
  description = "Name of the RDS parameter group"
  type        = string
}

variable "performance_insights_enabled" {
  type        = bool
  default     = true
  description = "Set to false to disable performance insights"
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "Set to true to access this database outside the VPC"
}

variable "replicate_source_db" {
  description = "Identifier of the primary database instance to replicate"
  type        = string
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Set to false to disable on-disk encryption"
}

variable "subnet_group_name" {
  description = "Name of the RDS subnet group (only for cross-region replication)"
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to created resources"
  default     = {}
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "IDs of VPC security groups for this instance"
}
