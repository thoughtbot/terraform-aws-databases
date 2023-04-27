output "environment_variables" {
  description = "Environment variables set by this rotation function"
  value       = ["DATABASE_URL"]
}

output "policy_json" {
  description = "Required IAM policies"
  value       = module.secret.policy_json
}

output "secret_arn" {
  description = "ARN of the secrets manager secret containing credentials"
  value       = module.secret.arn
}

output "secret_name" {
  description = "Name of the secrets manager secret containing credentials"
  value       = module.secret.name
}
