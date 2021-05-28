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
      name = "discourse-test"
    }
  }
}

variable "aws_region" {}
variable "asg_name" {}
variable "instance_type" {
  default = "t3a.small"
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*-discourse-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"] # Canonical
}
data "aws_ami" "discourse" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["*discourse*"]
  }
}
data "aws_vpc" "cluster" {
  filter {
    name   = "tag:Name"
    values = ["cluster"]
  }
}
data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.cluster.id
  filter {
    name   = "tag:Name"
    values = ["private*"]
  }
}
data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.cluster.id
  filter {
    name   = "tag:Name"
    values = ["public*"]
  }
}
data "template_file" "init" {
  template = "${file("${path.module}/init.sh")}"
  vars = {
    //    consul_address = "${aws_instance.consul.private_ip}"
  }
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
