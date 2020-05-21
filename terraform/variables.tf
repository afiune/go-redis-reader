variable "lacework_agent_url" {}

variable "aws_profile" {}

variable "aws_region" {}

variable "aws_key_pair_file" {}

variable "aws_key_pair_name" {}

variable "tag_contact" {}

variable "tag_name" {}

variable "aws_ubuntu_image_user" {
  default = "ubuntu"
}

variable "instance_type" {
  default = "t3.small"
}

variable "ubuntu1804_count" {
  default = "1"
}

variable "tag_customer" {
  default = "demo-app"
}

variable "tag_project" {
  default = "go-redis-reader"
}

variable "tag_dept" {
  default = "demo-dept"
}

variable "tag_application" {
  default = "go-redis-reader"
}

variable "tag_ttl" {
  default = 4
}
