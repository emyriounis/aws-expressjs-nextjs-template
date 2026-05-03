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
      version = "6.37.0"
    }
  }

  backend "s3" {
    bucket       = "myriounis-terraform-state"
    key          = "aws-expressjs-nextjs-template/fetch_reactjs_config.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}

data "terraform_remote_state" "expressjs" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket = "myriounis-terraform-state"
    key    = "aws-expressjs-nextjs-template/expressjs.tfstate"
    region = "eu-central-1"
  }
}

variable "name" {
  type    = string
  default = "fs-template"
}

variable "enviroment" {
  type = string
}

variable "base_domain" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "global_region" {
  type    = string
  default = "us-east-1"
}

locals {
  env_prefix     = var.enviroment == "prod" ? "" : "${var.enviroment}."
  subdomain      = "${local.env_prefix}${var.name}.${var.base_domain}"
  reactjs_domain = "reactjs.${local.subdomain}"
}

resource "local_file" "reactjs_env" {
  content  = <<-EOT
REACT_APP_COGNITO_USER_POOL_ID=${data.terraform_remote_state.expressjs.outputs.cognito_user_pool_id}
REACT_APP_COGNITO_CLIENT_ID=${data.terraform_remote_state.expressjs.outputs.cognito_client_id}
REACT_APP_COGNITO_DOMAIN=${data.terraform_remote_state.expressjs.outputs.cognito_domain}
REACT_APP_EXPRESSJS_DOMAIN=${data.terraform_remote_state.expressjs.outputs.expressjs_domain}
REACT_APP_COGNITO_REDIRECT_SIGNIN=["http://localhost:3000", "https://${local.reactjs_domain}"]
REACT_APP_COGNITO_REDIRECT_SIGNOUT=["http://localhost:3000", "https://${local.reactjs_domain}"]
EOT
  filename = "${path.module}/reactjs.env"
}
