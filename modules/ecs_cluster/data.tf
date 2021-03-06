data "aws_caller_identity" "current" {}

data "aws_ami" "ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["591542846629"] # Canonical
}

data "aws_vpc" "main" {
  id = var.vpc_id
}
