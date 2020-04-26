resource "aws_ecs_service" "main" {
  name                               = var.service["name"]
  cluster                            = local.ecs_cluster
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = var.service["desired_count"]
  launch_type                        = "EC2"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  health_check_grace_period_seconds  = 60

  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.id
    container_name   = var.service["name"]
    container_port   = var.service["port"]
  }

  depends_on = [ aws_ecs_task_definition.main ]

  /*
  lifecycle {
    ignore_changes = ["*"]
  }*/
}

resource "aws_appautoscaling_target" "main" {
  max_capacity       = var.service["maximum_count"]
  min_capacity       = var.service["minimum_count"]
  resource_id        = "service/${local.ecs_cluster}/${var.service["name"]}"
  role_arn           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  depends_on         = [ aws_ecs_service.main ]
}

resource "aws_appautoscaling_policy" "main" {
  name               = "${var.service["name"]}-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "service/${local.ecs_cluster}/${var.service["name"]}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 50
  }

  depends_on = [ aws_appautoscaling_target.main ]
}
