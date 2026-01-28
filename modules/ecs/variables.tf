variable "resource_name" { type = string }
variable "aws_region" { type = string }

variable "vpc_id" { type = string }
variable "vpc_cidr" { 
  type = string 
}
variable "subnet_ids" {
  type = list(string) 
}


variable "autoscaling_group_arn" {
  type = string
}

variable "services" {
  type = map(object({
    repo_name        = string
    image_tag        = string
    cpu              = number
    memory           = number
    container_port   = number
    host_port        = number
    desired_count    = number
    target_group_arn = string
    secrets          = map(string)
    environment      = map(string)
    create_repo      = bool
    autoscaling = object({
      min_capacity = number
      max_capacity = number
      cpu_target   = number
      mem_target   = number
    })
  }))
}

variable "buffer_capacity" {
  type = number
  default = 60
  description = "let you know how much capacity can be kept reserved"
}

variable "log_retention" {
  type = number
  default = 7
}

variable "task_role_managed_policy_arns" {
  type        = set(string)
  description = "Managed IAM policies to attach to ECS task role"
}

variable "exec_role_managed_policy_arns" {
  type        = set(string)
  description = "Managed IAM policies to attach to ECS task role"
}
