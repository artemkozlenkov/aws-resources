locals {
  name        = "cluster"
  environment = "dev"
}

variable "private-subnets" {
  type = list(string)
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}
variable "public-subnets" {
  type = list(string)
  default = ["10.1.11.0/24", "10.1.12.0/24"]
}

variable "aws_region" {
  default = "eu-central-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = local.name

  cidr = "10.1.0.0/16"

  azs = data.aws_availability_zones.available.names

  private_subnets = var.private-subnets
  private_subnet_tags = {
    Name = "private-subnet"
  }

  public_subnets = var.public-subnets
  public_subnet_tags = {
    Name = "public-subnet"
  }

  enable_nat_gateway = false # false is just faster

  tags = {
    Environment = local.environment
    Name        = local.name
  }
}
