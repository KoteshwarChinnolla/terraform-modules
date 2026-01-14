resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  subnet_id     = var.subnet_id

  # Common SSH connection for all provisioners
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = var.private_key
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
      "sudo chmod +x ${var.script_destination}",
      "if [ \"${var.execute}\" = \"true\" ]; then sudo ${var.script_destination}; fi"
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

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name               = "${var.instance_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "aws_iam_policy_document" "dynamic" {
  for_each = var.iam_policies

  dynamic "statement" {
    for_each = each.value.statements
    content {
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}


resource "aws_iam_policy" "dynamic" {
  for_each = var.iam_policies

  name = "${var.instance_name}-${each.key}"
  policy = data.aws_iam_policy_document.dynamic[each.key].json
}

resource "aws_iam_role_policy_attachment" "dynamic" {
  for_each = aws_iam_policy.dynamic

  role       = aws_iam_role.role.name
  policy_arn = each.value.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.instance_name}-profile"
  role = aws_iam_role.role.name
}


resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.role.name
  policy_arn = each.value
}