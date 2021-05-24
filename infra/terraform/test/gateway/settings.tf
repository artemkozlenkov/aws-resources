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


  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kozlenkovde"
    workspaces {
      name = "gateway"
    }
  }
}

variable "aws_region" {}
variable "instance_type" {
  default = "t2.micro"
}

data "aws_vpc" "selected" {
  tags = {
    Name = "cluster"
  }
}
data "aws_subnet_ids" "public-all" {
  filter {
    name   = "tag:Name"
    values = ["public-subnet"]
  }
  vpc_id = data.aws_vpc.selected.id
}
data "aws_subnet" "public" {
  for_each = data.aws_subnet_ids.public-all.ids
  id       = each.value
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
