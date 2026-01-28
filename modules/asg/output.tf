output "asg_name" {
  value = aws_autoscaling_group.this.name
}

output "asg_arn" {
  value = aws_autoscaling_group.this.arn
}

output "launch_template_id" {
  value = aws_launch_template.ecs_ec2.id
}

output "security_group_id" {
  value = aws_security_group.ecs_node_sg.id
}

output "instance_profile_arn" {
  value = aws_iam_instance_profile.ecs_node.arn
}

output "iam_role_name" {
  value = aws_iam_role.ecs_node_role.name
}
