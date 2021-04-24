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
  region = "eu-central-1"
}

