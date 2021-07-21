data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh")}"

  vars = {
    ecs_cluster = "${aws_ecs_cluster.main_cluster.name}"
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

resource "aws_autoscaling_policy" "main_asg_policy" {
  name                   = "${var.application_name}-cpu-scale-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.main_asg.name
  estimated_instance_warmup = 10

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}

resource "aws_autoscaling_group" "main_asg" {
  name                 = var.application_name
  launch_configuration = aws_launch_configuration.main_lc.name
  min_size             = var.target_capacity
  max_size             = var.target_capacity * 2
  health_check_type    = "EC2"
  health_check_grace_period = 10
  default_cooldown     = 30
  desired_capacity     = var.target_capacity
  vpc_zone_identifier  = data.aws_subnet_ids.subnets.ids
  wait_for_capacity_timeout = "3m"

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
    }
  }
}
