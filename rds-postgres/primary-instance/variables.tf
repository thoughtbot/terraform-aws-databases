variable "admin_username" {
  type        = string
  description = "Username for the admin user"
}

variable "allocated_storage" {
  description = "Size in GB for the database instance"
  type        = number
}

variable "apply_immediately" {
  description = "Set to true to immediately apply changes and cause downtime"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Set to false to disable automatic minor version ugprades"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  type        = number
  default     = 30
  description = "Number of days to retain backups"
}

variable "backup_window" {
  type        = string
  description = "UTC time range in which backups can be captured, such as 18:00-22:00"
  default     = null
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

variable "engine" {
  type        = string
  description = "RDS database engine; defaults to Postgres"
  default     = "postgres"
}

variable "engine_version" {
  type        = string
  description = "Version for RDS database engine; defaults to Postgres 12.6"
  default     = "12.6"
}

variable "identifier" {
  type        = string
  description = "Unique identifier for this database"
}

variable "initial_password" {
  type        = string
  description = "Override the initial password for the admin user"
  default     = ""
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

variable "maintenance_window" {
  type        = string
  description = "UTC day/time range during which maintenance can be performed, such as Mon:00:00-Mon:03:00"
  default     = null
}

variable "max_allocated_storage" {
  type        = number
  description = "Maximum size GB after autoscaling"
  default     = 0
}

variable "multi_az" {
  type        = bool
  description = "Whether or not to use a high-availability/multi-availability-zone instance"
  default     = false
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

variable "skip_final_snapshot" {
  description = "Set to true to skip a snapshot when destroying"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Set to false to disable on-disk encryption"
}

variable "subnet_group_name" {
  description = "Name of the RDS subnet group"
  type        = string
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
