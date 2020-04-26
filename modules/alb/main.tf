# Security group to allow HTTP and HTTPS
resource "aws_security_group" "main" {
  name_prefix = "alb.${var.name}.${terraform.workspace}."
  description = "SG for Public ELB ${var.name}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

locals {
  lb_secutiry_groups = concat(list(aws_security_group.main.id), var.security_group_ids)
}

# Create ALB
resource "aws_lb" "main" {
  name               = "${var.name}-${terraform.workspace}"
  load_balancer_type = "application"
  internal           = var.internal
  subnets            = split(",", var.internal ? join(",", var.private_subnets) : join(",", var.public_subnets))
  security_groups    = local.lb_secutiry_groups

  tags = {
    Environment = terraform.workspace
  }
}

# Create HTTP listener, with redirect to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  depends_on = [ aws_lb.main ]
}
