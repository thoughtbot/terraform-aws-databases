variable "allocated_storage" {
  description = "Size in GB for the database instance"
  type        = number
}

variable "apply_immediately" {
  description = "Set to true to immediately apply changes and cause downtime"
  type        = bool
  default     = false
}

variable "engine_version" {
  type        = string
  description = "Version for RDS database engine"
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

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "Set of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported"
  default     = []
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

variable "replica_region" {
  description = "Region where the replica will be managed; defaults to the provider region when null"
  type        = string
  default     = null
}

variable "storage_type" {
  description = "Storage type (e.g. gp2, gp3, io1). Leave null to keep the AWS default."
  type        = string
  default     = null
}

variable "iops" {
  description = "Provisioned IOPS. Only applicable for gp3/io1 storage types."
  type        = number
  default     = null
}

variable "storage_throughput" {
  description = "Storage throughput (MiB/s). Only applicable for gp3 storage type."
  type        = number
  default     = null
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

variable "subnet_ids" {
  description = "Subnets for the replica; when set and subnet_group_name is null, the module creates a subnet group"
  type        = list(string)
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to created resources"
  default     = {}
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "IDs of VPC security groups for this instance (if different from primary)"
  default     = []
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

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the replica when creating a security group"
  type        = list(string)
  default     = []
}

variable "deletion_protection" {
  description = "deletion protection to avoid accidental deletion"
  type        = bool
  default     = false
}

variable "create_server_security_group" {
  type        = bool
  description = "Set to true to create a dedicated server security group for the replica"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC for the replica security group; required when create_server_security_group is true"
  default     = null
}
