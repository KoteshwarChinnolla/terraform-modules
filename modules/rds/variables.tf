variable "resource_name" {
  type        = string
  description = "Base name for RDS resources"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for RDS subnet group"
}


variable "vpc_id" {
  type        = string
  description = "VPC ID for RDS security group"
}

variable "db_username" {
  type        = string
  description = "Master username"
}

variable "db_password" {
  type        = string
  description = "Master password"
  sensitive   = true
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type        = number
  default     = 40
}

variable "engine" {
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  type        = string
  default     = "15"
}

variable "parameter_family" {
  type        = string
  default     = "postgres15"
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "publicly_accessible" {
  type    = bool
  default = true
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "Who can connect to RDS"
  default     = ["0.0.0.0/0"]
}

variable "db_names_and_schemas" {
  type = map(object({
    schemas = list(string)
  }))
  default = {}
}

variable "enable_postgres_management" {
  type        = bool
  description = "Enable PostgreSQL database/schema management"
  default     = false
}

variable "max_allocated_storage" {
  type = number
  default = 100
}

variable "backup_retention_period" {
  type = number
  default = 5
}

variable "backup_window" {
  type = string
  default = "03:00-04:00"
}

variable "db_retention_period" {
  type = number
  default = 7
}