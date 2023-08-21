provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "global_region"
  region = var.global_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }

  backend "s3" {
    bucket  = "prytanis-terraform-state"
    key     = "aws-expressjs-nextjs-template/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

data "aws_route53_zone" "base_domain" {
  name = var.base_domain
}
