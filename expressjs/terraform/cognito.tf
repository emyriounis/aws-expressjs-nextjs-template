data "aws_region" "current" {}

resource "aws_cognito_user_pool" "this" {
  name           = "${local.resource_prefix}-pool"
  user_pool_tier = "ESSENTIALS"

  alias_attributes    = ["email", "phone_number"]
  deletion_protection = var.enviroment == "prod" ? "ENABLED" : "INACTIVE"

  username_configuration {
    case_sensitive = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "${local.resource_prefix}-client"
  user_pool_id = aws_cognito_user_pool.this.id

  explicit_auth_flows           = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH"]
  prevent_user_existence_errors = "ENABLED"

  access_token_validity  = 8   #hours
  refresh_token_validity = 365 #days
  refresh_token_rotation {
    feature                    = "ENABLED"
    retry_grace_period_seconds = 60
  }

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]

  callback_urls = ["http://localhost:3000/"]
  logout_urls   = ["http://localhost:3000/"]

  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${local.resource_prefix}-auth"
  user_pool_id = aws_cognito_user_pool.this.id
}

