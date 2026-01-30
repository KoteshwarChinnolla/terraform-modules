output "vpc_id" {
    value = module.vpc.vpc_id
    description = "The ID of the VPC"
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = module.rds.rds_endpoint
  # sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.rds_port
  # sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = module.rds.rds_username
  # sensitive   = true
}

# output "instance_url_connect" {
#   value = "ubuntu@${aws_instance.temp_ec2_instance.public_ip}"
# }

output "lb_url" {
  value = module.alb.alb_dns_name
}

