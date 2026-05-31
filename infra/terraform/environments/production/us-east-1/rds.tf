# -----------------------------------------------------------------------------------------
# RDS Instance
# -----------------------------------------------------------------------------------------
resource "aws_iam_role" "rds_monitoring_role" {
  name = "carshub-rds-monitoring-role-${var.env}-${var.region}"
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

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Uncomment only if KMS is needed

# module "carshub_kms_rds" {
#   source = "../../../modules/kms"
#   name = "carshub-kms-rds-${var.env}-${var.region}"
#   description             = "KMS key for ECR encryption"
#   deletion_window_in_days = 30
#   enable_key_rotation     = true
# }

module "carshub_db" {
  source     = "../../../modules/rds"
  db_name    = "carshubdb${var.env}useast1"
  identifier = "carshub-db-${var.env}useast1"

  allocated_storage     = 100
  max_allocated_storage = 500
  storage_type          = "gp3"
  storage_encrypted     = true
  # kms_key_id                            = module.carshub_kms_rds.arn 
  # iops               = 3000
  # storage_throughput = 125

  engine                     = "mysql"
  engine_version             = "8.0.40"
  instance_class             = "db.r6g.large"
  auto_minor_version_upgrade = true

  deletion_protection = false

  multi_az = true

  username                            = tostring(data.vault_generic_secret.rds.data["username"])
  password                            = tostring(data.vault_generic_secret.rds.data["password"])
  iam_database_authentication_enabled = true

  subnet_group_name      = "carshub-rds-subnet-group-${var.env}-${var.region}"
  subnet_group_ids       = module.carshub_vpc.database_subnets
  vpc_security_group_ids = [module.carshub_rds_sg.id]
  publicly_accessible    = false

  backup_retention_period   = 35
  backup_window             = "03:00-06:00"
  copy_tags_to_snapshot     = true
  skip_final_snapshot       = true
  final_snapshot_identifier = "carshub-db-final-snapshot-${var.env}"

  maintenance_window = "sun:08:00-sun:10:00"

  enabled_cloudwatch_logs_exports       = ["audit", "error", "general", "slowquery"]
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  monitoring_interval                   = 60
  # performance_insights_kms_key_id       = module.carshub_kms_rds.arn
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn

  parameter_group_name   = "carshub-db-pg-${var.env}-${var.region}"
  parameter_group_family = "mysql8.0"
  parameters = [
    {
      name  = "max_connections"
      value = "1000"
    },
    # {
    #   name  = "innodb_buffer_pool_size"
    #   value = "{DBInstanceClassMemory*3/4}"
    # },
    {
      name  = "slow_query_log"
      value = "1"
    },
    # {
    #   name  = "long_query_time"
    #   value = "2"
    # },
    # {
    #   name  = "log_queries_not_using_indexes"
    #   value = "1"
    # },
    # {
    #   name  = "innodb_flush_log_at_trx_commit"
    #   value = "1"
    # },
    # {
    #   name  = "innodb_log_file_size"
    #   value = "536870912"
    # },
    # {
    #   name  = "max_allowed_packet"
    #   value = "67108864"
    # },
    # {
    #   name  = "character_set_server"
    #   value = "utf8mb4"
    # },
    # {
    #   name  = "collation_server"
    #   value = "utf8mb4_unicode_ci"
    # },
    # {
    #   name  = "tmp_table_size"
    #   value = "67108864"
    # },
    # {
    #   name  = "max_heap_table_size"
    #   value = "67108864"
    # }
  ]
  tags = {
    Name        = "carshub-db-${var.env}"
    Environment = "${var.env}"
    Project     = var.project
  }
}