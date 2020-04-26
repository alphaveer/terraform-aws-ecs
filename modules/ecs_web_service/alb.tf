locals {
  target_group_name = "${var.service["name"]}-${local.ecs_cluster}"
}

resource "aws_lb_target_group" "main" {
  name                 = substr(local.target_group_name, 0, min(31, length(local.target_group_name)))
  port                 = "80"
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 10
  target_type          = "instance"

  health_check {
    protocol            = "HTTP"
    interval            = 20
    path                = var.alb["health_check_path"]
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = var.alb["health_check_matcher"]
  }

  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = var.alb["listener_arn"]
  priority     = var.alb["priority"]

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    field  = "host-header"
    values = [ "${var.alb["subdomain"]}.*" ]
  }

  depends_on = [ aws_lb_target_group.main ]
}
