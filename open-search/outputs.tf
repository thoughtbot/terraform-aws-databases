output "arn" {
  description = "ARN of the created OpenSearch cluster"
  value       = aws_opensearch_domain.this.arn
}

output "domain" {
  description = "Name of the OpenSearch domain for this cluster"
  value       = aws_opensearch_domain.this.domain_name
}

output "endpoint" {
  description = "Endpoint at which the cluster can be accessed"
  value       = aws_opensearch_domain.this.endpoint
}

output "policy" {
  description = "IAM policy for accessing this OpenSearch domain"
  value       = data.aws_iam_policy_document.es_access_policy.json
}
