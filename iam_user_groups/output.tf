output "ecr_user_name" {
  description = "The name of the ECR repository"
  value       = module.iam_user_groups.user_name_output
}

output "access_key_id" {
  description = "The access key ID for the IAM user"
  value       = module.iam_user_groups.access_key_id
}

output "secret_access_key" {
  description = "The secret access key for the IAM user"
  value       = module.iam_user_groups.secret_access_key
  sensitive   = true
}