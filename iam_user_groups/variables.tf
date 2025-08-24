variable "user_name" {
  description = "Name of the IAM user"
  type        = string
  default     = "example_user"
}

variable "group_name" {
  description = "Name of the IAM group"
  type        = string
  default     = "example_group"
}

variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = "example_policy"
}

variable "statements" {
  description = "A map of IAM policy statements"
  type = list(object({
    actions   = list(string)
    resources = list(string)
    effect    = string
  }))
  default = [{
    actions   = ["s3:*"]
    resources = ["*"]
    effect    = "Allow"
  }]
}