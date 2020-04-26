resource "aws_launch_configuration" "main" {
  name_prefix                 = "${var.name}.${terraform.workspace}."
  image_id                    = data.aws_ami.ecs.image_id
  instance_type               = var.instance_type
  security_groups             = concat(list(aws_security_group.main.id), var.security_group_ids)
  user_data                   = templatefile("${path.module}/templates/user_data.sh", { ecs_cluster_name = "${var.name}-${terraform.workspace}" })
  key_name                    = var.ssh_key_name
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_role.id
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs" {
  name_prefix          = "${var.name}.${terraform.workspace}."
  max_size             = var.cluster_size["maximum"]
  min_size             = var.cluster_size["minimum"]
  desired_capacity     = var.cluster_size["desired"]
  force_delete         = true
  launch_configuration = aws_launch_configuration.main.id
  vpc_zone_identifier  = var.subnets

  tag {
    key                 = "Name"
    value               = "ecs.${var.name}.${terraform.workspace}"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "Cluster"
    value               = "${var.name}-${terraform.workspace}"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "Environment"
    value               = terraform.workspace
    propagate_at_launch = "true"
  }

  depends_on = [ aws_ecs_cluster.main ]
}

resource "aws_autoscaling_policy" "up" {
  name                   = "ecs-${var.name}-${terraform.workspace}-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ecs.name
}

resource "aws_autoscaling_policy" "down" {
  name                   = "ecs-${var.name}-${terraform.workspace}-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ecs.name
}

resource "aws_cloudwatch_metric_alarm" "up" {
  alarm_name          = "ecs-${var.name}-${terraform.workspace}-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = "${var.name}-${terraform.workspace}"
  }

  alarm_description = "This metric monitors ecs memory reservation"
  alarm_actions     = [ aws_autoscaling_policy.up.arn ]
}

resource "aws_cloudwatch_metric_alarm" "down" {
  alarm_name          = "ecs-${var.name}-${terraform.workspace}-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "75"

  dimensions = {
    ClusterName = "${var.name}-${terraform.workspace}"
  }

  alarm_description = "This metric monitors ecs memory reservation"
  alarm_actions     = [ aws_autoscaling_policy.down.arn ]
}
