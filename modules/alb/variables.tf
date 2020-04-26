variable "name" {
  default = "shan"
}

variable "internal" {
  default = false
}

variable "vpc_id" {}

variable "private_subnets" {
  default = []
}

variable "public_subnets" {
  default = []
}

variable "security_group_ids" {
  default = []
}

variable "ssl_policy" {
  default = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "domain_name" {
  default = "shanux.com"
}

variable "subject_alternative_names" {
  type    = list(string)
  default = null
}
