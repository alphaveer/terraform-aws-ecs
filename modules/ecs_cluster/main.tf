# Launch ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.name}-${terraform.workspace}"
}

resource "aws_security_group" "main" {
  name_prefix = "ecs.${var.name}.${terraform.workspace}"
  description = "Allow all VPC traffic for ECS Instances"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = list(data.aws_vpc.main.cidr_block)
    description = "Self VPC"
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
    description = "Self SG"
  }

  tags = {
    Name        = "ECS"
    Environment = terraform.workspace
  }
}
