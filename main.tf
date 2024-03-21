terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38.0"
    }
  }
}

locals {
  environment = "Dev"
  name        = "cloudreslab"
  build_dir   = "${path.module}/build"
}
