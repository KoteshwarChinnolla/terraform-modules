ami_id = "ami-0e7938ad51d883574"
instance_type = "t3.medium"
key_name = "coffee_key"
ssh_user = "ubuntu"
script_source = "./scripts"
script_destination = "/tmp/scripts"
instance_name = "chocolate"
tags = {
  Environment = "Development"
  Project     = "coffeeshop"
}
ingress_rules = [
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
    },
    {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port = 5432
      to_port = 5432
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
iam_policies = {
  s3_access = {
    statements = [
      {
        effect = "Allow"
        actions: [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        resources = [
          "arn:aws:s3:::coffeeshop-postgres-test-db",
          "arn:aws:s3:::coffeeshop-postgres-test-db/*"
        ]
      }
    ]
  }
}
managed_policy_arns = [ "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess" ]