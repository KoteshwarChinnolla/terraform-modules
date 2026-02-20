resource "aws_security_group" "this" {
  name_prefix = "${var.name}-alb-sg-"
  vpc_id      = var.vpc_id
  description = "ALB public access"

  dynamic "ingress" {
    for_each = var.listener_ports
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = var.allowed_cidrs
    }
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.this.id]
}

locals {
  create_certificate = var.https_required && var.certificate_arn == null
}

resource "aws_lb_target_group" "this" {
  for_each = var.routes

  name_prefix = substr(each.key, 0, 6)
  vpc_id      = var.vpc_id
  protocol    = each.value.protocol
  port        = each.value.target_port
  target_type = var.target_type

  health_check {
    enabled = true
    path    = var.health_check_path
    port    = "traffic-port"
    matcher = 200
  }
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.https_required ? "redirect" : "fixed-response"

    dynamic "redirect" {
      for_each = var.https_required ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "fixed_response" {
      for_each = var.https_required ? [] : [1]
      content {
        content_type = "text/plain"
        message_body = "Not Found"
        status_code  = "404"
      }
    }
  }
}


data "aws_route53_zone" "this" {
  count             = local.create_certificate ? 1 : 0
  name         = regex("([^.]+\\.[^.]+)$", var.domain_name)[0]
  private_zone = false
}


resource "aws_acm_certificate" "this" {
  count             = local.create_certificate ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = local.create_certificate ? {
    for dvo in aws_acm_certificate.this[0].domain_validation_options :
    dvo.domain_name => dvo
  } : {}

  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  count = local.create_certificate ? 1 : 0

  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

locals {
  effective_certificate_arn = try(
    var.certificate_arn,
    aws_acm_certificate_validation.this[0].certificate_arn
  )
}

resource "aws_lb_listener" "https" {
  count = var.https_required ? 1 : 0


  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = local.effective_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}


resource "aws_lb_listener_rule" "routes" {
  for_each = var.routes

  listener_arn = var.https_required? aws_lb_listener.https[0].arn : aws_lb_listener.http.arn

  priority = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }
}


