# Instance variables

variable "admin_username" {
  type        = string
  description = "Username for the admin user"
  default     = "postgres"
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

variable "ca_cert_id" {
  type        = string
  description = "Certificate authority for RDS database"
  default     = "rds-ca-rsa2048-g1"
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

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "Set of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported"
  default     = []
}

variable "engine" {
  type        = string
  description = "RDS database engine; defaults to Postgres"
  default     = "postgres"
}

variable "engine_version" {
  type        = string
  description = "Version for RDS database engine"
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

variable "iops" {
  description = "The amount of provisioned IOPS. Required if storage type is `io1`"
  type        = number
  default     = null
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

variable "snapshot_identifier" {
  description = "Set this to create the database from an existing snapshot"
  type        = string
  default     = null
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Set to false to disable on-disk encryption"
}

variable "storage_type" {
  type        = string
  default     = "gp2"
  description = "Storage type for the EBS volume. One of `standard` (magnetic), `gp2` (general purpose SSD), or `io1` (provisioned IOPS SSD)"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to created resources"
  default     = {}
}

# CloudWatch variables

variable "alarm_actions" {
  type        = list(string)
  description = "SNS topic ARNs or other actions to invoke for alarms"
  default     = []
}

variable "create_cloudwatch_alarms" {
  type        = bool
  default     = true
  description = "Set to false to disable creation of CloudWatch alarms"
}

# Parameter group variables

variable "create_parameter_group" {
  type        = bool
  description = "Set to false to use existing parameter group"
  default     = true
}

variable "force_ssl" {
  type        = bool
  description = "Set to false to allow unencrypted connections to the database"
  default     = true
}

variable "parameter_group_name" {
  description = "Name of the RDS parameter group; defaults to identifier"
  type        = string
  default     = ""
}

# Security group variables

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the database"
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group allowed to access the database"
  type        = list(string)
  default     = []
}

variable "client_security_group_name" {
  description = "Override the name for the security group; defaults to identifer"
  type        = string
  default     = ""
}

variable "create_client_security_group" {
  type        = bool
  description = "Set to false to only use existing security groups"
  default     = true
}

variable "create_server_security_group" {
  type        = bool
  description = "Set to false to only use existing security groups"
  default     = true
}

variable "server_security_group_ids" {
  type        = list(string)
  description = "IDs of VPC security groups for this instance. One of vpc_id or server_security_group_ids is required"
  default     = []
}

variable "server_security_group_name" {
  description = "Override the name for the security group; defaults to identifer"
  type        = string
  default     = ""
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC for this instance. One of vpc_id or vpc_security_group_ids is required"
  default     = null
}

# Subnet group variables

variable "create_subnet_group" {
  type        = bool
  description = "Set to false to use existing subnet group"
  default     = true
}

variable "subnet_group_description" {
  description = "Set a description for the subnet group"
  type        = string
  default     = "Postgres subnet group"
}

variable "subnet_group_name" {
  description = "Name of the RDS subnet group (defaults to identifier)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets connected to the database; required if creating a subnet group"
  type        = list(string)
  default     = null
}

