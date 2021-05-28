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
      name = "route53"
    }
  }
}

variable "fqdn" {}
variable "aws_region" {}

data "aws_route53_zone" "blog" {
  name         = var.fqdn
  private_zone = false
}
data "terraform_remote_state" "alb" {
  backend = "remote"

  config = {
    organization = "kozlenkovde"
    workspaces = {
      name = "alb"
    }
  }
}

resource "aws_route53_record" "www_forum" {
  zone_id = data.aws_route53_zone.blog.zone_id
  name    = "forum.${var.fqdn}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.alb.outputs.dns_name
    zone_id                = data.terraform_remote_state.alb.outputs.zone_id
    evaluate_target_health = true
  }
}

output "forum_address" {
  value = aws_route53_record.www_forum.fqdn
}
