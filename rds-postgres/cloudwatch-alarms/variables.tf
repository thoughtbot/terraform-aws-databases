variable "alarm_actions" {
  type        = list(string)
  description = "SNS topic ARNs or other actions to invoke for alarms"
  default     = []
}

variable "allocated_storage" {
  description = "Size in GB for the database instance"
  type        = number
}

variable "db_connections_limit_threshold" {
  type        = number
  default     = 80
  description = "The percentage threshold for number of database connections. Default: 80"
}

variable "db_memory_threshold" {
  type        = number
  default     = 20
  description = "The percentage threshold of FreeableMemory left for the Database. Default: 20"
}

variable "identifier" {
  type        = string
  description = "Identifier of the database to monitor"
}

variable "instance_class" {
  description = "Tier for the database instance to monitor"
  type        = string
}
