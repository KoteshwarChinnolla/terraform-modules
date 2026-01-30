resource_name = "jjr-organics"
aws_region = "ap-south-2"
vpc_cidr_block = "10.0.0.0/16"
public_subnet_cidr_blocks = ["10.0.0.0/24", "10.0.2.0/24"]
private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]
availability_zones_private = ["ap-south-2a", "ap-south-2b"]
availability_zones_public = ["ap-south-2a", "ap-south-2b"]
db_username = "test_user"
db_password="koteshwar21"
db_names_and_schemas = {
    test_db = {
        schemas = ["jjr"]
      }
  }

asg_instance_type = "t3.small"
min_ecs_nodes = 1
max_ecs_nodes = 2
asg_instance_key = "jjr_key"

allowed_ingress_asg = [
  {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "183.82.104.156/32" ]
  }
]
https_required = true
domain_name = "backend.jjrorganics.com"

task_role_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
exec_role_managed_policy_arns = ["arn:aws:iam::aws:policy/SecretsManagerReadWrite"]

services = {
  jjr-organics = {
    image = {
      repo = "jjr-organics"
      tag  = "v0.0.5"
      create_repo  = true
    }

    compute = {
      cpu    = 512
      memory = 768
    }

    networking = {
      container_port = 8080
      host_port      = 8080
      path_patterns  = ["/*"]
    }
    secrets    = {
      # APP_JWT_SECRET = "arn:aws:secretsmanager:us-east-1:208940303379:secret:cafe_test/jwt/secret-GdGksm"
    }

    environment = {
    }

    scaling = {
      desired = 1
      min     = 1
      max     = 2
      cpu     = 75
      memory  = 75
    }
  }
}
