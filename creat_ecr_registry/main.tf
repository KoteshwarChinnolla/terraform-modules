provider "aws" {
  region = "ap-south-1"
}

# terraform {
#   backend "s3" {
#     bucket = "anasolbackendhrms"
#     key    = "terraform/state"
#     region = "us-east-1"
#   }
# }

variable "resource_name" {
  description = "Name of the resource"
  type        = string
  default     = "example_ecr"
}

module "ecr" {
  source = "../modules/ecr"
  resource_name = var.resource_name
}


output "ecr_repository_name" {
  value = module.ecr.ecr_repository_name
}

output "ecr_repo_url" {
  value = module.ecr.ecr_repo_url
}

# ecr_repo_url = "435073375740.dkr.ecr.ap-south-1.amazonaws.com/hrms_images-repository"
# ecr_repository_name = "hrms_images-repository"