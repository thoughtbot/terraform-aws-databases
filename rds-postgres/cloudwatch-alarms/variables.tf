variable "alarm_actions" {
  type        = list(string)
  description = "SNS topic ARNs or other actions to invoke for alarms"
  default     = []
}

variable "allocated_storage" {
  description = "Size in GB for the database instance"
  type        = number
}

variable "identifier" {
  type        = string
  description = "Identifier of the database to monitor"
}

variable "instance_class" {
  description = "Tier for the database instance to monitor"
  type        = string
}
