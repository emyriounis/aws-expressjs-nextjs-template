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
  engine_version     = "18.3"
  database_name      = "fs_template_db"
  master_username    = "postgres"
  master_password    = random_password.db_password.result

  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]

  # Enable the RDS Data API
  enable_http_endpoint = true
  skip_final_snapshot  = true
  deletion_protection  = true
  copy_tags_to_snapshot = true

  serverlessv2_scaling_configuration {
    max_capacity = var.environment == "prod" ? 8 : 2
    min_capacity = 0
    # min_capacity = var.environment == "prod" ? 0.5 : 0
    seconds_until_auto_pause = 300
  }
}

resource "aws_iam_role" "rds_monitoring" {
  name = "${local.resource_prefix}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  cluster_identifier  = aws_rds_cluster.aurora.id
  instance_class      = "db.serverless"
  engine              = aws_rds_cluster.aurora.engine
  engine_version      = aws_rds_cluster.aurora.engine_version
  publicly_accessible = false

  performance_insights_enabled = true

  monitoring_interval = var.environment == "prod" ? 60 : 1
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn
}
