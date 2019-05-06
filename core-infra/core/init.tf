terraform {
  backend "s3" {
    region = "eu-central-1"
    bucket = "cdt-terraform"
    key = "core-infra.json"
  }
}

provider "aws" {
  region = "eu-central-1"
  version = "~> 1.9"
}