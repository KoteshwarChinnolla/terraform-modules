provider "aws" {
  region = "us-east-1"
}

# terraform {
#   backend "s3" {
#     bucket = "anasolbackendhrms"
#     key    = "terraform/state"
#     region = "us-east-1"
#   }
# }

module "iam_user_groups" {
    source = "../modules/IAM_grops_poicy"
    user_name = var.user_name
    group_name = var.group_name
    policy_name = var.policy_name
    statements = var.statements
}

