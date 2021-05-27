terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kozlenkovde"
    workspaces {
      name = "network"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

output "vpc" {
  value = module.vpc
}

output "public_subnets" {
  value = module.vpc.public_subnets
}
output "private_subnets" {
  value = module.vpc.private_subnets
}
