output "id" {
  description = "ID of the created security_group"
  value       = aws_security_group.this.id
}

output "instance" {
  description = "RDS Database security group for the attached VPC"
  value       = aws_security_group.this
}
