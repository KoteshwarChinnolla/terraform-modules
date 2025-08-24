provider "aws" {
  region = "ap-south-1"
}


module "ec2_instance" {
  source = "../modules/ec2_instance"

  ami_id              = var.ami_id
  instance_type       = var.instance_type
  key_name            = var.key_name
  public_key_path     = var.public_key_path
  private_key_path    = var.private_key_path
  script_source       = var.script_source
  script_destination  = var.script_destination
  ssh_user            = var.ssh_user
  instance_name       = var.instance_name
  tags                = var.tags
  ingress_rules       = var.ingress_rules
}

