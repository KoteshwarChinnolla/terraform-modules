resource "aws_ecs_cluster" "this" {
  name = var.resource_name
}

# ---------- IAM ----------
data "aws_iam_policy_document" "ecs_task_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task" {
  name_prefix        = "${var.resource_name}-task-"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role_policy_attachment" "task_managed" {
  for_each = var.task_role_managed_policy_arns

  role       = aws_iam_role.task.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "exec_managed" {
  for_each = var.exec_role_managed_policy_arns

  role       = aws_iam_role.exec.name
  policy_arn = each.value
}

resource "aws_iam_role" "exec" {
  name_prefix        = "${var.resource_name}-exec-"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role_policy_attachment" "exec" {
  role       = aws_iam_role.exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---------- Logs ----------
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.resource_name}"
  retention_in_days = var.log_retention
}

# ---------- Capacity Provider ----------
resource "aws_ecs_capacity_provider" "this" {
  name = "${var.resource_name}-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn = var.autoscaling_group_arn

    managed_scaling {
      status          = "ENABLED"
      target_capacity = var.buffer_capacity
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.this.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 100
  }
}

# ---------- ECR ----------
resource "aws_ecr_repository" "this" {
  for_each = {
    for k, v in var.services :
    k => v
    if v.create_repo
  }

  name = each.value.repo_name
}

data "aws_ecr_repository" "this" {
  for_each = {
    for k, v in var.services :
    k => v
    if v.create_repo == false
  }

  name = each.value.repo_name
}

locals {
  ecr_urls = merge(
    {
      for k, v in aws_ecr_repository.this :
      k => v.repository_url
    },
    {
      for k, v in data.aws_ecr_repository.this :
      k => v.repository_url
    }
  )
}


# ---------- Task Definitions ----------
resource "aws_ecs_task_definition" "this" {
  for_each = var.services

  family             = "${var.resource_name}-${each.key}"
  task_role_arn      = aws_iam_role.task.arn
  execution_role_arn = aws_iam_role.exec.arn
  network_mode       = "awsvpc"
  cpu                = each.value.cpu
  memory             = each.value.memory

  container_definitions = jsonencode([{
    name      = each.key
    image = "${local.ecr_urls[each.key]}:${each.value.image_tag}"
    essential = true

    portMappings = [{
      containerPort = each.value.container_port
    }]

    secrets = [
      for k, v in each.value.secrets :
      { name = k, valueFrom = v }
    ]

    environment = [
      for k, v in each.value.environment :
      { name = k, value = v }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = var.aws_region
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-stream-prefix = each.key
      }
    }
  }])
}

# ---------- Security Group ----------
resource "aws_security_group" "ecs" {
  name_prefix = "${var.resource_name}-ecs-"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- Services ----------
resource "aws_ecs_service" "this" {
  for_each = var.services

  name            = each.key
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this[each.key].arn
  desired_count   = each.value.desired_count

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 100
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = each.value.target_group_arn
    container_name   = each.key
    container_port   = each.value.container_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_appautoscaling_target" "ecs" {
  for_each = var.services

  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  resource_id = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this[each.key].name}"

  min_capacity = each.value.autoscaling.min_capacity
  max_capacity = each.value.autoscaling.max_capacity
}

resource "aws_appautoscaling_policy" "cpu" {
  for_each = var.services

  name               = "${each.key}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.ecs[each.key].service_namespace
  resource_id        = aws_appautoscaling_target.ecs[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs[each.key].scalable_dimension

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = each.value.autoscaling.cpu_target
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_policy" "memory" {
  for_each = var.services

  name               = "${each.key}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.ecs[each.key].service_namespace
  resource_id        = aws_appautoscaling_target.ecs[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs[each.key].scalable_dimension

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = each.value.autoscaling.mem_target
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

