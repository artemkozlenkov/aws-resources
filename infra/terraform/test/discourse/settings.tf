provider "aws" {
  region = var.aws_region
  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.57"
    }
  }


  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kozlenkovde"
    workspaces {
      name = var.tfc_workspace
    }
  }
}

variable "aws_region" {}
variable "tfc_workspace" {}
