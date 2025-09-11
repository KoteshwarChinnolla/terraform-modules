resource "aws_acm_certificate" "cert_default" {
  count             = var.cirtificate_exists || var.root_domine != null ? 0 : 1
  domain_name       = var.domine_name
  validation_method = var.validation_method
  subject_alternative_names = var.alternative_domine_names

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

data "aws_route53_zone" "selected" {
  name = var.root_domine != null ? var.root_domine : var.domine_name
}

# Create validation records for the first certificate in locals
resource "aws_route53_record" "validation" {
  for_each = length(local.acm_certs) > 0 ? {
    for dvo in try(local.acm_certs[0].domain_validation_options, []) :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  count                   = length(local.acm_certs) > 0 ? 1 : 0
  certificate_arn         = local.acm_certs[0].arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

data "aws_acm_certificate" "issued" {
  domain      = var.domine_name
  statuses    = ["ISSUED"]
  most_recent = true
}

output "certificate_id" {
  value = length(local.acm_certs) > 0 ? local.acm_certs[0].arn : data.aws_acm_certificate.issued.arn
}

variable "cirtificate_exists" {
  type        = bool
  description = "true to use already existing cirtificate, false to creat a new cirtificate"
  default     = false
}

variable "root_domine" {
  type        = string
  description = "mention if any root domine exists so that CNAMES are not needed to be inserted again"
  default     = null
}

variable "domine_name" {
  type        = string
  description = "mention the name of the domine to which the cirtificate is for"
  default     = null
}

variable "alternative_domine_names" {
  type    = list(string)
  default = []
}

variable "validation_method" {
  type        = string
  description = "It can be one of EMAIL or DNS"
  default     = "DNS"
}

variable "Environment" {
  type        = string
  description = "it can be anything dev, test, prod .."
  default     = "prod"
}
