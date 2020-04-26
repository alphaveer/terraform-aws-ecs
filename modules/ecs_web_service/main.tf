locals {
  ecs_cluster = element(split("/", var.ecs_cluster_arn), length(split("/", var.ecs_cluster_arn)) - 1)
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${local.ecs_cluster}/${var.service["name"]}"
  retention_in_days = 7

  tags = {
    Environment = terraform.workspace
  }
}

data "template_file" "main" {
  template = file("${path.module}/task-definition.json")

  vars = {
    DOCKER_IMAGE   = var.ecr_repository_url
    SERVICE_MEMORY = var.service["memory"]
    SERVICE_CPU    = var.service["cpu"]
    SERVICE_NAME   = var.service["name"]
    SERVICE_PORT   = var.service["port"]
    ENVIRONMENT    = jsonencode(var.environment_variables)
    SECRETS        = jsonencode(var.secrets)
    LOG_GROUP      = aws_cloudwatch_log_group.main.name
    AWS_REGION     = data.aws_region.current.name
    COMMAND        = jsonencode(var.service_command_overide)
  }
}

resource "aws_ecs_task_definition" "main" {
  family                = "${local.ecs_cluster}-${var.service["name"]}"
  network_mode          = "bridge"
  container_definitions = data.template_file.main.rendered
  task_role_arn         = var.task_role_arn
  execution_role_arn    = var.task_role_arn

  # Need this config for terraform to ignore changes made by Jenkins
  /*lifecycle {
    ignore_changes = ["*"]
  }*/
}
