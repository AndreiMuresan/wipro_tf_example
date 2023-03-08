terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  backend "s3" {
    bucket = "sanitized"
    key    = "qa/terraform.tfstate"
    region = "sanitized"
  }

  required_version = ">= 0.14.9"
}
