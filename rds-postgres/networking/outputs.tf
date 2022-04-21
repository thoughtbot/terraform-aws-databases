output "security_group_id" {
  description = "ID of the created security group"
  value       = module.security_group.instance.id
}

output "subnet_group_name" {
  description = "Name of the created subnet group"
  value       = aws_db_subnet_group.this.name
}
