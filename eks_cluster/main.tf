provider "aws" {
  region = "ap-south-1"
}

# terraform {
#   backend "s3" {
#     bucket = "anasolbackendhrms"
#     key    = "terraform/state"
#     region = "us-east-1"
#   }
# }


module "vpc" {
    source = "../modules/vpc"
    resource_name = var.resource_name
    vpc_cidr_block = var.vpc_cidr_block
    private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
    public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
    availability_zones_private = var.availability_zones_private
    availability_zones_public = var.availability_zones_public
}


module "eks" {
    source = "../modules/eks"
    resource_name = var.resource_name
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnet_ids
    kubernetes_version = var.kubernetes_version
    master_iam_role_name = var.master_iam_role_name
    worker_iam_role_name = var.worker_iam_role_name
    node_group = var.node_group

    depends_on = [ module.vpc ]
}