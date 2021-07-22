data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh")}"

  vars = {
    ecs_cluster = var.application_name
  }
}

resource "aws_launch_configuration" "main_lc" {
  name          = var.application_name
  image_id      = var.ami_id
  instance_type = var.instance_type
  associate_public_ip_address = true
  iam_instance_profile = "arn:aws:iam::812844034365:instance-profile/ecsInstanceRole"
  security_groups = ["${aws_security_group.main_sg.id}"]

  root_block_device {
    volume_size = "30"
    volume_type = "gp3"
  }

  user_data = "${data.template_file.user_data.rendered}"
}

resource "aws_ecs_capacity_provider" "main_cp" {
  name = var.application_name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.main_asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_autoscaling_group" "main_asg" {
  name                 = var.application_name
  launch_configuration = aws_launch_configuration.main_lc.name
  min_size             = var.target_capacity
  max_size             = var.target_capacity * 2
  health_check_type    = "EC2"
  health_check_grace_period = 0
  default_cooldown     = 30
  desired_capacity     = var.target_capacity
  vpc_zone_identifier  = data.aws_subnet_ids.subnets.ids
  wait_for_capacity_timeout = "3m"

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
      instance_warmup = 10
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  tag {
    key = "AmazonECSManaged"
    value = ""
    propagate_at_launch = true
  }
}
