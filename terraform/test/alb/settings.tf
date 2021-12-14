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
      version = ">= 3.40.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kozlenkovde"
    workspaces {
      name = "alb"
    }
  }
}

data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "kozlenkovde"
    workspaces = {
      name = "network"
    }
  }
}

variable "aws_region" {}

output "target_group_arns" {
  value = module.alb.target_group_arns
}

output "dns" {
  value = module.alb.lb_dns_name
}

output "zone_id" {
  value = module.alb.lb_zone_id
}
