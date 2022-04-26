output "host" {
  description = "The hostname to use when connecting to this replica"
  value       = aws_db_instance.this.address
}

output "identifier" {
  description = "Identifier of the created RDS database"
  value       = aws_db_instance.this.identifier
}

output "instance" {
  description = "The created replica"
  value       = aws_db_instance.this
}
