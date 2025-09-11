variable "bucket_name" {
  description = "Bucket name for the S3 bucket"
  type        = string
}

variable "domine_names" {
  description = "List of domain names (aliases) for CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "bucket_domain_name" {
  description = "Domain name of the S3 bucket used as origin for CloudFront"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket used as origin for CloudFront"
  type        = string
}

variable "cirtificate_arn" {
  type = string
  description = "enter the cirtificate arn if exists else cloudfron cirtificate is chosen, SSL required for route53"
}