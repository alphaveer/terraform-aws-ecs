# Create SSL listener on ALB, with a default target group
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.ssl_certificate_arn
  // certificate_arn   = "${aws_acm_certificate_validation.main.certificate_arn}"

  default_action {
    target_group_arn = aws_lb_target_group.https_default.arn
    type             = "forward"
  }
  depends_on = [ aws_lb_target_group.https_default, aws_lb.main ]
}

locals {
  https_default_lb_target_group_name = "${var.name}-${terraform.workspace}-https-default"
}

resource "aws_lb_target_group" "https_default" {
  name                 = substr(local.https_default_lb_target_group_name, 0, min(31, length(local.https_default_lb_target_group_name)))
  port                 = "80"
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 10
  target_type          = "instance"

  health_check {
    protocol            = "HTTP"
    interval            = 20
    path                = "/"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-404"
  }

  tags = {
    Environment = "${terraform.workspace}"
  }
}
