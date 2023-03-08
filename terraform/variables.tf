variable "default_region" {
  type    = string
  default = "sanitized"
}

variable "vpc_id" {
  type    = string
  default = "vpc-sanitized"
}

variable "ami_id" {
  type    = string
  default = "ami-sanitized" # Amazon Linux AMI 2. This changes based on your AWS region.
}

variable "instance_type" {
  type    = string
  default = "t2.medium"
}

# The key pair should exist in the targeted AWS account
variable "key_name" {
  type    = string
  default = "sanitized"
}

variable "private_subnet_id" {
  type    = string
  default = "subnet-sanitized"
}

# Adjust the default value to prevent ssh access from everywhere
variable "allowed_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "application" {
  type    = string
  default = "qa-sanitized-ccf"
}

variable "environment" {
  type    = string
  default = "qa"
}
