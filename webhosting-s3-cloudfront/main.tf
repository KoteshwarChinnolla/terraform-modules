provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "hrms-anasol-frontend-terraform-backend"
    key    = "terraform/state"
    region = "us-east-1"
  }
}

module "s3_bucket" {
  source              = "github.com/KoteshwarChinnolla/terraform-modules//modules/s3_bucket"
  bucket_name         = var.bucket_name
  privacy             = var.privacy
  folder_path         = var.folder_path
  enable_website      = var.enable_website
  versioning          = var.versioning
  cloudfront_enabled  = var.cloudfront_enabled
}

module "cirtificate" {
  source = "github.com/KoteshwarChinnolla/terraform-modules//modules/acm_SUB_ROOT_CERT"
  certificate_type = var.certificate_type
  root_domain = var.domine_name
  domain_name = var.acm_domine_name
  validation_method = var.validation_method
  Environment = var.Environment
  alternative_domain_names = var.domine_names
}

module "cloud_front" {
  depends_on = [ module.s3_bucket, module.cirtificate ]
  count              = var.cloudfront_enabled ? 1 : 0
  source             = "github.com/KoteshwarChinnolla/terraform-modules//modules/cloud_front"
  bucket_name        = var.bucket_name
  domine_names       = var.domine_names
  bucket_domain_name = module.s3_bucket.bucket_domain
  bucket_arn         = module.s3_bucket.bucket_arn
  cirtificate_arn    = module.cirtificate.certificate_arn
}

output "cloud_front_distribution_id" {
  value = var.cloudfront_enabled ? module.cloud_front[0].cloud_front_distribution_id : null
}

module "route_53" {
  count         = var.route_53_enable ? 1 : 0
  source        = "github.com/KoteshwarChinnolla/terraform-modules//modules/route_53"
  domine_exists = var.domine_exists
  domine_name   = var.domine_name

  parms_to_enter = var.parms_to_enter
  alias_record = var.cloudfront_enabled ? {
    name            = "techlife"
    type            = "A"
    allow_overwrite = true
    alias = {
      name                   = module.cloud_front[0].cloud_front_domain
      zone_id                = module.cloud_front[0].cloud_front_hosted_zone_id
      evaluate_target_health = true
    }
  } : null
}