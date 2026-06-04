variable "name" {
  type        = string
  description = "Name for this cluster"
}

variable "description" {
  description = "Human-readable description for this replication group"
  type        = string
}

variable "global_replication_group_id" {
  type        = string
  description = "The ID of the global replication group to which this replication group belongs."
}

variable "auth_token_secret_name" {
  type        = string
  description = "Name (or ARN) of the Secrets Manager secret holding the global datastore primary's auth token, as a JSON object with a `token` key (the format written by the auth-token module). The secret must be readable from this region. Preferred over auth_token so the value stays in sync across rotations."
  default     = null
}

variable "auth_token" {
  type        = string
  description = "Auth token of the global datastore primary, supplied directly. Used only when auth_token_secret_name is not set. Must match the primary exactly; it is not inherited at creation time."
  sensitive   = true
  default     = null
}

variable "subnet_ids" {
  description = "Subnets connected to the database"
  type        = list(string)
}

variable "node_type" {
  type        = string
  description = "Node type of the global datastore (used only to size the CloudWatch alarms; not set on the replication group, which inherits it from the primary). Must match the primary's node type."
}

variable "replication_group_id" {
  description = "Override the ID for the replication group"
  type        = string
  default     = ""
}

variable "replica_count" {
  type        = number
  default     = 1
  description = "Number of read-only replicas to add to the cluster"
}

variable "port" {
  description = "Port on which to listen (used for the security group; the replication group itself inherits the port from the global datastore)"
  type        = number
  default     = 6379
}

variable "apply_immediately" {
  type        = bool
  description = "Set to true to apply changes immediately"
  default     = false
}

variable "subnet_group_name" {
  description = "Override the name for the subnet group"
  type        = string
  default     = ""
}

variable "alarm_actions" {
  type        = list(object({ arn = string }))
  description = "SNS topics or other actions to invoke for alarms"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to created resources"
  default     = {}
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
