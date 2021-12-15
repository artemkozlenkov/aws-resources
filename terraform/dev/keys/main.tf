provider "aws" {
  region = "eu-central-1"
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
}


resource "aws_key_pair" "single_ec2_ssh_key" {
  public_key = file("~/.ssh/aws_private.pub")
  key_name   = "dev"
}