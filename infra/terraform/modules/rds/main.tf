resource "aws_db_instance" "db" {
  allocated_storage                     = var.allocated_storage
  db_name                               = var.db_name
  identifier                            = var.identifier
  # iops                                  = var.iops
  # storage_throughput                    = var.storage_throughput
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  iam_database_authentication_enabled   = var.iam_database_authentication_enabled
  copy_tags_to_snapshot                 = var.copy_tags_to_snapshot
  final_snapshot_identifier             = var.final_snapshot_identifier
  maintenance_window                    = var.maintenance_window
  kms_key_id                            = var.kms_key_id
  performance_insights_kms_key_id = var.performance_insights_kms_key_id 
  storage_encrypted                     = var.storage_encrypted
  engine                                = var.engine
  engine_version                        = var.engine_version
  publicly_accessible                   = var.publicly_accessible
  multi_az                              = var.multi_az
  instance_class                        = var.instance_class
  username                              = var.username
  storage_type                          = var.storage_type
  password                              = var.password
  max_allocated_storage                 = var.max_allocated_storage
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_role_arn
  parameter_group_name                  = aws_db_parameter_group.parameter_group.name
  backup_retention_period               = 7
  backup_window                         = var.backup_window
  deletion_protection                   = var.deletion_protection
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  skip_final_snapshot                   = var.skip_final_snapshot
  db_subnet_group_name                  = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids                = var.vpc_security_group_ids
  tags = merge(
    {
      Name = var.db_name
    },
    var.tags
  )
}

# Subnet group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.subnet_group_name
  subnet_ids = var.subnet_group_ids

  tags = {
    Name = var.subnet_group_name
  }
}

resource "aws_db_parameter_group" "parameter_group" {
  name   = var.parameter_group_name
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}
