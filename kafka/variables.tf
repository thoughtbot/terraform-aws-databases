variable "cluster_name" {
  type        = string
  description = "Name of the MSK cluster"
}

variable "kafka_version" {
  type        = string
  description = "Desired Kafka version on the MSK cluster"
}

variable "broker_node_count" {
  type        = number
  description = "The desired total number of broker nodes in the kafka cluster"
  default     = null
}

variable "ebs_volume_size" {
  type        = number
  description = "The size in GiB of the EBS volume for the data drive on each broker node"
  default     = 5
}

variable "instance_type" {
  type        = string
  description = "The instance type to use for the kafka brokers"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to created resources"
  default     = {}
}

variable "private_tags" {
  description = "Tags to identify private subnets"
  type        = map(string)
  default     = { "kubernetes.io/role/internal-elb" = "1" }
}

variable "public_tags" {
  description = "Tags to identify public subnets"
  type        = map(string)
  default     = { "kubernetes.io/role/elb" = "1" }
}

variable "vpc_tags" {
  description = "Tags to identify the VPC"
  type        = map(string)
  default     = {}
}

variable "additional_vpc_tags" {
  description = "Tags to identify an additional VPC"
  type        = map(string)
  default     = {}
}
