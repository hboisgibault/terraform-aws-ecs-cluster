#
# DATA
#

data "aws_subnet_ids" "subnets" {
  vpc_id = var.vpc_id
}

data "aws_alb" "alb" {
  arn  = var.alb_arn
}

#
# RESOURCES
#

resource "aws_ecs_cluster" "main_cluster" {
  name        = var.application_name

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
  launch_type     = "EC2"
  scheduling_strategy = "REPLICA"
  task_definition = "${data.aws_ecs_task_definition.main_td.family}:${data.aws_ecs_task_definition.main_td.revision}"
  desired_count   = var.target_capacity
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 10
  wait_for_steady_state = false
  force_new_deployment = true

  load_balancer {
    target_group_arn = aws_lb_target_group.main_tg.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  ordered_placement_strategy {
    type = "spread"
    field = "instanceId"
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