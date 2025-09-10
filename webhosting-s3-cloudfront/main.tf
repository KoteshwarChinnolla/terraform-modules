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
  source              = "../modules/s3_bucket"
  bucket_name         = var.bucket_name
  privacy             = var.privacy
  folder_path         = var.folder_path
  enable_website      = var.enable_website
  versioning          = var.versioning
  cloudfront_enabled  = var.cloudfront_enabled
}

module "cloud_front" {
  count              = var.cloudfront_enabled ? 1 : 0
  source             = "../modules/cloud_front"
  bucket_name        = var.bucket_name
  domine_names       = var.domine_names
  bucket_domain_name = module.s3_bucket.bucket_domain
  bucket_arn         = module.s3_bucket.bucket_arn
}

locals {
  cloud_front_domain = var.cloudfront_enabled ? module.cloud_front[0].cloud_front_domain : null

  recards = concat(
    var.parms_to_enter,
    [
      for d in var.domine_names : {
        name            = d
        type            = "A"
        allow_overwrite = true
        records         = [local.cloud_front_domain]
      }
    ]
  )
}

module "route_53" {
  count          = var.route_53_enable ? 1 : 0
  source         = "../modules/route_53"
  depends_on     = [module.cloud_front]
  domine_exists  = var.domine_exists
  domine_name    = var.domine_name
  parms_to_enter = local.recards
}