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

