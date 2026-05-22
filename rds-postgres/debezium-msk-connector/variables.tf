variable "cluster_name" {
  type        = string
  description = "Base name used to derive connector, slot, publication, and topic defaults."
}

variable "connector_name" {
  type        = string
  default     = null
  description = "Explicit name for the MSK Connect connector. Defaults to '<cluster_name>-postgres-connector'."
}

variable "worker_configuration_name" {
  type        = string
  default     = null
  description = "Explicit name for the MSK Connect worker configuration. Defaults to '<cluster_name>-worker-config'."
}

variable "log_group_name" {
  type        = string
  default     = null
  description = "Explicit name for the CloudWatch log group. Defaults to '<connector_name>-logs'."
}

variable "kafkaconnect_version" {
  type        = string
  default     = "3.7.x"
  description = "Kafka Connect runtime version for the MSK Connect connector."
}

variable "mcu_count" {
  type        = number
  default     = 1
  description = "Number of MSK Connect units (MCUs) allocated to each connector worker."
}

variable "min_worker_count" {
  type        = number
  default     = 1
  description = "Minimum number of autoscaled workers for the MSK Connect connector."
}

variable "max_worker_count" {
  type        = number
  default     = 2
  description = "Maximum number of autoscaled workers for the MSK Connect connector."
}

variable "database_credentials_secret_name" {
  type        = string
  description = "Name of the AWS Secrets Manager secret that stores the PostgreSQL connection details with keys `host`, `port`, `dbname`, `username`, and `password`."
}

variable "kafka_iam_broker_endpoint_parameter_name" {
  type        = string
  description = "Name of the SSM parameter that contains the MSK IAM bootstrap broker endpoint."
}

variable "table_include_list" {
  type        = string
  description = "Comma-separated list of PostgreSQL tables that Debezium should capture. Example: 'public.table_a,public.table_b'."
}

variable "bootstrap_brokers_sasl_iam" {
  type        = string
  description = "SASL/IAM bootstrap broker connection string for the target Amazon MSK cluster."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs attached to the MSK Connect connector within the VPC."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs where the MSK Connect connector workers will run."
}

variable "custom_plugin_name" {
  type        = string
  description = "Name of the existing AWS MSK Connect custom plugin that contains the Debezium PostgreSQL connector artifacts."
}

variable "schema_history_topic" {
  type        = string
  default     = null
  description = "Override for the internal Kafka topic used by Debezium schema history. Defaults to 'schemahistory.<cluster_name>' with hyphens replaced by underscores."
}

variable "tasks_max" {
  type        = number
  default     = 1
  description = "Maximum number of connector tasks. PostgreSQL Debezium connectors typically run with a single task."
}

variable "cloudwatch_log_retention_in_days" {
  type        = number
  default     = 30
  description = "Number of days to retain connector worker logs in CloudWatch."
}

variable "worker_configuration_properties_file_content" {
  type        = string
  default     = null
  description = "Optional full worker configuration properties content. Defaults to a configuration that enables Secrets Manager and SSM config providers in the current AWS region."
}

variable "connector_configuration_overrides" {
  type        = map(string)
  default     = {}
  description = "Additional connector configuration entries to merge over the module defaults."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to supported resources created by this module."
}
