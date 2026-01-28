provider "aws" {
  region = "ap-south-2"
}

terraform {
  backend "s3" {
    bucket = "coffeeshop-backend-terraform-state"
    key    = "terraform/state"
    region = "ap-south-2"
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/${var.key_name}.pem"
  file_permission = "0600"
}

module "ec2_instance" {
  source = "github.com/KoteshwarChinnolla/terraform-modules/modules/ec2_instance"

  ami_id              = var.ami_id
  instance_type       = var.instance_type
  key_name            = var.key_name
  public_key          = tls_private_key.ssh_key.public_key_openssh
  private_key         = tls_private_key.ssh_key.private_key_pem
  script_source       = var.script_source
  script_destination  = var.script_destination
  ssh_user            = var.ssh_user
  instance_name       = var.instance_name
  tags                = var.tags
  ingress_rules       = var.ingress_rules
  execute             = false
  iam_policies        = var.iam_policies
  managed_policy_arns = var.managed_policy_arns
}


resource "aws_ebs_volume" "ebs_vol" {
  availability_zone = var.ebs_availability_zone
  size = var.ebs_volume_size
  depends_on = [ module.ec2_instance ]
  tags = {
    Name = "cafe" 
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = var.device_name
  volume_id   = aws_ebs_volume.ebs_vol.id
  instance_id = module.ec2_instance.instance_id
  depends_on = [ aws_ebs_volume.ebs_vol ]
}