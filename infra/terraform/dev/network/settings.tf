terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kozlenkovde"
    workspaces {
      name =  "network"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

