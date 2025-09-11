resource "aws_acm_certificate" "ROOT_CERT" {
  count             = var.certificate_type == "ROOT_CERT" ? 1 : 0
  domain_name       = var.domain_name
  validation_method = var.validation_method
  subject_alternative_names = var.alternative_domain_names

  tags = {
    Environment = var.Environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "SUB_ROOT_CERT" {
  count             = var.root_domain != null && var.certificate_type == "SUB_ROOT_CERT" ? 1 : 0
  domain_name       = var.domain_name
  validation_method = var.validation_method

  validation_option {
    domain_name       = var.domain_name
    validation_domain = var.root_domain
  }
}

data "aws_route53_zone" "selected" {
  name = coalesce(var.root_domain, var.domain_name)
}

resource "aws_route53_record" "validation" {
  count = var.root_domain != null && var.certificate_type == "SUB_ROOT_CERT" ? 1 : 0
  depends_on = [ aws_acm_certificate.SUB_ROOT_CERT ]
  for_each = {
    for dvo in tolist(aws_acm_certificate.SUB_ROOT_CERT[0].domain_validation_options) : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.selected.zone_id
}

resource "aws_route53_record" "validation" {
  count = var.certificate_type == "ROOT_CERT" ? 1 : 0
  depends_on = [ aws_acm_certificate.ROOT_CERT ]
  for_each = {
    for dvo in tolist(aws_acm_certificate.ROOT_CERT[0].domain_validation_options) : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.selected.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn = coalesce(
    try(aws_acm_certificate.ROOT_CERT[0].arn, null),
    try(aws_acm_certificate.SUB_ROOT_CERT[0].arn, null)
  )

  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

data "aws_acm_certificate" "issued" {
  count = var.certificate_type == "EXISTING" ? 1 : 0
  
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

output "certificate_arn" {
  value = var.certificate_type == "ROOT_CERT" ? try(aws_acm_certificate.ROOT_CERT[0].arn, null) : var.certificate_type == "SUB_ROOT_CERT" ? try(aws_acm_certificate.SUB_ROOT_CERT[0].arn, null) : var.certificate_type == "EXISTING" ? try(data.aws_acm_certificate.issued[0].arn, null) : null
}

variable "certificate_type" {
  type        = string
  description = "Certificate type: 'ROOT_CERT', 'SUB_ROOT_CERT', or 'EXISTING'"
  default     = "EXISTING"
}

variable "root_domain" {
  type        = string
  description = "mention if any root domain exists so that CNAMES are not needed to be inserted again"
  default     = null
}

variable "domain_name" {
  type        = string
  description = "mention the name of the domain to which the certificate is for"
  default     = null
}

variable "alternative_domain_names" {
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