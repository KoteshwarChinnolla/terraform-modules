data "aws_route53_zone" "primary" {
  count = var.domine_exists ? 1 : 0
  name  = var.domine_name
}

resource "aws_route53_zone" "my_domain_zone" {
  count = var.domine_exists ? 0 : 1
  name  = var.domine_name
}

# Choose zone_id from whichever exists
locals {
  zone_id = var.domine_exists ? data.aws_route53_zone.primary[0].zone_id : aws_route53_zone.my_domain_zone[0].zone_id
}

resource "aws_route53_record" "www-dev" {
  for_each = {
    for r in var.parms_to_enter : "${r.name}-${r.type}" => r
    if r.records != null && length(r.records) > 0
  }

  zone_id         = local.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 301
  allow_overwrite = each.value.allow_overwrite
  records         = compact(each.value.records)
}



variable "domine_exists" {
  type = bool
}

variable "domine_name" {
  type = string
}

variable "parms_to_enter" {
  description = "all the records to be entered into Route 53"
  type = list(object({
    name            = string
    type            = string
    allow_overwrite = bool
    records         = list(string)
  }))
  default = [
    {
      name            = "www"
      type            = "A"
      allow_overwrite = true
      records         = ["1.2.3.4"]
    },
    {
      name            = "mail"
      type            = "CNAME"
      allow_overwrite = true
      records         = ["mail.example.com"]
    }
  ]
}
