# -----------------------------------------------------------------------------------------
# Registering vault provider
# -----------------------------------------------------------------------------------------
data "vault_generic_secret" "rds" {
  path = "secret/rds"
}

data "aws_elb_service_account" "main" {}

data "aws_caller_identity" "current" {}

resource "random_id" "id" {
  byte_length = 8
}

# -----------------------------------------------------------------------------------------
# VPC Configuration
# -----------------------------------------------------------------------------------------
module "carshub_vpc" {
  source                  = "../../../modules/vpc"
  vpc_name                = "carshub-vpc-${var.env}-${var.region}"
  vpc_cidr                = "10.0.0.0/16"
  azs                     = var.azs
  public_subnets          = var.public_subnets
  private_subnets         = var.private_subnets
  database_subnets        = var.database_subnets
  enable_dns_hostnames    = true
  enable_dns_support      = true
  create_igw              = true
  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  single_nat_gateway      = false
  one_nat_gateway_per_az  = true
  tags = {
    Name        = "carshub-vpc-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

# Security Group
module "carshub_frontend_lb_sg" {
  source = "../../../modules/security-groups"
  name   = "carshub-frontend-lb-sg-${var.env}-${var.region}"
  vpc_id = module.carshub_vpc.vpc_id
  ingress_rules = [
    {
      description     = "HTTP Traffic"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = []
      cidr_blocks     = ["0.0.0.0/0"]
    },
    {
      description     = "HTTPS Traffic"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = []
      cidr_blocks     = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      description     = "Allow outbound traffic to al"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = {
    Name        = "carshub-frontend-lb-sg-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

module "carshub_backend_lb_sg" {
  source = "../../../modules/security-groups"
  name   = "carshub-backend-lb-sg-${var.env}-${var.region}"
  vpc_id = module.carshub_vpc.vpc_id
  ingress_rules = [
    {
      description     = "HTTP Traffic"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.carshub_ecs_frontend_sg.id] 
      cidr_blocks     = []
    },
    {
      description     = "HTTPS Traffic"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = [module.carshub_ecs_frontend_sg.id] 
      cidr_blocks     = []
    }
  ]
  egress_rules = [
    {
      description     = "Allow outbound traffic to al"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = {
    Name        = "carshub-backend-lb-sg-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

module "carshub_ecs_frontend_sg" {
  source = "../../../modules/security-groups"
  name   = "carshub-ecs_frontend-sg-${var.env}-${var.region}"
  vpc_id = module.carshub_vpc.vpc_id
  ingress_rules = [
    {
      description     = "ECS Frontend Traffic"
      from_port       = 3000
      to_port         = 3000
      protocol        = "tcp"
      security_groups = [module.carshub_frontend_lb_sg.id]
      cidr_blocks     = []
    }
  ]
  egress_rules = [
    {
      description     = "Allow outbound traffic to al"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = {
    Name        = "carshub-ecs-frontend-sg-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

module "carshub_ecs_backend_sg" {
  source = "../../../modules/security-groups"
  name   = "carshub-ecs_backend-sg-${var.env}-${var.region}"
  vpc_id = module.carshub_vpc.vpc_id
  ingress_rules = [
    {
      description     = "Traffic from Backend ALB"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.carshub_backend_lb_sg.id]
      cidr_blocks     = []
    }
  ]
  egress_rules = [
    {
      description     = "Allow outbound traffic to al"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = {
    Name        = "carshub-ecs-backend-sg-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

module "carshub_rds_sg" {
  source = "../../../modules/security-groups"
  name   = "carshub-rds-sg-${var.env}-${var.region}"
  vpc_id = module.carshub_vpc.vpc_id
  ingress_rules = [
    {
      description     = "MySQL from Backend ECS only"
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      security_groups = [module.carshub_ecs_backend_sg.id]
      cidr_blocks     = []
    }
  ]
  egress_rules = [
    {
      description     = "Allow outbound traffic to al"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = {
    Name        = "carshub-rds-sg-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

module "carshub_lambda_sg" {
  source = "../../../modules/security-groups"
  name   = "carshub-lambda-sg-${var.env}-${var.region}"
  vpc_id = module.carshub_vpc.vpc_id

  ingress_rules = []

  egress_rules = [
    {
      description     = "HTTPS to VPC endpoints and internet"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]

  tags = {
    Name        = "carshub-lambda-sg-${var.env}-${var.region}"
    Environment = var.env
    Project     = var.project
  }
}

resource "aws_security_group_rule" "lambda_to_rds_egress" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.carshub_lambda_sg.id
  source_security_group_id = module.carshub_rds_sg.id
  description              = "MySQL to RDS"
}

resource "aws_security_group_rule" "rds_from_lambda_ingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.carshub_rds_sg.id
  source_security_group_id = module.carshub_lambda_sg.id
  description              = "MySQL from Lambda"
}

module "carshub_vpc_endpoint_sg" {
  source = "../../../modules/security-groups"
  name   = "carshub-vpc-endpoint-sg-${var.env}-${var.region}"
  vpc_id = module.carshub_vpc.vpc_id
  ingress_rules = [
    {
      description     = "HTTPS from Lambda"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = [module.carshub_lambda_sg.id]
      cidr_blocks     = []
    }
  ]
  egress_rules = [
    {
      description     = "Allow all outbound"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
  tags = {
    Name        = "carshub-vpc-endpoint-sg-${var.env}-${var.region}"
    Environment = var.env
    Project     = var.project
  }
}

# -----------------------------------------------------------------------------------------
# Secrets Manager
# -----------------------------------------------------------------------------------------
module "carshub_db_credentials" {
  source                  = "../../../modules/secrets-manager"
  name                    = "carshub-rds-secrets-${var.env}-${var.region}"
  description             = "Secret for storing RDS credentials"
  recovery_window_in_days = 0
  secret_string = jsonencode({
    username = tostring(data.vault_generic_secret.rds.data["username"])
    password = tostring(data.vault_generic_secret.rds.data["password"])
  })
  replica = [
    {
      region     = "us-west-2"
      kms_key_id = "alias/aws/secretsmanager"
    }
  ]
  tags = {
    Name        = "carshub-rds-secrets-${var.env}-${var.region}"
    Environment = var.env
    Project     = var.project
  }
}

# -----------------------------------------------------------------------------------------
# VPC Flow Logs
# -----------------------------------------------------------------------------------------
module "flow_logs_role" {
  source             = "../../../modules/iam"
  role_name          = "carshub-flow-logs-role-${var.env}-${var.region}"
  role_description   = "IAM role for VPC Flow Logs"
  policy_name        = "carshub-flow-logs-policy-${var.env}-${var.region}"
  policy_description = "IAM policy for VPC Flow Logs"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                  "Service": "vpc-flow-logs.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
  policy             = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                  "logs:CreateLogStream",
                  "logs:PutLogEvents",
                  "logs:DescribeLogGroups",
                  "logs:DescribeLogStreams"
                ],
                "Resource": [
                  "${module.carshub_flow_log_group.arn}",
                  "${module.carshub_flow_log_group.arn}:*"
                ],
                "Effect": "Allow"
            }
        ]
    }
    EOF
  tags = {
    Name        = "carshub-flow-logs-role-${var.env}-${var.region}"
    Environment = var.env
    Project     = var.project
  }
}

module "carshub_flow_log_group" {
  source            = "../../../modules/cloudwatch/cloudwatch-log-group"
  log_group_name    = "/aws/vpc/flow-logs/carshub-application-${var.env}-${var.region}"
  skip_destroy      = false
  retention_in_days = 0 # dont set it to 0 when production is considered 
}

# Add VPC Flow Logs for security monitoring
resource "aws_flow_log" "carshub_vpc_flow_log" {
  iam_role_arn    = module.flow_logs_role.arn
  log_destination = module.carshub_flow_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = module.carshub_vpc.vpc_id
  depends_on = [
    module.carshub_flow_log_group,
    module.flow_logs_role
  ]
}

# -----------------------------------------------------------------------------------------
# ECR Module
# -----------------------------------------------------------------------------------------

# Uncomment only if KMS is needed

# module "carshub_kms_ecr" {
#   source = "../../../modules/kms"
#   name = "carshub-kms-ecr-${var.env}-${var.region}"
#   description             = "KMS key for ECR encryption"
#   deletion_window_in_days = 30
#   enable_key_rotation     = true
# }

module "carshub_frontend_container_registry" {
  source               = "../../../modules/ecr"
  force_delete         = true
  scan_on_push         = false
  image_tag_mutability = "IMMUTABLE"
  name                 = "carshub-frontend-registry-${var.env}-${var.region}"
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  # Uncomment only if KMS is needed

  # encryption_type = "KMS"
  # kms_key         = module.carshub_kms_ecr.key_id

  tags = {
    Name        = "carshub-frontend-registry-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

resource "null_resource" "build_and_push_frontend" {
  # Re-trigger build if any of these change
  triggers = {
    image_tag = "latest"
  }

  provisioner "local-exec" {
    command = "bash ${path.cwd}/../../../../../src/frontend/artifact_push.sh carshub-frontend-registry-${var.env}-${var.region} ${var.region} http://${module.carshub_backend_lb.dns_name} ${module.carshub_media_cloudfront_distribution.domain_name}"
  }

  depends_on = [
    module.carshub_frontend_container_registry,
  ]
}

module "carshub_backend_container_registry" {
  source               = "../../../modules/ecr"
  force_delete         = true
  scan_on_push         = false
  image_tag_mutability = "IMMUTABLE"
  name                 = "carshub-backend-registry-${var.env}-${var.region}"
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  # Uncomment only if KMS is needed

  # encryption_type = "KMS"
  # kms_key         = module.carshub_kms_ecr.key_id

  tags = {
    Name        = "carshub-backend-registry-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

resource "null_resource" "build_and_push_backend" {
  # Re-trigger build if any of these change
  triggers = {
    image_tag = "latest"
  }

  provisioner "local-exec" {
    command = "bash ${path.cwd}/../../../../../src/backend/api/artifact_push.sh carshub-backend-registry-${var.env}-${var.region} ${var.region}"
  }

  depends_on = [
    module.carshub_backend_container_registry,
  ]
}

resource "aws_ecr_replication_configuration" "carshub_ecr_replication" {
  replication_configuration {
    rule {
      destination {
        region      = "us-west-2"
        registry_id = data.aws_caller_identity.current.account_id
      }

      # Only replicate the carshub repos, not everything in the account
      repository_filter {
        filter      = "carshub-frontend-registry-${var.env}"
        filter_type = "PREFIX_MATCH"
      }

      repository_filter {
        filter      = "carshub-backend-registry-${var.env}"
        filter_type = "PREFIX_MATCH"
      }
    }
  }
}

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

# -----------------------------------------------------------------------------------------
# S3 Configuration
# -----------------------------------------------------------------------------------------
module "carshub_media_bucket" {
  source      = "../../../modules/s3"
  bucket_name = "carshub-media-bucket-${var.env}-${var.region}"
  objects = [
    {
      key    = "images/"
      source = ""
    },
    {
      key    = "documents/"
      source = ""
    }
  ]
  versioning_enabled = "Enabled"
  cors = [
    {
      allowed_headers = ["${module.carshub_media_cloudfront_distribution.domain_name}"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    },
    {
      allowed_headers = ["${module.carshub_frontend_lb.dns_name}"]
      allowed_methods = ["PUT"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  bucket_policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipal",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${module.carshub_media_bucket.arn}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : "${module.carshub_media_cloudfront_distribution.arn}"
          }
        }
      }
    ]
  })
  force_destroy = true
  bucket_notification = {
    queue = [
      {
        queue_arn = module.carshub_media_events_queue.arn
        events    = ["s3:ObjectCreated:*"]
      }
    ]
    lambda_function = []
  }
  tags = {
    Name        = "carshub-media-bucket-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

module "carshub_media_update_function_code" {
  source      = "../../../modules/s3"
  bucket_name = "carshub-media-updatefunctioncode${var.env}-${var.region}"
  objects = [
    {
      key    = "lambda.zip"
      source = "../../../files/lambda.zip"
    }
  ]
  bucket_policy = ""
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  versioning_enabled = "Enabled"
  force_destroy      = true
  tags = {
    Name        = "carshub-media-updatefunctioncode${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

module "carshub_frontend_lb_logs" {
  source      = "../../../modules/s3"
  bucket_name = "carshub-frontend-lb-logs-${var.env}-${var.region}"
  objects     = []
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::carshub-frontend-lb-logs-${var.env}-${var.region}/*"
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::carshub-frontend-lb-logs-${var.env}-${var.region}"
      },
      {
        Sid    = "AWSELBAccountWrite"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::carshub-frontend-lb-logs-${var.env}-${var.region}/*"
      }
    ]
  })
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    },
    {
      allowed_headers = ["*"]
      allowed_methods = ["PUT"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  versioning_enabled = "Enabled"
  force_destroy      = true
  tags = {
    Name        = "carshub-frontend-lb-logs-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

module "carshub_backend_lb_logs" {
  source      = "../../../modules/s3"
  bucket_name = "carshub-backend-lb-logs-${var.env}-${var.region}"
  objects     = []
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::carshub-backend-lb-logs-${var.env}-${var.region}/*"
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::carshub-backend-lb-logs-${var.env}-${var.region}"
      },
      {
        Sid    = "AWSELBAccountWrite"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::carshub-backend-lb-logs-${var.env}-${var.region}/*"
      }
    ]
  })
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    },
    {
      allowed_headers = ["*"]
      allowed_methods = ["PUT"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  versioning_enabled = "Enabled"
  force_destroy      = true
  tags = {
    Name        = "carshub-backend-lb-logs-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

# -----------------------------------------------------------------------------------------
# Signing Profile
# -----------------------------------------------------------------------------------------
module "carshub_media_update_function_code_signed" {
  source             = "../../../modules/s3"
  bucket_name        = "carshub-media-update-function-code-signed${var.env}-${var.region}"
  versioning_enabled = "Enabled"
  force_destroy      = true
  bucket_policy      = ""
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  tags = {
    Name        = "carshub-media-update-function-code-signed${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

# Signing profile
module "carshub_signing_profile" {
  source                           = "../../../modules/signing-profile"
  platform_id                      = "AWSLambda-SHA384-ECDSA"
  signature_validity_value         = 5
  signature_validity_type          = "YEARS"
  ignore_signing_job_failure       = false
  untrusted_artifact_on_deployment = "Warn"
  s3_bucket_key                    = "lambda.zip"
  s3_bucket_source                 = module.carshub_media_update_function_code.bucket
  s3_bucket_version                = module.carshub_media_update_function_code.objects[0].version_id
  s3_bucket_destination            = module.carshub_media_update_function_code_signed.bucket
}

# -----------------------------------------------------------------------------------------
# SQS Config
# -----------------------------------------------------------------------------------------
resource "aws_lambda_event_source_mapping" "sqs_event_trigger" {
  event_source_arn                   = module.carshub_media_events_queue.arn
  function_name                      = module.carshub_media_update_function.arn
  enabled                            = true
  batch_size                         = 10
  maximum_batching_window_in_seconds = 60
}

# SQS Queue for buffering S3 events
module "carshub_media_events_queue" {
  source                     = "../../../modules/sqs"
  queue_name                 = "carshub-media-events-queue-${var.env}-${var.region}"
  delay_seconds              = 0
  maxReceiveCount            = 3
  max_message_size           = 262144
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 180
  receive_wait_time_seconds  = 20
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = "arn:aws:sqs:${var.region}:*:carshub-media-events-queue-${var.env}-${var.region}"
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = module.carshub_media_bucket.arn
          }
        }
      }
    ]
  })
  tags = {
    Name        = "carshub-media-events-queue-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

module "carshub_media_events_dlq" {
  source                     = "../../../modules/sqs"
  queue_name                 = "carshub-media-events-dlq-${var.env}-${var.region}"
  delay_seconds              = 0
  maxReceiveCount            = 3
  max_message_size           = 262144
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 180
  receive_wait_time_seconds  = 20
  policy                     = ""
  tags = {
    Name        = "carshub-media-events-dlq-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

# -----------------------------------------------------------------------------------------
# Lambda Config
# -----------------------------------------------------------------------------------------
module "carshub_media_update_function_iam_role" {
  source             = "../../../modules/iam"
  role_name          = "carshub-media-update-function-iam-role-${var.env}-${var.region}"
  role_description   = "IAM role for media metadata update lambda function"
  policy_name        = "carshub-media-update-function-iam-policy-${var.env}-${var.region}"
  policy_description = "IAM policy for media metadata update lambda function"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                  "Service": "lambda.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
  policy             = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
                ],
                "Resource": "arn:aws:logs:*:*:*",
                "Effect": "Allow"
            },
            {
              "Effect": "Allow",
              "Action": "secretsmanager:GetSecretValue",
              "Resource": "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:carshub-rds-secrets-${var.env}-${var.region}-*"
            },
            {
                "Action": ["s3:GetObject", "s3:PutObject"],
                "Effect": "Allow",
                "Resource": "${module.carshub_media_bucket.arn}/*"
            },
            {
              "Action": [
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes"
              ],
              "Effect"   : "Allow",
              "Resource" : "${module.carshub_media_events_queue.arn}"
            },
            {
              "Action": [
                "sqs:*"
              ],
              "Effect"   : "Allow",
              "Resource" : "${module.carshub_media_events_dlq.arn}"
            },
            {
              "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface"
              ],
              "Effect"   : "Allow",
              "Resource" : "*"
            }
        ]
    }
    EOF
  tags = {
    Name        = "carshub-media-update-function-iam-role-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

# Lambda Layer for storing dependencies
resource "aws_lambda_layer_version" "python_layer" {
  filename            = "../../../files/python.zip"
  layer_name          = "python"
  compatible_runtimes = ["python3.12"]
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = module.carshub_vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.carshub_vpc.private_subnets
  security_group_ids  = [module.carshub_vpc_endpoint_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.carshub_vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.carshub_vpc.private_route_table_ids
}

# Lambda function to update media metadata in RDS database
module "carshub_media_update_function" {
  source        = "../../../modules/lambda"
  function_name = "carshub-media-update-${var.env}-${var.region}"
  role_arn      = module.carshub_media_update_function_iam_role.arn
  permissions   = []
  vpc_config = {
    security_group_ids = [module.carshub_lambda_sg.id]
    subnet_ids         = module.carshub_vpc.private_subnets
  }
  dead_letter_config = {
    target_arn = module.carshub_media_events_dlq.arn
  }
  env_variables = {
    SECRET_NAME = module.carshub_db_credentials.name
    DB_HOST     = module.carshub_db.address
    DB_NAME     = var.db_name
    REGION      = var.region
  }
  handler                 = "lambda.lambda_handler"
  runtime                 = "python3.12"
  s3_bucket               = module.carshub_media_update_function_code.bucket
  s3_key                  = "lambda.zip"
  layers                  = [aws_lambda_layer_version.python_layer.arn]
  code_signing_config_arn = module.carshub_signing_profile.config_arn
  tags = {
    Name        = "carshub-media-update-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

# -----------------------------------------------------------------------------------------
# Cloudfront distribution
# -----------------------------------------------------------------------------------------
module "carshub_media_cloudfront_distribution" {
  source                                = "../../../modules/cloudfront"
  distribution_name                     = "carshub-media-cdn-${var.env}-${var.region}"
  oac_name                              = "carshub-media-cdn-oac-${var.env}-${var.region}"
  oac_description                       = "carshub-media-cdn-oac-${var.env}-${var.region}"
  oac_origin_access_control_origin_type = "s3"
  oac_signing_behavior                  = "always"
  oac_signing_protocol                  = "sigv4"
  enabled                               = true
  origin = [
    {
      origin_id           = "carshub-media-bucket-${var.env}-${var.region}"
      domain_name         = "carshub-media-bucket-${var.env}.s3.${var.region}.amazonaws.com"
      connection_attempts = 3
      connection_timeout  = 10
    },
    {
      origin_id           = "carshub-media-bucket-${var.env}-us-west-2"
      domain_name         = "carshub-media-bucket-${var.env}.s3.us-west-2.amazonaws.com"
      connection_attempts = 3
      connection_timeout  = 10
    }
  ]
  origin_groups = [
    {
      origin_id    = "carshub-media-origin-group-${var.env}"
      status_codes = [500, 502, 503, 504, 403, 404]
      members = [
        "carshub-media-bucket-${var.env}-${var.region}",
        "carshub-media-bucket-${var.env}-us-west-2"
      ]
    }
  ]
  compress                       = true
  smooth_streaming               = false
  target_origin_id               = "carshub-media-origin-group-${var.env}"
  allowed_methods                = ["GET", "HEAD"]
  cached_methods                 = ["GET", "HEAD"]
  viewer_protocol_policy         = "redirect-to-https"
  min_ttl                        = 0
  default_ttl                    = 86400
  max_ttl                        = 31536000
  price_class                    = "PriceClass_200"
  forward_cookies                = "all"
  cloudfront_default_certificate = true
  geo_restriction_type           = "none"
  query_string                   = true
  tags = {
    Name        = "carshub-media-cdn-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

# -----------------------------------------------------------------------------------------
# Load Balancer Configuration
# -----------------------------------------------------------------------------------------
module "carshub_frontend_lb" {
  source                     = "terraform-aws-modules/alb/aws"
  name                       = "carshub-front-lb-${var.env}-${var.region}"
  load_balancer_type         = "application"
  vpc_id                     = module.carshub_vpc.vpc_id
  subnets                    = module.carshub_vpc.public_subnets
  enable_deletion_protection = false
  drop_invalid_header_fields = true
  ip_address_type            = "ipv4"
  internal                   = false
  security_groups = [
    module.carshub_frontend_lb_sg.id
  ]
  access_logs = {
    bucket = "${module.carshub_frontend_lb_logs.bucket}"
  }
  listeners = {
    carshub_frontend_lb_http_listener = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "carshub_frontend_lb_target_group"
      }
    }
  }
  target_groups = {
    carshub_frontend_lb_target_group = {
      backend_protocol = "HTTP"
      backend_port     = 3000
      target_type      = "ip"
      vpc_id           = module.carshub_vpc.vpc_id
      health_check = {
        enabled             = true
        healthy_threshold   = 3
        interval            = 30
        path                = "/auth/signin"
        port                = 3000
        protocol            = "HTTP"
        unhealthy_threshold = 3
      }
      create_attachment = false
    }
  }
  tags = {
    Name        = "carshub-front-lb-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
  depends_on = [module.carshub_vpc]
}

module "carshub_backend_lb" {
  source                     = "terraform-aws-modules/alb/aws"
  name                       = "carshub-back-lb-${var.env}-${var.region}"
  load_balancer_type         = "application"
  vpc_id                     = module.carshub_vpc.vpc_id
  subnets                    = module.carshub_vpc.public_subnets
  enable_deletion_protection = false
  drop_invalid_header_fields = true
  ip_address_type            = "ipv4"
  internal                   = false
  security_groups = [
    module.carshub_backend_lb_sg.id
  ]
  access_logs = {
    bucket = "${module.carshub_backend_lb_logs.bucket}"
  }
  listeners = {
    carshub_backend_lb_http_listener = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "carshub_backend_lb_target_group"
      }
    }
  }
  target_groups = {
    carshub_backend_lb_target_group = {
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      vpc_id           = module.carshub_vpc.vpc_id
      health_check = {
        enabled             = true
        healthy_threshold   = 3
        interval            = 30
        path                = "/"
        port                = 80
        protocol            = "HTTP"
        unhealthy_threshold = 3
      }
      create_attachment = false
    }
  }
  tags = {
    Name        = "carshub-back-lb-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
  depends_on = [module.carshub_vpc]
}

# ---------------------------------------------------------------------
# ECS configuration
# ---------------------------------------------------------------------
module "ecs_task_execution_role" {
  source             = "../../../modules/iam"
  role_name          = "carshub-ecs-task-execution-role-${var.env}-${var.region}"
  role_description   = "IAM role for ECS task execution"
  policy_name        = "carshub-ecs-task-execution-policy-${var.env}-${var.region}"
  policy_description = "IAM policy for ECS task execution"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                  "Service": "ecs-tasks.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
  policy             = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
              "Effect": "Allow",
              "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
              ],
              "Resource": "*"
            },
            {
                "Action": [
                  "s3:PutObject"
                ],
                "Resource": [
                  "${module.carshub_media_bucket.arn}",
                  "${module.carshub_media_bucket.arn}/*"
                ],
                "Effect": "Allow"
            },
            {
              "Effect": "Allow",
              "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
              ],
              "Resource": [
                "${module.carshub_db_credentials.arn}*"
              ]
            },
            {
                "Action": [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents",
                  "logs:DescribeLogGroups",
                  "logs:CreateLogStream",
                  "logs:DescribeLogStreams",
                  "logs:PutLogEvents"
                ],
                "Resource": "*",
                "Effect": "Allow"
            }
        ]
    }
    EOF
  tags = {
    Name        = "carshub-ecs-task-execution-role-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

# ECR-ECS policy attachment 
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = module.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# X-Ray tracing
resource "aws_iam_role_policy_attachment" "ecs_task_xray" {
  role       = module.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

module "carshub_frontend_ecs_log_group" {
  source            = "../../../modules/cloudwatch/cloudwatch-log-group"
  log_group_name    = "/aws/ecs/carshub-frontend-ecs-${var.env}-${var.region}"
  skip_destroy      = false
  retention_in_days = 0
  tags = {
    Name        = "/aws/ecs/carshub-frontend-ecs-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

module "carshub_backend_ecs_log_group" {
  source            = "../../../modules/cloudwatch/cloudwatch-log-group"
  log_group_name    = "/aws/ecs/carshub-backend-ecs-${var.env}-${var.region}"
  skip_destroy      = false
  retention_in_days = 0
  tags = {
    Name        = "/aws/ecs/carshub-backend-ecs-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

module "carshub_cluster" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = "carshub-ecs-cluster-${var.env}-${var.region}"
  services = {
    ecs_frontend = {
      cpu                    = 2048
      memory                 = 4096
      task_exec_iam_role_arn = module.ecs_task_execution_role.arn
      iam_role_arn           = module.ecs_task_execution_role.arn
      desired_count          = 2
      assign_public_ip       = false
      enable_execute_command = true
      deployment_controller = {
        type = "ECS"
      }
      network_mode = "awsvpc"
      runtime_platform = {
        cpu_architecture        = "X86_64"
        operating_system_family = "LINUX"
      }
      launch_type              = "FARGATE"
      scheduling_strategy      = "REPLICA"
      requires_compatibilities = ["FARGATE"]
      container_definitions = {
        ecs_frontend = {
          cpu       = 1024
          memory    = 2048
          essential = true
          image     = "${module.carshub_frontend_container_registry.repository_url}:latest"
          healthCheck = {
            command     = ["CMD-SHELL", "wget -qO- http://localhost:3000/auth/signin || exit 1"]
            interval    = 30
            timeout     = 10
            retries     = 3
            startPeriod = 60
          }
          ulimits = [
            {
              name      = "nofile"
              softLimit = 65536
              hardLimit = 65536
            }
          ]
          portMappings = [
            {
              name          = "ecs_frontend"
              containerPort = 3000
              hostPort      = 3000
              protocol      = "tcp"
            }
          ]
          environment = [
            {
              name = "HOSTNAME", value = "0.0.0.0"
            },
            {
              name  = "BASE_URL"
              value = "${module.carshub_backend_lb.dns_name}"
            }
          ]
          readonlyRootFilesystem = false
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = module.carshub_frontend_ecs_log_group.name
              awslogs-region        = var.region
              awslogs-stream-prefix = "carshub-frontend"
            }
          }
          memoryReservation = 100
          restartPolicy = {
            enabled              = true
            ignoredExitCodes     = []
            restartAttemptPeriod = 300 # increase to 5 min to prevent rapid cycling
          }
        }
      }
      load_balancer = {
        service = {
          target_group_arn = module.carshub_frontend_lb.target_groups["carshub_frontend_lb_target_group"].arn
          container_name   = "ecs_frontend"
          container_port   = 3000
        }
      }
      subnet_ids                    = module.carshub_vpc.private_subnets
      vpc_id                        = module.carshub_vpc.vpc_id
      security_group_ids            = [module.carshub_ecs_frontend_sg.id]
      availability_zone_rebalancing = "ENABLED"
    }

    ecs_backend = {
      cpu                    = 2048
      memory                 = 4096
      task_exec_iam_role_arn = module.ecs_task_execution_role.arn
      iam_role_arn           = module.ecs_task_execution_role.arn
      desired_count          = 2
      assign_public_ip       = false
      enable_execute_command = true
      deployment_controller = {
        type = "ECS"
      }
      network_mode = "awsvpc"
      runtime_platform = {
        cpu_architecture        = "X86_64"
        operating_system_family = "LINUX"
      }
      launch_type              = "FARGATE"
      scheduling_strategy      = "REPLICA"
      requires_compatibilities = ["FARGATE"]
      container_definitions = {
        ecs_backend = {
          cpu       = 1024
          memory    = 2048
          essential = true
          image     = "${module.carshub_backend_container_registry.repository_url}:latest"
          healthCheck = {
            command     = ["CMD-SHELL", "wget -qO- http://localhost:80 || exit 1"]
            interval    = 30
            timeout     = 10
            retries     = 3
            startPeriod = 120
          }
          ulimits = [
            {
              name      = "nofile"
              softLimit = 65536
              hardLimit = 65536
            }
          ]
          environment = [
            {
              name  = "DB_PATH"
              value = "${module.carshub_db.address}"
            },
            {
              name  = "DB_NAME"
              value = "${module.carshub_db.name}"
            },
            {
              name  = "UN"
              value = "mohit"
            },
            {
              name  = "CREDS"
              value = "Mohitdixit12345!"
            }
          ]
          portMappings = [
            {
              name          = "ecs_backend"
              containerPort = 80
              hostPort      = 80
              protocol      = "tcp"
            }
          ]
          readonlyRootFilesystem = false
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = module.carshub_backend_ecs_log_group.name
              awslogs-region        = var.region
              awslogs-stream-prefix = "carshub-backend"
            }
          }
          memoryReservation = 100
          restartPolicy = {
            enabled              = true
            ignoredExitCodes     = []
            restartAttemptPeriod = 300 # increase to 5 min to prevent rapid cycling
          }
        }
      }
      load_balancer = {
        service = {
          target_group_arn = module.carshub_backend_lb.target_groups["carshub_backend_lb_target_group"].arn
          container_name   = "ecs_backend"
          container_port   = 80
        }
      }
      subnet_ids                    = module.carshub_vpc.private_subnets
      vpc_id                        = module.carshub_vpc.vpc_id
      security_group_ids            = [module.carshub_ecs_backend_sg.id]
      availability_zone_rebalancing = "ENABLED"
    }
  }
  tags = {
    Name        = "carshub-ecs-cluster-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
  depends_on = [
    module.carshub_frontend_ecs_log_group,
    module.carshub_backend_ecs_log_group,
    module.ecs_task_execution_role
  ]
}

# Module for Frontend CPU Autoscaling Policy
module "carshub_frontend_cpu_autoscaling" {
  source             = "../../../modules/autoscaling"
  min_capacity       = 2
  max_capacity       = 10
  resource_id        = "service/${module.carshub_cluster.cluster_name}/${module.carshub_cluster.services["ecs_frontend"].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  policies = [
    {
      name        = "carshub-frontend-cpu-scale-up-${var.env}"
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type          = "ChangeInCapacity"
        cooldown                 = 60
        metric_aggregation_type  = "Average"
        min_adjustment_magnitude = null
        step_adjustment = [
          {
            metric_interval_lower_bound = 0
            metric_interval_upper_bound = 20
            scaling_adjustment          = 1
          },
          {
            metric_interval_lower_bound = 20
            metric_interval_upper_bound = null
            scaling_adjustment          = 2
          }
        ]
      }
      predictive_scaling_policy_configuration  = null
      target_tracking_scaling_policy_configuration = null
    },
    {
      name        = "carshub-frontend-cpu-scale-down-${var.env}"
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type          = "ChangeInCapacity"
        cooldown                 = 300
        metric_aggregation_type  = "Average"
        min_adjustment_magnitude = null
        step_adjustment = [
          {
            metric_interval_lower_bound = null
            metric_interval_upper_bound = 0
            scaling_adjustment          = -1
          }
        ]
      }
      predictive_scaling_policy_configuration      = null
      target_tracking_scaling_policy_configuration = null
    }
  ]
  depends_on = [module.carshub_cluster]
}

module "carshub_frontend_memory_autoscaling" {
  source             = "../../../modules/autoscaling"
  min_capacity       = 2
  max_capacity       = 10
  resource_id        = "service/${module.carshub_cluster.cluster_name}/${module.carshub_cluster.services["ecs_frontend"].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  policies = [
    {
      name        = "carshub-frontend-memory-scale-up-${var.env}"
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type          = "ChangeInCapacity"
        cooldown                 = 60
        metric_aggregation_type  = "Average"
        min_adjustment_magnitude = null
        step_adjustment = [
          {
            metric_interval_lower_bound = 0
            metric_interval_upper_bound = 20
            scaling_adjustment          = 1
          },
          {
            metric_interval_lower_bound = 20
            metric_interval_upper_bound = null
            scaling_adjustment          = 2
          }
        ]
      }
      predictive_scaling_policy_configuration      = null
      target_tracking_scaling_policy_configuration = null
    },
    {
      name        = "carshub-frontend-memory-scale-down-${var.env}"
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type          = "ChangeInCapacity"
        cooldown                 = 300
        metric_aggregation_type  = "Average"
        min_adjustment_magnitude = null
        step_adjustment = [
          {
            metric_interval_lower_bound = null
            metric_interval_upper_bound = 0
            scaling_adjustment          = -1
          }
        ]
      }
      predictive_scaling_policy_configuration      = null
      target_tracking_scaling_policy_configuration = null
    }
  ]

  depends_on = [module.carshub_cluster]
}

module "carshub_backend_cpu_autoscaling" {
  source             = "../../../modules/autoscaling"
  min_capacity       = 2
  max_capacity       = 10
  resource_id        = "service/${module.carshub_cluster.cluster_name}/${module.carshub_cluster.services["ecs_backend"].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  policies = [
    {
      name        = "carshub-backend-cpu-scale-up-${var.env}"
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type          = "ChangeInCapacity"
        cooldown                 = 60
        metric_aggregation_type  = "Average"
        min_adjustment_magnitude = null
        step_adjustment = [
          {
            metric_interval_lower_bound = 0
            metric_interval_upper_bound = 20
            scaling_adjustment          = 1
          },
          {
            metric_interval_lower_bound = 20
            metric_interval_upper_bound = null
            scaling_adjustment          = 2
          }
        ]
      }
      predictive_scaling_policy_configuration      = null
      target_tracking_scaling_policy_configuration = null
    },
    {
      name        = "carshub-backend-cpu-scale-down-${var.env}"
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type          = "ChangeInCapacity"
        cooldown                 = 300
        metric_aggregation_type  = "Average"
        min_adjustment_magnitude = null
        step_adjustment = [
          {
            metric_interval_lower_bound = null
            metric_interval_upper_bound = 0
            scaling_adjustment          = -1
          }
        ]
      }
      predictive_scaling_policy_configuration      = null
      target_tracking_scaling_policy_configuration = null
    }
  ]

  depends_on = [module.carshub_cluster]
}

module "carshub_backend_memory_autoscaling" {
  source             = "../../../modules/autoscaling"
  min_capacity       = 2
  max_capacity       = 10
  resource_id        = "service/${module.carshub_cluster.cluster_name}/${module.carshub_cluster.services["ecs_backend"].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  policies = [
    {
      name        = "carshub-backend-memory-scale-up-${var.env}"
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type          = "ChangeInCapacity"
        cooldown                 = 60
        metric_aggregation_type  = "Average"
        min_adjustment_magnitude = null
        step_adjustment = [
          {
            metric_interval_lower_bound = 0
            metric_interval_upper_bound = 20
            scaling_adjustment          = 1
          },
          {
            metric_interval_lower_bound = 20
            metric_interval_upper_bound = null
            scaling_adjustment          = 2
          }
        ]
      }
      predictive_scaling_policy_configuration      = null
      target_tracking_scaling_policy_configuration = null
    },
    {
      name        = "carshub-backend-memory-scale-down-${var.env}"
      policy_type = "StepScaling"
      step_scaling_policy_configuration = {
        adjustment_type          = "ChangeInCapacity"
        cooldown                 = 300
        metric_aggregation_type  = "Average"
        min_adjustment_magnitude = null
        step_adjustment = [
          {
            metric_interval_lower_bound = null
            metric_interval_upper_bound = 0
            scaling_adjustment          = -1
          }
        ]
      }
      predictive_scaling_policy_configuration      = null
      target_tracking_scaling_policy_configuration = null
    }
  ]

  depends_on = [module.carshub_cluster]
}

# module "carshub_frontend_app_autoscaling_policy" {
#   source             = "../../../modules/autoscaling"
#   min_capacity       = 2
#   max_capacity       = 10
#   resource_id        = "service/${module.carshub_cluster.cluster_name}/${module.carshub_cluster.services["ecs_frontend"].name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
#   policies = [
#     {
#       name        = "worker-scale-up"
#       policy_type = "StepScaling"
#       step_scaling_policy_configuration = {
#         adjustment_type         = "ChangeInCapacity"
#         cooldown                = 60
#         metric_aggregation_type = "Average"
#         step_adjustment = [
#           {
#             metric_interval_lower_bound = 0
#             metric_interval_upper_bound = 20
#             scaling_adjustment          = 1
#           },
#           {
#             metric_interval_lower_bound = 20
#             scaling_adjustment          = 2
#           }
#         ]
#       }
#     }
#   ]
# }

# module "carshub_backend_app_autoscaling_policy" {
#   source             = "../../../modules/autoscaling"
#   min_capacity       = 2
#   max_capacity       = 10
#   resource_id        = "service/${module.carshub_cluster.cluster_name}/${module.carshub_cluster.services["ecs_backend"].name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
#   policies = [
#     {
#       name        = "worker-scale-up"
#       policy_type = "StepScaling"
#       step_scaling_policy_configuration = {
#         adjustment_type         = "ChangeInCapacity"
#         cooldown                = 60
#         metric_aggregation_type = "Average"
#         step_adjustment = [
#           {
#             metric_interval_lower_bound = 0
#             metric_interval_upper_bound = 20
#             scaling_adjustment          = 1
#           },
#           {
#             metric_interval_lower_bound = 20
#             scaling_adjustment          = 2
#           }
#         ]
#       }
#     }
#   ]
# }

# -----------------------------------------------------------------------------------------
# Cloudwath Alarm Configuration
# -----------------------------------------------------------------------------------------
module "carshub_alarm_notifications" {
  source     = "../../../modules/sns"
  topic_name = "carshub-cloudwatch-alarm-notification-topic-${var.env}-${var.region}"
  subscriptions = [
    {
      protocol = "email"
      endpoint = "madmaxcloudonline@gmail.com"
    }
  ]
  tags = {
    Name        = "carshub-cloudwatch-alarm-notification-topic-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

# CPU Utilization Alarm
module "carshub_frontend_ecs_service_high_cpu" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${module.carshub_cluster.cluster_name}-${module.carshub_cluster.services["ecs_frontend"].name}-high-cpu-utilization-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS service CPU utilization"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    ClusterName = module.carshub_cluster.cluster_name
    ServiceName = module.carshub_cluster.services["ecs_frontend"].name
  }
}

# Memory Utilization Alarm
module "carshub_frontend_ecs_service_high_memory" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${module.carshub_cluster.cluster_name}-${module.carshub_cluster.services["ecs_frontend"].name}-high-memory-utilization-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS service memory utilization"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    ClusterName = module.carshub_cluster.cluster_name
    ServiceName = module.carshub_cluster.services["ecs_frontend"].name
  }
}

# Service Running Tasks Alarm - alerts if there are fewer than expected tasks
module "carshub_frontend_ecs_service_running_tasks" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${module.carshub_cluster.cluster_name}-${module.carshub_cluster.services["ecs_frontend"].name}-low-running-tasks-${var.env}-${var.region}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1" # Adjust based on your desired minimum task count
  alarm_description   = "This metric monitors the minimum number of running tasks"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    ClusterName = module.carshub_cluster.cluster_name
    ServiceName = module.carshub_cluster.services["ecs_frontend"].name
  }
}

# Service Failed Deployment Alarm
module "carshub_frontend_ecs_failed_deployments" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${module.carshub_cluster.cluster_name}-${module.carshub_cluster.services["ecs_frontend"].name}-failed-deployments-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DeploymentFailures"
  namespace           = "ECS/ContainerInsights"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors ECS deployment failures"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    ClusterName = module.carshub_cluster.cluster_name
    ServiceName = module.carshub_cluster.services["ecs_frontend"].name
  }
}

# Target Response Time Alarm (if using ALB)
module "carshub_frontend_ecs_alb_high_response_time" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${module.carshub_cluster.cluster_name}-${module.carshub_cluster.services["ecs_frontend"].name}-high-response-time-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "This metric monitors ALB target response time"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    LoadBalancer = module.carshub_frontend_lb.arn
  }
}

# HTTP 5XX Error Rate Alarm (if using ALB)
module "carshub_frontend_lb_high_5xx_errors" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${module.carshub_cluster.cluster_name}-${module.carshub_cluster.services["ecs_frontend"].name}-high-5xx-errors-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10" # Adjust based on your traffic pattern
  alarm_description   = "This metric monitors number of 5XX errors"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]
  dimensions = {
    TargetGroup  = module.carshub_frontend_lb.target_groups["carshub_frontend_lb_target_group"].arn
    LoadBalancer = "${module.carshub_frontend_lb.arn}"
  }
}

# ECS Task Restart Count - alerts on excessive task restarts which might indicate instability
module "carshub_frontend_ecs_task_restarts" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${module.carshub_cluster.cluster_name}-${module.carshub_cluster.services["ecs_frontend"].name}-high-task-restarts-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "TaskRestartCount"
  namespace           = "ECS/ContainerInsights"
  period              = "300" # 5 minutes
  statistic           = "Sum"
  threshold           = "3" # Alert if more than 3 restarts in 5 minutes
  alarm_description   = "This metric monitors excessive ECS task restarts"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    ClusterName = module.carshub_cluster.cluster_name
    ServiceName = module.carshub_cluster.services["ecs_frontend"].name
  }
}

# # -------------------------------------------------------------------------------------------------------------------------

# CPU Utilization Alarm
module "carshub_backend_ecs_service_high_cpu" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${module.carshub_cluster.cluster_name}-${module.carshub_cluster.services["ecs_backend"].name}-high-cpu-utilization-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS service CPU utilization"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    ClusterName = module.carshub_cluster.cluster_name
    ServiceName = module.carshub_cluster.services["ecs_backend"].name
  }

}

# Memory Utilization Alarm
module "carshub_backend_ecs_service_high_memory" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${module.carshub_cluster.cluster_name}-${module.carshub_cluster.services["ecs_backend"].name}-high-memory-utilization-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS service memory utilization"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    ClusterName = module.carshub_cluster.cluster_name
    ServiceName = module.carshub_cluster.services["ecs_backend"].name
  }
}

# Service Running Tasks Alarm - alerts if there are fewer than expected tasks
module "carshub_backend_ecs_service_running_tasks" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${module.carshub_cluster.cluster_name}-${module.carshub_cluster.services["ecs_backend"].name}-low-running-tasks-${var.env}-${var.region}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1" # Adjust based on your desired minimum task count
  alarm_description   = "This metric monitors the minimum number of running tasks"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    ClusterName = module.carshub_cluster.cluster_name
    ServiceName = module.carshub_cluster.services["ecs_backend"].name
  }
}

# Service Failed Deployment Alarm
module "carshub_backend_ecs_failed_deployments" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${module.carshub_cluster.cluster_name}-${module.carshub_cluster.services["ecs_backend"].name}-failed-deployments-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DeploymentFailures"
  namespace           = "ECS/ContainerInsights"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors ECS deployment failures"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    ClusterName = module.carshub_cluster.cluster_name
    ServiceName = module.carshub_cluster.services["ecs_backend"].name
  }
}

# Target Response Time Alarm (if using ALB)
module "carshub_backend_lb_high_response_time" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${module.carshub_cluster.cluster_name}-${module.carshub_cluster.services["ecs_backend"].name}-high-response-time-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  extended_statistic  = "p95"
  statistic           = "Average"
  threshold           = "1" # 1 second response time
  alarm_description   = "This metric monitors ALB target response time (p95)"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    TargetGroup  = module.carshub_backend_lb.target_groups["carshub_backend_lb_target_group"].arn
    LoadBalancer = "${module.carshub_backend_lb.arn}"
  }
}

# HTTP 5XX Error Rate Alarm (if using ALB)
module "carshub_backend_lb_high_5xx_errors" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${module.carshub_cluster.cluster_name}-${module.carshub_cluster.services["ecs_backend"].name}-high-5xx-errors-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10" # Adjust based on your traffic pattern
  alarm_description   = "This metric monitors number of 5XX errors"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    TargetGroup  = module.carshub_backend_lb.target_groups["carshub_backend_lb_target_group"].arn
    LoadBalancer = "${module.carshub_backend_lb.arn}"
  }
}

# ECS Task Restart Count - alerts on excessive task restarts which might indicate instability
module "carshub_backend_ecs_task_restarts" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${module.carshub_cluster.cluster_name}-${module.carshub_cluster.services["ecs_backend"].name}-high-task-restarts-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "TaskRestartCount"
  namespace           = "ECS/ContainerInsights"
  period              = "300" # 5 minutes
  statistic           = "Sum"
  threshold           = "3" # Alert if more than 3 restarts in 5 minutes
  alarm_description   = "This metric monitors excessive ECS task restarts"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    ClusterName = module.carshub_cluster.cluster_name
    ServiceName = module.carshub_cluster.services["ecs_backend"].name
  }
}

module "lambda_errors" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "carshub-media-update-lambda-errors-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when Lambda function errors > 0 in 5 minutes"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    FunctionName = module.carshub_media_update_function.function_name
  }
}

module "sqs_queue_depth" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "carshub-media-events-queue-depth-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Average"
  threshold           = 100
  alarm_description   = "Alarm when SQS queue depth > 100"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]

  dimensions = {
    QueueName = module.carshub_media_events_queue.name
  }
}

module "rds_high_cpu" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "carshub-rds-high-cpu-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when RDS CPU utilization > 80% for 10 minutes"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]
  dimensions = {
    DBInstanceIdentifier = module.carshub_db.name
  }
}

module "rds_low_storage" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "carshub-rds-low-storage-${var.env}-${var.region}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10737418240 # 10 GB in bytes
  alarm_description   = "Alarm when RDS free storage < 10 GB"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]
  dimensions = {
    DBInstanceIdentifier = module.carshub_db.name
  }
}

module "rds_high_connections" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "carshub-rds-high-connections-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 100
  alarm_description   = "Alarm when RDS connections exceed 80% of max"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]
  dimensions = {
    DBInstanceIdentifier = module.carshub_db.name
  }
}

module "rds_swap_usage_alarm" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "carshub-rds-swap-usage-${var.env}-${var.region}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "SwapUsage"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 1073741824
  alarm_description   = "Alert when RDS swap usage exceeds 1 GB"
  alarm_actions       = [module.carshub_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_alarm_notifications.topic_arn]
  dimensions = {
    DBInstanceIdentifier = module.carshub_db.id
  }
}

# -----------------------------------------------------------------------------------------
# Resource Group Configuration
# -----------------------------------------------------------------------------------------
resource "aws_resourcegroups_group" "carshub_resource_group" {
  name = "carshub-resource-group-${var.env}"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": ["AWS::AllSupported"],
  "TagFilters": [
    {
      "Key": "Project",
      "Values": ["${var.project}"]
    }
  ]
}
JSON
  }
}


# -----------------------------------------------------------------------------------------
# WAF Configuration
# -----------------------------------------------------------------------------------------
# module "carshub_waf" {
#   source = "../../../modules/waf"

#   # Naming — matches your existing convention
#   name = "carshub-waf-${var.env}-${var.region}"

#   # Attach WAF to the public-facing Frontend ALB
#   # Replace with your actual frontend ALB ARN output
#   frontend_alb_arn = module.carshub_frontend_lb.arn

#   # Reuse your existing SNS alarm topic — no new infra needed
#   alarm_topic_arn = module.carshub_alarm_notifications.topic_arn

#   # Account + region for log resource policy
#   account_id = data.aws_caller_identity.current.account_id
#   aws_region = var.region

#   # ---------------------------------------------------
#   # IP Management
#   # ---------------------------------------------------

#   # IPs to always block — add known attackers, threat intel here
#   blocked_ip_list = [
#     # "203.0.113.0/24",  # Example: known scanner range
#   ]

#   # IPs that bypass rate limiting — office, CI/CD, trusted partners
#   allowed_ip_list = [
#     # "YOUR_OFFICE_IP/32",
#     # "YOUR_CICD_RUNNER_IP/32",
#   ]

#   # ---------------------------------------------------
#   # Geo Blocking
#   # ---------------------------------------------------

#   # Block countries not in your target market
#   # Remove or leave empty [] if you serve global traffic
#   blocked_countries = [
#     # "KP",  # North Korea
#     # "IR",  # Iran
#     # "CU",  # Cuba
#     # "SY",  # Syria
#   ]

#   # ---------------------------------------------------
#   # Rate Limiting
#   # ---------------------------------------------------

#   # General rate limit per IP per 5-minute window
#   # 2000 = ~6-7 requests/second — comfortable for real users, blocks bots
#   rate_limit_requests = 2000

#   # Auth endpoints get a much tighter limit
#   # 100 = ~1 login attempt every 3 seconds per IP
#   auth_rate_limit_requests = 100

#   # ---------------------------------------------------
#   # Logging
#   # ---------------------------------------------------

#   # How long to keep WAF logs in CloudWatch
#   log_retention_days = 90

#   # ---------------------------------------------------
#   # Alarm Thresholds — tune after observing normal traffic
#   # ---------------------------------------------------

#   alarm_blocked_requests_threshold = 500
#   alarm_rate_limit_threshold       = 100
#   alarm_auth_rate_limit_threshold  = 20

#   tags = {
#     Name        = "carshub-waf-${var.env}-${var.region}"
#     Environment = var.env
#     Project     = var.project
#   }
# }
