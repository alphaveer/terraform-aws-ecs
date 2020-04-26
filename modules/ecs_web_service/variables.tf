variable "vpc_id" {}

variable "ecs_cluster_arn" {}

variable "service" {
  type = map(string)
}

variable "alb" {
  type = map(string)
}

variable "ecr_repository_url" {}

variable "task_role_arn" {
  default = null
}

variable "environment_variables" {
  default = []
}

variable "service_command_overide" {
  default = []
}

variable "secrets" {
  default = []
}
