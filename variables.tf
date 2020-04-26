variable "region" {
  default = "us-east-1"
}

variable "profile" {}

variable "name" {
  default = "terraform"
}

variable "ssh_key_name" {
  default = null
}

variable "ssl_certificate_arn" {}
