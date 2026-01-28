output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "task_security_group_id" {
  value = aws_security_group.ecs.id
}

output "task_role_arn" {
  value = aws_iam_role.task.arn
}
