variable "alarm_actions" {
  type        = list(object({ arn = string }))
  description = "SNS topcis or other actions to invoke for alarms"
  default     = []
}

variable "at_rest_encryption_enabled" {
  description = "Set to false to disable encryption at rest"
  type        = bool
  default     = true
}

variable "kms_key" {
  description = "Custom KMS key to encrypt data at rest"
  type        = object({ arn = string })
  default     = null
}

variable "description" {
  description = "Human-readable description for this replication group"
  type        = string
}

variable "enable_kms" {
  type        = bool
  description = "Enable KMS encryption"
  default     = true
}

variable "engine" {
  type        = string
  description = "Elasticache database engine; defaults to Redis"
  default     = "redis"
}

variable "engine_version" {
  type        = string
  description = "Version for RDS database engine"
}

variable "initial_auth_token" {
  type        = string
  description = "Override the initial auth token"
  default     = null
}

variable "name" {
  type        = string
  description = "Name for this cluster"
}

variable "node_type" {
  type        = string
  description = "Node type for the Elasticache instance"
}

variable "parameter_group_name" {
  type        = string
  description = "Parameter group name for the Redis cluster"
  default     = null
}

variable "port" {
  description = "Port on which to listen"
  type        = number
  default     = 6379
}

variable "replica_count" {
  type        = number
  default     = 1
  description = "Number of read-only replicas to add to the cluster"
}

variable "replication_group_id" {
  description = "Override the ID for the replication group"
  type        = string
  default     = ""
}

variable "snapshot_name" {
  description = "Name of an existing snapshot from which to create a cluster"
  type        = string
  default     = null
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain snapshots"
  type        = number
  default     = 7
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

variable "transit_encryption_enabled" {
  description = "Set to false to disable TLS"
  type        = bool
  default     = true
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
