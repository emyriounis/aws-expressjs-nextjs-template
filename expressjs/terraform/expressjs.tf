resource "aws_lambda_layer_version" "expressjs_layer" {
  filename   = "../layer.zip"
  layer_name = "${local.resource_prefix}-layer"

  source_code_hash    = filebase64sha256("../layer.zip")
  compatible_runtimes = [var.runtime]
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7.0"

  function_name = "${local.resource_prefix}-expressjs-lambda"
  description   = "${local.resource_prefix} ExpressJS"

  runtime                      = var.runtime
  memory_size                  = var.lambda_memory_size
  ephemeral_storage_size       = 512
  timeout                      = 30
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0

  create_package         = false
  local_existing_package = "../source.zip"
  handler                = "server.handler"

  publish = true
  layers  = [aws_lambda_layer_version.expressjs_layer.arn]

  cloudwatch_logs_retention_in_days = var.logs_retention
  # dead_letter_target_arn

  attach_network_policy  = true
  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]

  cors = {
    allow_credentials = true
    allow_origins     = ["*"] #TODO: update
    allow_methods     = ["*"]
  }

  environment_variables = {
    NODE_ENV = "prod"
    ENV      = var.environment
    # AURORA_CLUSTER_ARN = aws_rds_cluster.aurora.arn
    # SECRET_ARN         = aws_secretsmanager_secret.db_credentials.arn
    # DATABASE_NAME      = aws_rds_cluster.aurora.database_name
    DATABASE_URL = "postgresql://${aws_rds_cluster.aurora.master_username}:${random_password.db_password.result}@${aws_rds_cluster.aurora.endpoint}:${aws_rds_cluster.aurora.port}/${aws_rds_cluster.aurora.database_name}"
  }

  allowed_triggers = {
    api_gateway = {
      action     = "lambda:InvokeFunction"
      service    = "apigateway"
      source_arn = "${module.api_gateway.api_execution_arn}/*/*"
    }
  }

  attach_policy_statements = true
  policy_statements = {
    rds_data = {
      effect = "Allow",
      actions = [
        "rds-data:BatchExecuteStatement",
        "rds-data:BeginTransaction",
        "rds-data:CommitTransaction",
        "rds-data:ExecuteStatement",
        "rds-data:RollbackTransaction"
      ],
      resources = [aws_rds_cluster.aurora.arn]
    },
    secrets = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.db_credentials.arn]
    }
  }
}
