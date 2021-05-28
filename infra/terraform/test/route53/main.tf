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

variable "blog_fqdn" {}
variable "aws_region" {}

data "aws_route53_zone" "blog" {
  name         = var.blog_fqdn
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

resource "aws_route53_record" "www-blog" {
  zone_id = data.aws_route53_zone.blog.zone_id
  name    = var.blog_fqdn
  type    = "A"
  ttl     = "300"
  records = [data.terraform_remote_state.alb.outputs.public_dns]
}


