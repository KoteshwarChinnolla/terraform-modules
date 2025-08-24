output "ecr_repository_name" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.repository.name
}

output "ecr_repo_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.repository.repository_url
}
