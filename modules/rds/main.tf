resource "aws_db_subnet_group" "this" {
  name       = var.resource_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.resource_name
  }
}

resource "aws_security_group" "this" {
  name   = "${var.resource_name}_rds"
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.resource_name
  }
}

resource "aws_db_parameter_group" "this" {
  name   = var.resource_name
  family = var.parameter_family

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "this" {
  identifier             = var.resource_name
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version

  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name  = aws_db_parameter_group.this.name

  publicly_accessible    = var.publicly_accessible
  skip_final_snapshot    = var.skip_final_snapshot

  backup_retention_period = var.db_retention_period
  backup_window           = var.backup_window

  tags = {
    Name = var.resource_name
  }
}



# provider "postgresql" {
#   host            = split(":", aws_db_instance.this.endpoint)[0]
#   port            = var.db_port
#   username        = var.db_username
#   password        = var.db_password
#   sslmode         = "require"
# }

# resource "postgresql_database" "app_db" {
#   for_each = var.enable_postgres_management ? var.db_names_and_schemas : {}

#   name  = each.key
#   owner = var.db_username
# }


# locals {
#   db_schemas = flatten([
#     for db, cfg in var.db_names_and_schemas : [
#       for schema in cfg.schemas : {
#         db     = db
#         schema = schema
#       }
#     ]
#   ])
# }


# resource "postgresql_schema" "app_schema" {
#   for_each = var.enable_postgres_management ? {
#     for s in local.db_schemas :
#     "${s.db}.${s.schema}" => s
#   } : {}

#   name     = each.value.schema
#   database = postgresql_database.app_db[each.value.db].name
#   owner    = var.db_username
# }



