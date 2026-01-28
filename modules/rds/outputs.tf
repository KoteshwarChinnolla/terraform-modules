output "rds_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "rds_username" {
  value = aws_db_instance.this.username
}

output "rds_port" {
  value = aws_db_instance.this.port
}

output "rds_security_group_id" {
  value = aws_security_group.this.id
}

output "rds_instance_id" {
  value = aws_db_instance.this.id
}

output "rds_subnet_group" {
  value = aws_db_subnet_group.this.name
}
