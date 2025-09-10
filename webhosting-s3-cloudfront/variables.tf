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
