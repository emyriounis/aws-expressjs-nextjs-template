module "migration_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7.0"

  function_name = "${local.resource_prefix}-migration-lambda"
  description   = "Prisma Migration Execution Lambda"

  runtime                      = var.runtime
  memory_size                  = var.lambda_memory_size
  ephemeral_storage_size       = 512
  timeout                      = 300
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0

  create_package         = false
  local_existing_package = "../source.zip"
  handler                = "run-migrations.handler"

  publish = true
  layers  = [aws_lambda_layer_version.expressjs_layer.arn]

  cloudwatch_logs_retention_in_days = var.logs_retention

  attach_network_policy  = true
  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]

  environment_variables = {
    NODE_ENV     = var.environment
    DATABASE_URL = "postgresql://${aws_rds_cluster.aurora.master_username}:${random_password.db_password.result}@${aws_rds_cluster.aurora.endpoint}:${aws_rds_cluster.aurora.port}/${aws_rds_cluster.aurora.database_name}"
  }
}

resource "null_resource" "trigger_migration" {
  triggers = {
    lambda_version = module.migration_lambda.lambda_function_version
  }

  provisioner "local-exec" {
    command = "aws lambda invoke --function-name ${module.migration_lambda.lambda_function_name} --invocation-type RequestResponse response.json && cat response.json"
  }
}
