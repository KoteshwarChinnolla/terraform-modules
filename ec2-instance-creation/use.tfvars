ami_id = "ami-02d26659fd82cf299"
instance_type = "t3.medium"
key_name = "my-key-pair"
public_key_path = "~/.ssh/deployer-key.pub"
private_key_path = "~/.ssh/deployer-key"
ssh_user = "ubuntu"
script_source = "./script.sh"
script_destination = "/home/ubuntu/script.sh"
instance_name = "testinginstance"
tags = {
  Environment = "Development"
  Project     = "TerraformDemo"
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
    }
  ]