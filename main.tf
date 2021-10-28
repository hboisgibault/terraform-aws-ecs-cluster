#
# RESOURCES
#

resource "aws_ecs_cluster" "main_cluster" {
  name        = var.application_name
  capacity_providers = [aws_ecs_capacity_provider.main_cp.name]
  
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main_cp.name
    weight = 1
    base = 1
  }

  provisioner "local-exec" {
    when = destroy

    command = <<CMD
      aws autoscaling update-auto-scaling-group --auto-scaling-group-name ${self.name} --min-size 0 --max-size 0 --desired-capacity 0
      aws autoscaling delete-auto-scaling-group --auto-scaling-group-name ${self.name}
    CMD
  }

  tags = {
    Environment = var.environment_name
  }
}

data "aws_ecs_task_definition" "main_td" {
  task_definition = var.application_name
}

resource "aws_ecs_service" "main_service" {
  name            = var.application_name
  cluster         = aws_ecs_cluster.main_cluster.id
  scheduling_strategy = "REPLICA"
  task_definition = "${data.aws_ecs_task_definition.main_td.family}:${data.aws_ecs_task_definition.main_td.revision}"
  desired_count   = var.target_capacity
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 0
  wait_for_steady_state = false
  force_new_deployment = true

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main_cp.name
    base = 1
    weight = 1
  }

  dynamic "load_balancer" {
    for_each = var.use_alb ? [1] : []

    content {
      target_group_arn = aws_lb_target_group.main_tg.arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  ordered_placement_strategy {
    type = "binpack"
    field = "memory"
  }

  deployment_circuit_breaker {
    enable = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = {
    Environment = var.environment_name
  }
}