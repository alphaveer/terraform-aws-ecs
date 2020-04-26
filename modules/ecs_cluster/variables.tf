variable "name" {
  default     = "Terraform"
  description = "ECS Cluster Name"
}

variable "instance_type" {
  default     = "t3.medium"
  description = "ECS Cluster Instance Type"
}

variable "ssh_key_name" {}

variable "vpc_id" {
  description = "VPC ID to deploy the ECS Cluster"
}

variable "subnets" {
  default     = []
  description = "List of Subnets to deploy the ECS Cluster Instances"
}

variable "cluster_size" {
  default = {
    minimum = 1
    maximum = 1
    desired = 1
  }
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}
