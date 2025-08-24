output "output_group_arn" {
  value = aws_iam_group.group1.arn
}

# output "policy_arn" {
#   value = aws_iam_policy.group_policy.arn
# }

output "user_name_output" {
  value = aws_iam_user.user1.name
}

output "access_key_id" {
  value = aws_iam_access_key.user1_key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.user1_key.secret
  sensitive = true
}