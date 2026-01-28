variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "ssh_user" {
  description = "SSH user (depends on AMI: ubuntu/ec2-user)"
  type        = string
  default     = "ubuntu"
}

variable "script_source" {
  description = "Local path to the script file"
  type        = string
  default     = "./script.sh"
}

variable "script_destination" {
  description = "Path on remote instance to copy script"
  type        = string
  default     = "/home/ubuntu/script.sh"
}

variable "instance_name" {
  description = "Tag: Name of the instance"
  type        = string
  default = "MyEC2Instance"
}

variable "tags" {
  description = "Extra tags for the instance"
  type        = map(string)
  default     = {}
}


variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "ebs_availability_zone" {
  description = "Availability zone for the EBS volume"
  type        = string
  default     = "ap-south-2a"
}

variable "ebs_volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 20
}

variable "device_name" {
  description = "type of ebs volume"
  type = string
  default = "/dev/xvdbf"
}

variable "iam_policies" {
  description = "Map of IAM policies to attach to EC2 role"
  type = map(object({
    statements = list(object({
      effect    = string
      actions   = list(string)
      resources = list(string)
    }))
  }))
  default = {}
}

variable "managed_policy_arns" {
  description = "aws managed policy "
  type = list(string)
  default = []
}