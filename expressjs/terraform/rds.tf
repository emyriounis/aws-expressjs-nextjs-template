resource "aws_security_group" "aurora_sg" {
  name        = "${local.resource_prefix}-aurora-sg"
  description = "Security group for Aurora Serverless v2 PostgreSQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow all internal VPC traffic to PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "${local.resource_prefix}-aurora-cluster"
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = "16.4"
  database_name      = "fs_template_db"
  master_username    = "postgres"
  master_password    = random_password.db_password.result

  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]

  # Enable the RDS Data API
  enable_http_endpoint = true
  skip_final_snapshot  = true

  serverlessv2_scaling_configuration {
    max_capacity             = 1.0
    min_capacity             = 0.0
    seconds_until_auto_pause = 300
  }
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  cluster_identifier  = aws_rds_cluster.aurora.id
  instance_class      = "db.serverless"
  engine              = aws_rds_cluster.aurora.engine
  engine_version      = aws_rds_cluster.aurora.engine_version
  publicly_accessible = false
}
