resource "aws_lb_target_group" "main_tg" {
  name     = var.application_name
  port     = 80
  protocol = "HTTP"
  protocol_version = "HTTP1" # DO NOT USE HTTP2, CONFLICTS WITH HEALTH CHECKS
  vpc_id   = var.vpc_id
  target_type = "instance"
  deregistration_delay = 60

  health_check {
    healthy_threshold = 2
    interval = 15
    timeout = 10
    matcher = "200-301"
  }
}

resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = var.alb_listener_arn
  priority     = var.alb_listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main_tg.arn
  }

  condition {
    host_header {
      values = [var.application_host]
    }
  }
}