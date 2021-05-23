terraform {
 backend "remote" {
   hostname     = "app.terraform.io"
   organization = "kozlenkovde"

   workspaces {
     name = "kozlenkovde"
   }
 }

 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 2.0"
   }
 }
}