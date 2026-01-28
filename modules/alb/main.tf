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

resource "aws_lb_target_group" "this" {
  for_each = var.routes

  name_prefix = substr(each.key, 0, 6)
  vpc_id      = var.vpc_id
  protocol    = each.value.protocol
  port        = each.value.target_port
  target_type = "ip"

  health_check {
    enabled = true
    path    = var.health_check_path
    port    = each.value.target_port
    matcher = 200
  }
}


resource "aws_lb_listener" "this" {
  for_each = { for p in var.listener_ports : tostring(p) => p }

  load_balancer_arn = aws_lb.this.arn
  port              = each.value
  protocol          = var.protocol

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

  listener_arn = aws_lb_listener.this[tostring(var.listener_ports[0])].arn
  priority     = each.value.priority

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
