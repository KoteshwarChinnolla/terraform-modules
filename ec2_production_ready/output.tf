output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "instance_id" {
  description = "The name tag of the EC2 instance"
  value       = module.ec2_instance.instance_id
}

output "instance_dns" {
  description = "The public DNS of the EC2 instance"
  value       = module.ec2_instance.public_dns
}