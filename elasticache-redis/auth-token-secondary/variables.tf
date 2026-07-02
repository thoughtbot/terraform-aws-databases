variable "admin_principals" {
  description = "Principals allowed to peform admin actions (default: current account)"
  type        = list(string)
  default     = null
}

variable "auth_token_secret_name" {
  type        = string
  description = "Name (or ARN) of the Secrets Manager secret holding the global datastore primary's auth token, as a JSON object with a `token` key (the format written by the auth-token module). Must be readable from this region -- typically a replica created via that module's `replica_regions`."
}

variable "replica_regions" {
  description = "List of regions to replicate the secret to"
  type = list(object({
    region     = string
    kms_key_id = optional(string)
  }))
  default = []
}

variable "replication_group_id" {
  description = "ID of the secondary replication group whose endpoint this secret describes"
  type        = string
}

variable "read_principals" {
  description = "Principals allowed to read the secret (default: current account)"
  type        = list(string)
  default     = null
}

variable "secret_name" {
  description = "Override the name for this secret"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to be applied to created resources"
  type        = map(string)
  default     = {}
}

variable "trust_tags" {
  description = "Tags required on principals accessing the secret"
  type        = map(string)
  default     = {}
}
