locals {
  name        = "cluster"
  environment = "dev"
}

variable "private-subnets" {
  type    = list(string)
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}
variable "public-subnets" {
  type    = list(string)
  default = ["10.1.11.0/24", "10.1.12.0/24"]
}
variable "aws_region" {}

data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_subnet_ids" "public" {
  vpc_id = module.vpc.vpc_id
  filter {
    name   = "tag:Name"
    values = ["public*"]
  }
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = local.name

  cidr = "10.1.0.0/16"

  azs = data.aws_availability_zones.available.names

  private_subnets = var.private-subnets
  enable_nat_gateway  = true
  single_nat_gateway  = false
  reuse_nat_ips       = true
  external_nat_ip_ids = aws_eip.nat.*.id
  private_subnet_tags = {
    Name = "private-subnet"
  }

  public_subnets = var.public-subnets
  public_subnet_tags = {
    Name = "public-subnet"
  }

  tags = {
    Environment = local.environment
    Name        = local.name
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(tolist(data.aws_subnet_ids.public.ids), 0)
}
