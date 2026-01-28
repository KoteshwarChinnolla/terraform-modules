variable "resource_name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "ecs_cluster_name" { type = string }

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "instance_key" {
  type = string
  default = "string"
}

variable "market_type" {
  type    = string
  default = "spot"
}

variable "min_size" { type = number }
variable "max_size" { type = number }

variable "ecs_ami_ssm_path" {
  type    = string
  default = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

variable "allowed_ingress" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
