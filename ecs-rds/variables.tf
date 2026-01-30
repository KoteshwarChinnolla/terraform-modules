variable "resource_name" {
  description = "Name of the resource"
  type        = string
  default     = "vpc"
}
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-2"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = []
}

variable "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = []
}

variable "availability_zones_private" {
  description = "List of availability zones for the VPC"
  type        = list(string)
  default     = []
}

variable "availability_zones_public" {
  description = "List of availability zones for public subnets"
  type        = list(string)
  default     = []
}

variable "db_username" {
  type        = string
  description = "RDS root user name"
}

variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

variable "db_names_and_schemas" {
  type = map(object({
    schemas = list(string)
  }))
}

variable "min_ecs_nodes" {
  type = string
}

variable "max_ecs_nodes" {
  type = string
}

variable "allowed_ingress_asg" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "services" {
  description = "Complete definition of all ECS services and ALB routing"
  type = map(object({
    image = object({
      repo = string
      tag  = string
      create_repo  = bool
    })

    compute = object({
      cpu    = number
      memory = number
    })

    networking = object({
      container_port = number
      host_port      = number
      path_patterns  = list(string)
    })
    secrets     = map(string)
    environment = map(string)

    scaling = object({
      desired = number
      min     = number
      max     = number
      cpu     = number
      memory  = number
    })
  }))
}


variable "asg_instance_type" {
  type = string
  default = "t2.micro"
}

variable "asg_instance_key" {
  type = string
  default = "coffee_key"
}

variable "alb_health_check_path" {
  type = string
  default = "/actuator/health"
}

variable "https_required" {
  type = bool
  default = false
}

variable "domain_name" {
  type = string
  default = ""
}

variable "task_role_managed_policy_arns" {
  type        = set(string)
  description = "Managed IAM policies to attach to ECS task role"
}

variable "exec_role_managed_policy_arns" {
  type        = set(string)
  description = "Managed IAM policies to attach to ECS task role"
}
