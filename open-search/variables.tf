variable "admin_principals" {
  description = "IAM principals allowed to perform administrative actions"
  type        = list(string)
}

variable "advanced_options" {
  description = "Map of key-value string pairs to specify advanced configuration options"
  type        = map(string)
  default     = {}
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the OpenSearch domain"
  type        = list(string)
}

variable "automated_snapshot_start_hour" {
  description = "Hour at which automated snapshots are taken, in UTC (default 7)"
  type        = number
  default     = 7
}

variable "domain_name" {
  description = "Name for this OpenSearch domain"
  type        = string
}

variable "ebs_volume_iops" {
  description = "IOPS for attached EBS volumes if using io volume type"
  type        = number
  default     = null
}

variable "ebs_volume_size" {
  description = "Size of EBS volume on each node"
  type        = number
}

variable "ebs_volume_type" {
  description = "Storage type of EBS volumes (default gp2)"
  type        = string
  default     = "gp2"
}

variable "engine_version" {
  description = "Version of OpenSearch to deploy"
  type        = string
}

variable "encrypt_at_rest" {
  description = "Set to false to disable at-rest encryption"
  type        = bool
  default     = true
}

variable "instance_count" {
  description = "Number of data nodes in the cluster (default 1)"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "Instance type for data nodes in the cluster"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key to encrypt data at rest"
  type        = string
  default     = null
}

variable "security_group_name" {
  description = "Name for the security group (defaults to domain name)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "IDs for VPC subnets in which the cluster should run"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be applied to created resources"
  type        = map(string)
  default     = {}
}

variable "tls_security_policy" {
  description = "Minimum TLS version for connecting to the cluster"
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"
}

variable "vpc_id" {
  description = "ID of the VPC in which the cluster should run"
  type        = string
}
