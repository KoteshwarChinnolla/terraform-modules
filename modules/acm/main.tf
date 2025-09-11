resource "aws_acm_certificate" "cert_default" {
  count             = var.cirtificate_exists || var.root_domine != null ? 0 : 1
  domain_name       = var.domine_name
  validation_method = var.validation_method

  tags = {
    Environment = var.Environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "cert_with_root" {
  count             = var.root_domine != null ? 1 : 0
  domain_name       = var.domine_name
  validation_method = var.validation_method

  validation_option {
    domain_name       = var.domine_name
    validation_domain = var.root_domine
  }
}

locals {
  acm_certs = concat(
    aws_acm_certificate.cert_default[*],
    aws_acm_certificate.cert_with_root[*]
  )
}

resource "aws_route53_record" "example" {
  count = length(local.acm_certs) > 0 ? 1 : 0

  for_each = {
    for dvo in local.acm_certs[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.example.zone_id
}

# Lookup existing cert if it already exists (ISSUED state)
data "aws_acm_certificate" "issued" {
  domain      = var.domine_name
  statuses    = ["ISSUED"]
  most_recent = true
}

output "certificate_id" {
  value = length(local.acm_certs) > 0 ? local.acm_certs[0].arn : data.aws_acm_certificate.issued.arn
}




variable "cirtificate_exists" {
  type = bool
  description = "true to use already existing cirtificate, false to creat a new cirtificate"
}

variable "root_domine" {
  type = string
  description = "mection if any root domine exists so that CNAMES are not needed to be incerted again"
}

variable "domine_name" {
  type = string
  description = "mection the name of the domine to wich the cirtificate is for"
}

variable "validation_method" {
  type = string
  description = "It can be one of EMAIL or DNS"
}


variable "Environment" {
  type = string
  description = "it can be anything dev, test, prod .."
}