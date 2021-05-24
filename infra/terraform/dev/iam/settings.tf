terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kozlenkovde"
    workspaces {
      name =  "iam-discourse"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

