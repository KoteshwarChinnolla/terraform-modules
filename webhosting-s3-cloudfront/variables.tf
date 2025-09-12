variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "privacy" {
  description = "Bucket privacy setting (private, public, public-read)"
  type        = string
  default     = "private"
}

variable "folder_path" {
  description = "Local folder path for files to upload into S3"
  type        = string
  default     = ""
}

variable "enable_website" {
  description = "Enable S3 website hosting (true/false)"
  type        = bool
  default     = false
}

variable "versioning" {
  description = "Versioning status (Enabled, Suspended, or Disabled)"
  type        = string
  default     = "Disabled"
}

variable "cloudfront_enabled" {
  description = "Whether to enable CloudFront distribution"
  type        = bool
  default     = false
}

variable "domine_names" {
  description = "List of domain names (aliases) for CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "route_53_enable" {
  description = "true if you like to add recards to route53"
  type = bool
  default = false
}

variable "domine_exists" {
  type = bool
}

variable "domine_name" {
  type = string
}

variable "parms_to_enter" {
  description = "all the records to be entered into Route 53"
  type = list(object({
    name            = string
    type            = string
    allow_overwrite = bool
    records         = list(string)
  }))
  default = [
    {
      name            = "www"
      type            = "A"
      allow_overwrite = true
      records         = ["1.2.3.4"]
    },
    {
      name            = "mail"
      type            = "CNAME"
      allow_overwrite = true
      records         = ["mail.example.com"]
    }
  ]
}


variable "certificate_type" {
  type = string
  description = "true to use already existing cirtificate, false to creat a new cirtificate"
  default = false
}

variable "root_domine" {
  type = string
  description = "mection if any root domine exists so that CNAMES are not needed to be incerted again"
  default = null
}

variable "acm_domine_name" {
  type = string
  description = "mection the name of the domine to wich the cirtificate is for"
  default = null
}

variable "validation_method" {
  type = string
  description = "It can be one of EMAIL or DNS"
  default = "DNS"
}


variable "Environment" {
  type = string
  description = "it can be anything dev, test, prod .."
  default = "prod"
}

variable "cirtificate_arn" {
  type = string
  description = "enter the cirtificate arn if exists else cloudfron cirtificate is chosen, SSL required for route53"
  default = null
}