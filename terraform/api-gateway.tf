module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "6.1.0"

  name        = "${local.repo}-api"
  description = "${local.repo} API"

  hosted_zone_name = var.base_domain
  domain_name      = local.expressjs_domain

  stage_access_log_settings = {
    create_log_group            = true
    log_group_retention_in_days = var.logs_retention
    format = jsonencode({
      context = {
        domainName     = "$context.domainName"
        domainPrefix   = "$context.domainPrefix"
        protocol       = "$context.protocol"
        requestId      = "$context.requestId"
        resourcePath   = "$context.resourcePath"
        requestTime    = "$context.requestTime"
        httpMethod     = "$context.httpMethod"
        path           = "$context.path"
        responseLength = "$context.responseLength"
        routeKey       = "$context.routeKey"
        stage          = "$context.stage"
        status         = "$context.status"
        error = {
          message      = "$context.error.message"
          responseType = "$context.error.responseType"
        }
        identity = {
          sourceIP = "$context.identity.sourceIp"
        }
        integration = {
          error                   = "$context.integration.error"
          integrationStatus       = "$context.integration.integrationStatus"
          integrationLatency      = "$context.integrationLatency"
          responseLatency         = "$context.responseLatency"
          integrationErrorMessage = "$context.integrationErrorMessage"
        }
      }
    })
  }

  cors_configuration = {
    allow_headers = ["*"]
    allow_origins = ["*"] #TODO: update
    allow_methods = ["*"]
  }

  authorizers = {
    "cognito" = {
      authorizer_type  = "JWT"
      identity_sources = ["$request.header.Authorization"]
      name             = "cognito-authorizer"
      jwt_configuration = {
        audience = [aws_cognito_user_pool_client.this.id]
        issuer   = "https://${aws_cognito_user_pool.this.endpoint}"
      }
    }
  }

  routes = {
    "ANY /heartbeat" = {
      authorization_type = "NONE"

      integration = {
        uri                    = module.lambda.lambda_function_arn
        payload_format_version = "2.0"
      }
    }

    "$default" = {
      authorization_type = "JWT"
      authorizer_key     = "cognito"

      integration = {
        uri                    = module.lambda.lambda_function_arn
        payload_format_version = "2.0"
      }
    }
  }
}
