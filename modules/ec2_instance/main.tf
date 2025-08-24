resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  # Common SSH connection for all provisioners
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  # Copy script to instance
  provisioner "file" {
    source      = var.script_source
    destination = var.script_destination
  }

  # Make script executable
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${var.script_destination}"
    ]
  }

  vpc_security_group_ids = [aws_security_group.example.id]

  tags = merge(
    {
      Name = var.instance_name
    },
    var.tags
  )
}



resource "aws_security_group" "example" {
  name        = "${var.instance_name}-sg"
  description = "Allow multiple ingress rules"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}


data "http" "myip" {
  url = "https://checkip.amazonaws.com/"
}
