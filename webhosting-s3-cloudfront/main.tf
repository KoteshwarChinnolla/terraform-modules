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

module "s3_bucket" {
  source = "../modules/s3_bucket"
  bucket_name = var.bucket_name
  privacy = var.privacy
  folder_path = var.folder_path
  enable_website = var.enable_website
  versioning = var.versioning
  cloudfront_enabled = var.cloudfront_enabled
}

module "cloud_front" {
  count = var.cloudfront_enabled ? 1 : 0
  source = "../modules/cloud_front"
  bucket_name = var.bucket_name
  domine_names = var.domine_names
  bucket_domain_name = module.s3_bucket.bucket_domain
  bucket_arn = module.s3_bucket.bucket_arn
}