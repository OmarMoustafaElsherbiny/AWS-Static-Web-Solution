terraform {
  # replace var.tfc_organization & var.tfc_workspace_name with their string values in CLI driven workflow
  cloud {
    organization = var.tfc_organization

    workspaces {
      name = var.tfc_workspace_name
    }
  }
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
  build_dir   = "build"
}
