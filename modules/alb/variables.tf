variable "name" {
  type        = string
  description = "Base name for ALB"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "listener_ports" {
  type        = list(number)
  default     = [80]
}

variable "allowed_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
}


variable "health_check_path" {
  type    = string
  default = "/"
}


variable "routes" {
  type = map(object({
    priority     = number
    path_patterns = list(string)
    target_port  = number
    protocol     = string
  }))
}


variable "https_required" {
  type    = bool
  default = false
}

variable "domain_name" {
  type    = string
  default = null
}

# routes = {
#   cafe = {
#     priority     = 10
#     path_patterns = ["/api/cafe/*"]
#     target_port  = 8080
#     protocol     = "HTTP"
#   }

#   auth = {
#     priority     = 20
#     path_patterns = ["/api/auth/*"]
#     target_port  = 9000
#     protocol     = "HTTP"
#   }
# }
