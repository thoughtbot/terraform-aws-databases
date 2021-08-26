variable "alarm_actions" {
  type        = list(object({ arn = string }))
  description = "SNS topcis or other actions to invoke for alarms"
  default     = []
}

variable "allocated_storage" {
  description = "Size in GB for the database instance"
  type        = number
}

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

variable "force_ssl" {
  type        = bool
  description = "Set to false to allow unencrypted connections to the database"
  default     = true
}

variable "identifiers" {
  description = "Override the identifier for one or more databases"
  type        = map(string)
  default     = {}
}

variable "instance_class" {
  description = "Tier for the database instance"
  type        = string
}

variable "kms_key" {
  description = "Custom KMS key to encrypt data at rest"
  type        = object({ arn = string })
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

variable "name" {
  type        = string
  description = "Name for this database"
}

variable "namespace" {
  type        = list(string)
  default     = []
  description = "Prefix to be applied to created resources"
}

variable "password" {
  type        = string
  default     = ""
  description = "Override the generated password for the master user"
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

variable "replica_names" {
  type        = list(string)
  default     = []
  description = "Read-only replicas to create for this database"
}

variable "security_group_name" {
  description = "Override the name for the security group"
  type        = string
  default     = ""
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Set to false to disable on-disk encryption"
}

variable "subnet_ids" {
  description = "Subnets connected to the database"
  type        = list(string)
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

variable "username" {
  type        = string
  description = "Override the master username for the master user"
  default     = "postgres"
}

variable "vpc" {
  description = "VPC for the database instance"
  type        = object({ id = string })
}
