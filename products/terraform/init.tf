terraform {
  backend "s3" {
    region = "eu-central-1"
    bucket = "cdt-terraform"
    key    = "products.json"
  }
}

provider "aws" {
  region  = "eu-central-1"
  version = "~> 1.9"
}
