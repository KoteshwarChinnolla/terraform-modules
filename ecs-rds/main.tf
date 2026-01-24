provider "aws" {
  region = "ap-south-2"
}

terraform {
  backend "s3" {
    bucket = "cafe-rds-ecs-backend"
    key    = "terraform/state"
    region = "ap-south-2"
  }
}


module "vpc" {
    source = "github.com/KoteshwarChinnolla/terraform-modules//modules/vpc"
    resource_name = var.resource_name
    vpc_cidr_block = var.vpc_cidr_block
    private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
    public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
    availability_zones_private = var.availability_zones_private
    availability_zones_public = var.availability_zones_public
    enable_nat = false
}

module "rds" {
  source = "../rds"

  resource_name = "${var.resource_name}-rds"

  subnet_ids = module.vpc.private_subnet_ids
  vpc_id     = module.vpc.vpc_id

  db_username = var.db_username
  db_password = var.db_password

  allowed_cidr_blocks = [var.vpc_cidr_block]
  publicly_accessible = false
  db_names_and_schemas = var.db_names_and_schemas
  enable_postgres_management = false
}

resource "aws_security_group" "temp_ec2_ssh" {
  name = "temp_ec2_ssh"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "temp_ec2_instance" {
  ami = "ami-0e7938ad51d883574"
  instance_type = "t3.micro"
  key_name = var.asg_instance_key
  subnet_id = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.temp_ec2_ssh.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${path.module}/rds_db_creation/${var.asg_instance_key}.pem")}"
    host        = self.public_ip
  }

  # Copy script to instance
  provisioner "file" {
    source      = "${path.module}/rds_db_creation/"
    destination = "/tmp"
  }
}


module "asg" {
  source = "../asg"

  resource_name    = "${var.resource_name}-asg"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.public_subnet_ids
  ecs_cluster_name = var.resource_name

  min_size = var.min_ecs_nodes
  max_size = var.max_ecs_nodes

  allowed_ingress = var.allowed_ingress_asg
  instance_type = var.asg_instance_type
  instance_key = var.asg_instance_key
}


module "alb" {
  source = "../alb"

  name       = "${var.resource_name}-alb"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  listener_ports   = [80, 443]
  protocol         = "HTTP"
  allowed_cidrs    = ["0.0.0.0/0"]
  health_check_path = var.alb_health_check_path

  routes = {
    for k, v in var.services :
    k => {
      priority      = 10 + index(keys(var.services), k) * 10
      path_patterns = v.networking.path_patterns
      target_port   = v.networking.container_port
      protocol      = "HTTP"
    }
  }
}


module "ecs" {
  source = "../ecs"

  resource_name = var.resource_name
  aws_region    = var.aws_region
  vpc_id        = module.vpc.vpc_id
  vpc_cidr      = var.vpc_cidr_block
  subnet_ids    = module.vpc.public_subnet_ids
  task_role_managed_policy_arns = var.task_role_managed_policy_arns
  exec_role_managed_policy_arns = var.exec_role_managed_policy_arns
  autoscaling_group_arn = module.asg.asg_arn

  services = {
    for k, v in var.services:
    k => {
      repo_name        = v.image.repo
      image_tag        = v.image.tag
      cpu              = v.compute.cpu
      memory           = v.compute.memory
      container_port   = v.networking.container_port
      host_port        = v.networking.host_port
      desired_count    = v.scaling.desired
      target_group_arn = module.alb.target_group_arns[k]
      secrets          = v.secrets
      environment      = merge(v.environment, {
        SPRING_DATASOURCE_URL="jdbc:postgresql://${module.rds.rds_endpoint}/test_db"
        SPRING_DATASOURCE_USERNAME=var.db_username
        SPRING_DATASOURCE_PASSWORD=var.db_password
      })
      create_repo      = v.image.create_repo
      autoscaling = {
        min_capacity = v.scaling.min
        max_capacity = v.scaling.max
        cpu_target   = v.scaling.cpu
        mem_target   = v.scaling.memory
      }
    }
  }
  depends_on = [ module.rds ]
}

