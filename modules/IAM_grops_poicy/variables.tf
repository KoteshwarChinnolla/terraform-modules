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

variable "policy_name" {
  description = "The name of the IAM policy"
  type        = string
  default     = "example_policy"
}

variable "group_name" {
  description = "The name of the IAM group to attach the policy to"
  type        = string
  default     = "example_group"
  
}

variable "user_name" {
  description = "IAM User name"
  type = string
  default = "example_user"
}