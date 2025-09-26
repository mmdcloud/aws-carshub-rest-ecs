# Registering vault provider
data "vault_generic_secret" "rds" {
  path = "secret/rds"
}

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------------------
# VPC Configuration
# -----------------------------------------------------------------------------------------
module "carshub_vpc" {
  source                = "../../../modules/vpc/vpc"
  vpc_name              = "carshub-vpc-${var.env}-${var.region}"
  vpc_cidr_block        = "10.0.0.0/16"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  internet_gateway_name = "carshub-vpc-igw-${var.env}-${var.region}"
}

# Security Group
module "carshub_frontend_lb_sg" {
  source = "../../../modules/vpc/security_groups"
  vpc_id = module.carshub_vpc.vpc_id
  name   = "carshub-frontend-lb-sg-${var.env}-${var.region}"
  ingress = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      self            = "false"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      description     = "HTTP traffic"
    },
    {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      self            = "false"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      description     = "HTTPS traffic"
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "carshub_backend_lb_sg" {
  source = "../../../modules/vpc/security_groups"
  vpc_id = module.carshub_vpc.vpc_id
  name   = "carshub-backend-lb-sg-${var.env}-${var.region}"
  ingress = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      self            = "false"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      description     = "any"
    },
    {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      self            = "false"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      description     = "HTTPS traffic"
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "carshub_ecs_frontend_sg" {
  source = "../../../modules/vpc/security_groups"
  vpc_id = module.carshub_vpc.vpc_id
  name   = "carshub-ecs-frontend-sg-${var.env}-${var.region}"
  ingress = [
    {
      from_port       = 3000
      to_port         = 3000
      protocol        = "tcp"
      self            = "false"
      cidr_blocks     = []
      security_groups = [module.carshub_frontend_lb_sg.id]
      description     = "any"
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "carshub_ecs_backend_sg" {
  source = "../../../modules/vpc/security_groups"
  vpc_id = module.carshub_vpc.vpc_id
  name   = "carshub-ecs-backend-sg-${var.env}-${var.region}"
  ingress = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      self            = "false"
      cidr_blocks     = []
      security_groups = [module.carshub_backend_lb_sg.id]
      description     = "any"
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# RDS Security Group
module "carshub_rds_sg" {
  source = "../../../modules/vpc/security_groups"
  vpc_id = module.carshub_vpc.vpc_id
  name   = "carshub-rds-sg-${var.env}-${var.region}"
  ingress = [
    {
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      self            = "false"
      cidr_blocks     = []
      security_groups = [module.carshub_ecs_backend_sg.id]
      description     = "any"
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# Public Subnets
module "carshub_public_subnets" {
  source = "../../../modules/vpc/subnets"
  name   = "carshub-public-subnet-${var.env}-${var.region}"
  subnets = [
    {
      subnet = "10.0.1.0/24"
      az     = "${var.region}a"
    },
    {
      subnet = "10.0.2.0/24"
      az     = "${var.region}b"
    },
    {
      subnet = "10.0.3.0/24"
      az     = "${var.region}c"
    }
  ]
  vpc_id                  = module.carshub_vpc.vpc_id
  map_public_ip_on_launch = true
}

# Private Subnets
module "carshub_private_subnets" {
  source = "../../../modules/vpc/subnets"
  name   = "carshub-private-subnet-${var.env}-${var.region}"
  subnets = [
    {
      subnet = "10.0.6.0/24"
      az     = "${var.region}a"
    },
    {
      subnet = "10.0.5.0/24"
      az     = "${var.region}b"
    },
    {
      subnet = "10.0.4.0/24"
      az     = "${var.region}c"
    }
  ]
  vpc_id                  = module.carshub_vpc.vpc_id
  map_public_ip_on_launch = false
}

# Carshub Public Route Table
module "carshub_public_rt" {
  source  = "../../../modules/vpc/route_tables"
  name    = "carshub-public-route-table-${var.env}-${var.region}"
  subnets = module.carshub_public_subnets.subnets[*]
  routes = [
    {
      cidr_block     = "0.0.0.0/0"
      gateway_id     = module.carshub_vpc.igw_id
      nat_gateway_id = ""
    }
  ]
  vpc_id = module.carshub_vpc.vpc_id
}

resource "aws_eip" "carshub_nat_eip" {
  count  = length(module.carshub_public_subnets.subnets)
  domain = "vpc"

  tags = {
    Name = "carshub-nat-eip-${count.index + 1}"
  }
}

# NAT Gateways (one per AZ)
resource "aws_nat_gateway" "carshub_vpc_nat" {
  count = length(module.carshub_public_subnets.subnets)

  allocation_id = aws_eip.carshub_nat_eip[count.index].id
  subnet_id     = module.carshub_public_subnets.subnets[count.index].id

  tags = {
    Name = "carshub-nat-gateway-${count.index + 1}-${var.env}-${var.region}"
  }
}

resource "aws_route_table" "carshub_private_rt" {
  count  = length(aws_nat_gateway.carshub_vpc_nat)
  vpc_id = module.carshub_vpc.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.carshub_vpc_nat[count.index].id
  }

  tags = {
    Name = "carshub-private-route-table-${count.index + 1}-${var.env}-${var.region}"
  }
}

resource "aws_route_table_association" "carshub_private_rt_association" {
  count          = length(module.carshub_private_subnets.subnets)
  subnet_id      = module.carshub_private_subnets.subnets[count.index].id
  route_table_id = aws_route_table.carshub_private_rt[count.index].id
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
}

# -----------------------------------------------------------------------------------------
# VPC Flow Logs
# -----------------------------------------------------------------------------------------

# IAM Role for VPC Flow Logs
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
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents",
                  "logs:DescribeLogGroups",
                  "logs:DescribeLogStreams"
                ],
                "Resource": "*",
                "Effect": "Allow"
            }
        ]
    }
    EOF
}

resource "aws_cloudwatch_log_group" "carshub_flow_log_group" {
  name              = "/aws/vpc/flow-logs/carshub-application-${var.env}-${var.region}"
  retention_in_days = 365
}

# Add VPC Flow Logs for security monitoring
resource "aws_flow_log" "carshub_vpc_flow_log" {
  iam_role_arn    = module.flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.carshub_flow_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = module.carshub_vpc.vpc_id
}

# -----------------------------------------------------------------------------------------
# ECR Module
# -----------------------------------------------------------------------------------------

# Frontend Repo
module "carshub_frontend_container_registry" {
  source               = "../../../modules/ecr"
  force_delete         = true
  scan_on_push         = false
  image_tag_mutability = "IMMUTABLE"
  bash_command         = "bash ${path.cwd}/../../../../../src/frontend/artifact_push.sh carshub-frontend-${var.env}-${var.region} ${var.region} http://${module.carshub_backend_lb.lb_dns_name} ${module.carshub_media_cloudfront_distribution.domain_name}"
  name                 = "carshub-frontend-${var.env}-${var.region}"
}

# 2. Backend Repo
module "carshub_backend_container_registry" {
  source               = "../../../modules/ecr"
  force_delete         = true
  scan_on_push         = false
  image_tag_mutability = "IMMUTABLE"
  bash_command         = "bash ${path.cwd}/../../../../../src/backend/api/artifact_push.sh carshub-backend-${var.env}-${var.region} ${var.region}"
  name                 = "carshub-backend-${var.env}-${var.region}"
}

# -----------------------------------------------------------------------------------------
# RDS Instance
# -----------------------------------------------------------------------------------------

# IAM Role for Enhanced Monitoring
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


module "carshub_db" {
  source                          = "../../../modules/rds"
  db_name                         = "carshubdb${var.env}useast1"
  allocated_storage               = 100
  storage_type                    = "gp3"
  engine                          = "mysql"
  engine_version                  = "8.0.40"
  instance_class                  = "db.r6g.large"
  multi_az                        = true
  username                        = tostring(data.vault_generic_secret.rds.data["username"])
  password                        = tostring(data.vault_generic_secret.rds.data["password"])
  subnet_group_name               = "carshub-rds-subnet-group-${var.env}-${var.region}"
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  backup_retention_period         = 35
  backup_window                   = "03:00-06:00"
  subnet_group_ids = [
    module.carshub_private_subnets.subnets[0].id,
    module.carshub_private_subnets.subnets[1].id,
    module.carshub_private_subnets.subnets[2].id
  ]
  vpc_security_group_ids                = [module.carshub_rds_sg.id]
  publicly_accessible                   = false
  deletion_protection                   = false
  skip_final_snapshot                   = true
  max_allocated_storage                 = 500
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  monitoring_interval                   = 60
  monitoring_role_arn                   = aws_iam_role.rds_monitoring_role.arn
  parameter_group_name                  = "carshub-db-pg-${var.env}-${var.region}"
  parameter_group_family                = "mysql8.0"
  parameters = [
    {
      name  = "max_connections"
      value = "1000"
    },
    {
      name  = "innodb_buffer_pool_size"
      value = "{DBInstanceClassMemory*3/4}"
    },
    {
      name  = "slow_query_log"
      value = "1"
    }
  ]
}

# -----------------------------------------------------------------------------------------
# S3 Configuration
# -----------------------------------------------------------------------------------------

module "carshub_media_bucket" {
  source      = "../../../modules/s3"
  bucket_name = "carshub-media-bucket${var.env}-${var.region}"
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
      allowed_headers = ["${module.carshub_frontend_lb.lb_dns_name}"]
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
  # Note: Lifecycle policies should be configured in the S3 module
  # or as separate aws_s3_bucket_lifecycle_configuration resources
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
}

# Signing profile
module "carshub_signing_profile" {
  source                           = "../../../modules/signing-profile"
  platform_id                      = "AWSLambda-SHA384-ECDSA"
  signature_validity_value         = 5
  signature_validity_type          = "YEARS"
  ignore_signing_job_failure       = true
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
  source                        = "../../../modules/sqs"
  queue_name                    = "carshub-media-events-queue-${var.env}-${var.region}"
  delay_seconds                 = 0
  maxReceiveCount               = 3
  dlq_message_retention_seconds = 86400
  dlq_name                      = "carshub-media-events-dlq-${var.env}-${var.region}"
  max_message_size              = 262144
  message_retention_seconds     = 345600
  visibility_timeout_seconds    = 180
  receive_wait_time_seconds     = 20
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
              "Resource": "${module.carshub_db_credentials.arn}"
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
            }
        ]
    }
    EOF
}

# Lambda Layer for storing dependencies
resource "aws_lambda_layer_version" "python_layer" {
  filename            = "../../../files/python.zip"
  layer_name          = "python"
  compatible_runtimes = ["python3.12"]
}

# Lambda function to update media metadata in RDS database
module "carshub_media_update_function" {
  source        = "../../../modules/lambda"
  function_name = "carshub-media-update-${var.env}-${var.region}"
  role_arn      = module.carshub_media_update_function_iam_role.arn
  permissions   = []
  env_variables = {
    SECRET_NAME = module.carshub_db_credentials.name
    DB_HOST     = tostring(split(":", module.carshub_db.endpoint)[0])
    DB_NAME     = var.db_name
    REGION      = var.region
  }
  handler                 = "lambda.lambda_handler"
  runtime                 = "python3.12"
  s3_bucket               = module.carshub_media_update_function_code.bucket
  s3_key                  = "lambda.zip"
  layers                  = [aws_lambda_layer_version.python_layer.arn]
  code_signing_config_arn = module.carshub_signing_profile.config_arn
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
      origin_id           = "carshub-media-bucket-${var.env}"
      domain_name         = "carshub-media-bucket-${var.env}.s3.${var.region}.amazonaws.com"
      connection_attempts = 3
      connection_timeout  = 10
    }
  ]
  compress                       = true
  smooth_streaming               = false
  target_origin_id               = "carshub-media-bucket-${var.env}"
  allowed_methods                = ["GET", "HEAD"]
  cached_methods                 = ["GET", "HEAD"]
  viewer_protocol_policy         = "redirect-to-https"
  min_ttl                        = 0
  default_ttl                    = 86400
  max_ttl                        = 31536000
  price_class                    = "PriceClass_100"
  forward_cookies                = "all"
  cloudfront_default_certificate = true
  geo_restriction_type           = "none"
  query_string                   = true
}

# -----------------------------------------------------------------------------------------
# Load Balancer Configuration
# -----------------------------------------------------------------------------------------
# Frontend Load Balancer
module "carshub_frontend_lb" {
  source                     = "../../../modules/load-balancer"
  lb_name                    = "frontend-lb-${var.env}-${var.region}"
  lb_is_internal             = false
  lb_ip_address_type         = "ipv4"
  load_balancer_type         = "application"
  drop_invalid_header_fields = true
  enable_deletion_protection = false
  security_groups            = [module.carshub_frontend_lb_sg.id]
  subnets                    = module.carshub_public_subnets.subnets[*].id
  target_groups = [
    {
      target_group_name      = "frontend-tg-${var.env}-${var.region}"
      target_port            = 3000
      target_ip_address_type = "ipv4"
      target_protocol        = "HTTP"
      target_type            = "ip"
      target_vpc_id          = module.carshub_vpc.vpc_id

      health_check_interval            = 30
      health_check_path                = "/auth/signin"
      health_check_enabled             = true
      health_check_protocol            = "HTTP"
      health_check_timeout             = 5
      health_check_healthy_threshold   = 3
      health_check_unhealthy_threshold = 3
      health_check_port                = 3000

    }
  ]
  listeners = [
    {
      listener_port     = 80
      listener_protocol = "HTTP"
      certificate_arn   = null
      default_actions = [
        {
          type             = "forward"
          target_group_arn = module.carshub_frontend_lb.target_groups[0].arn
        }
      ]
    },
    # TODO : Uncomment this while using HTTPS
    # {
    #   listener_port     = 443
    #   listener_protocol = "HTTPS"
    #   certificate_arn   = aws_acm_certificate.frontend_cert.arn
    #   default_actions = [
    #     {
    #       type             = "forward"
    #       target_group_arn = module.carshub_frontend_lb.target_groups[0].arn
    #     }
    #   ]
    # }
  ]
}

# Backend Load Balancer
module "carshub_backend_lb" {
  source                     = "../../../modules/load-balancer"
  lb_name                    = "backend-lb-${var.env}-${var.region}"
  lb_is_internal             = false
  lb_ip_address_type         = "ipv4"
  load_balancer_type         = "application"
  enable_deletion_protection = false
  drop_invalid_header_fields = true
  security_groups            = [module.carshub_backend_lb_sg.id]
  subnets                    = module.carshub_public_subnets.subnets[*].id
  target_groups = [
    {
      target_group_name      = "backend-tg-${var.env}-${var.region}"
      target_port            = 80
      target_ip_address_type = "ipv4"
      target_protocol        = "HTTP"
      target_type            = "ip"
      target_vpc_id          = module.carshub_vpc.vpc_id

      health_check_interval            = 30
      health_check_path                = "/"
      health_check_enabled             = true
      health_check_protocol            = "HTTP"
      health_check_timeout             = 5
      health_check_healthy_threshold   = 3
      health_check_unhealthy_threshold = 3
      health_check_port                = 80
    }
  ]
  listeners = [
    {
      listener_port     = 80
      listener_protocol = "HTTP"
      certificate_arn   = null
      default_actions = [
        {
          type             = "forward"
          target_group_arn = module.carshub_backend_lb.target_groups[0].arn
        }
      ]
    },
    # TODO : Uncomment this while using HTTPS
    # {
    #   listener_port     = 443
    #   listener_protocol = "HTTPS"
    #   certificate_arn   = aws_acm_certificate.frontend_cert.arn
    #   default_actions = [
    #     {
    #       type             = "forward"
    #       target_group_arn = module.carshub_frontend_lb.target_groups[0].arn
    #     }
    #   ]
    # }
  ]
}

# -----------------------------------------------------------------------------------------
# ECS Configuration
# -----------------------------------------------------------------------------------------

resource "aws_ecs_cluster" "carshub_cluster" {
  name = "carshub-cluster-${var.env}-${var.region}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Cloudwatch log groups for ecs service logs
module "carshub_frontend_ecs_log_group" {
  source            = "../../../modules/cloudwatch/cloudwatch-log-group"
  log_group_name    = "/ecs/carshub-frontend-${var.env}-${var.region}"
  retention_in_days = 30
}

module "carshub_backend_ecs_log_group" {
  source            = "../../../modules/cloudwatch/cloudwatch-log-group"
  log_group_name    = "/ecs/carshub-backend-${var.env}-${var.region}"
  retention_in_days = 30
}

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
                "Action": [
                  "s3:PutObject"
                ],
                "Resource": "*",
                "Effect": "Allow"
            },
            {
              "Effect": "Allow",
              "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
              ],
              "Resource": "${module.carshub_db_credentials.arn}"
            }
        ]
    }
    EOF
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

# Frontend ECS Configuration
module "carshub_frontend_ecs" {
  source                                   = "../../../modules/ecs"
  task_definition_family                   = "carshub-frontend-task-definition-${var.env}-${var.region}"
  task_definition_requires_compatibilities = ["FARGATE"]
  task_definition_cpu                      = 2048
  task_definition_memory                   = 4096
  task_definition_execution_role_arn       = module.ecs_task_execution_role.arn
  task_definition_task_role_arn            = module.ecs_task_execution_role.arn
  task_definition_network_mode             = "awsvpc"
  task_definition_cpu_architecture         = "X86_64"
  task_definition_operating_system_family  = "LINUX"
  task_definition_container_definitions = jsonencode(
    [
      {
        "name" : "carshub-frontend-${var.env}-${var.region}",
        "image" : "${module.carshub_frontend_container_registry.repository_url}:latest",
        "cpu" : 1024,
        "memory" : 2048,
        "placementStrategy" : [
          { "type" : "spread", "field" : "attribute:ecs.availability-zone" }
        ]
        "essential" : true,
        "healthCheck" : {
          "command" : ["CMD-SHELL", "curl -f http://localhost:3000/auth/signin || exit 1"],
          "interval" : 30,
          "timeout" : 5,
          "retries" : 3,
          "startPeriod" : 60
        },
        "ulimits" : [
          {
            "name" : "nofile",
            "softLimit" : 65536,
            "hardLimit" : 65536
          }
        ]
        "portMappings" : [
          {
            "containerPort" : 3000,
            "hostPort" : 3000,
            "name" : "carshub-frontend-${var.env}-${var.region}"
          }
        ],
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : "${module.carshub_frontend_ecs_log_group.name}",
            "awslogs-region" : "${var.region}",
            "awslogs-stream-prefix" : "ecs"
          }
        },
        environment = [
          {
            name  = "BASE_URL"
            value = "${module.carshub_backend_lb.lb_dns_name}"
          },
          {
            name  = "CDN_URL"
            value = "${module.carshub_media_cloudfront_distribution.domain_name}"
          }
        ]
      },
      {
        "name" : "xray-daemon",
        "image" : "amazon/aws-xray-daemon",
        "cpu" : 32,
        "memoryReservation" : 256,
        "portMappings" : [
          {
            "containerPort" : 2000,
            "protocol" : "udp"
          }
        ]
      },
  ])

  service_name                = "carshub-frontend-ecs-service-${var.env}-${var.region}"
  service_cluster             = aws_ecs_cluster.carshub_cluster.id
  service_launch_type         = "FARGATE"
  service_scheduling_strategy = "REPLICA"
  service_desired_count       = 2

  deployment_controller_type = "ECS"
  load_balancer_config = [{
    container_name   = "carshub-frontend-${var.env}-${var.region}"
    container_port   = 3000
    target_group_arn = module.carshub_frontend_lb.target_groups[0].arn
  }]

  security_groups = [module.carshub_ecs_frontend_sg.id]
  subnets = [
    module.carshub_private_subnets.subnets[0].id,
    module.carshub_private_subnets.subnets[1].id,
    module.carshub_private_subnets.subnets[2].id
  ]
  assign_public_ip = false
}

# Backend ECS Configuration
module "carshub_backend_ecs" {
  source                                   = "../../../modules/ecs"
  task_definition_family                   = "carshub-backend-task-definition-${var.env}-${var.region}"
  task_definition_requires_compatibilities = ["FARGATE"]
  task_definition_cpu                      = 2048
  task_definition_memory                   = 4096
  task_definition_execution_role_arn       = module.ecs_task_execution_role.arn
  task_definition_task_role_arn            = module.ecs_task_execution_role.arn
  task_definition_network_mode             = "awsvpc"
  task_definition_cpu_architecture         = "X86_64"
  task_definition_operating_system_family  = "LINUX"
  task_definition_container_definitions = jsonencode(
    [
      {
        "name" : "carshub-backend-${var.env}-${var.region}",
        "image" : "${module.carshub_backend_container_registry.repository_url}:latest",
        "cpu" : 1024,
        "memory" : 2048,
        "placementStrategy" : [
          { "type" : "spread", "field" : "attribute:ecs.availability-zone" }
        ]
        "essential" : true,
        "secrets" : [
          {
            "name" : "UN",
            "valueFrom" : "${module.carshub_db_credentials.arn}:username::"
          },
          {
            "name" : "CREDS",
            "valueFrom" : "${module.carshub_db_credentials.arn}:password::"
          }
        ],
        "healthCheck" : {
          "command" : ["CMD-SHELL", "curl -f http://localhost:80 || exit 1"],
          "interval" : 30,
          "timeout" : 5,
          "retries" : 3,
          "startPeriod" : 60
        },
        "ulimits" : [
          {
            "name" : "nofile",
            "softLimit" : 65536,
            "hardLimit" : 65536
          }
        ]
        "portMappings" : [
          {
            "containerPort" : 80,
            "hostPort" : 80,
            "name" : "carshub-backend-${var.env}-${var.region}"
          }
        ],
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : "${module.carshub_backend_ecs_log_group.name}",
            "awslogs-region" : "${var.region}",
            "awslogs-stream-prefix" : "ecs"
          }
        },
        environment = [
          {
            name  = "DB_PATH"
            value = "${tostring(split(":", module.carshub_db.endpoint)[0])}"
          },
          {
            name  = "DB_NAME"
            value = "${module.carshub_db.name}"
          }
        ]
      },
      {
        "name" : "xray-daemon",
        "image" : "amazon/aws-xray-daemon",
        "cpu" : 32,
        "memoryReservation" : 256,
        "portMappings" : [
          {
            "containerPort" : 2000,
            "protocol" : "udp"
          }
        ]
      }
  ])

  service_name                = "carshub-backend-ecs-service-${var.env}-${var.region}"
  service_cluster             = aws_ecs_cluster.carshub_cluster.id
  service_launch_type         = "FARGATE"
  service_scheduling_strategy = "REPLICA"
  service_desired_count       = 2

  deployment_controller_type = "ECS"
  load_balancer_config = [{
    container_name   = "carshub-backend-${var.env}-${var.region}"
    container_port   = 80
    target_group_arn = module.carshub_backend_lb.target_groups[0].arn
  }]

  security_groups = [module.carshub_ecs_backend_sg.id]
  subnets = [
    module.carshub_private_subnets.subnets[0].id,
    module.carshub_private_subnets.subnets[1].id,
    module.carshub_private_subnets.subnets[2].id
  ]
  assign_public_ip = false
}


# Module for App Autoscaling Policy
module "carshub_frontend_app_autoscaling_policy" {
  source                    = "../../../modules/autoscaling"
  min_capacity              = 2
  max_capacity              = 10
  target_resource_id        = "service/${aws_ecs_cluster.carshub_cluster.name}/${module.carshub_frontend_ecs.name}"
  target_scalable_dimension = "ecs:service:DesiredCount"
  target_service_namespace  = "ecs"
  policies = [
    {
      name                    = "carshub-frontend-autoscaling-policy-${var.env}-${var.region}"
      adjustment_type         = "ChangeInCapacity"
      cooldown                = 60
      metric_aggregation_type = "Average"
      steps = [
        {
          metric_interval_lower_bound = 0
          metric_interval_upper_bound = 20
          scaling_adjustment          = 1
        },
        {
          metric_interval_lower_bound = 20
          scaling_adjustment          = 2
        }
      ]
    }
  ]
}

module "carshub_backend_app_autoscaling_policy" {
  source                    = "../../../modules/autoscaling"
  min_capacity              = 2
  max_capacity              = 10
  target_resource_id        = "service/${aws_ecs_cluster.carshub_cluster.name}/${module.carshub_backend_ecs.name}"
  target_scalable_dimension = "ecs:service:DesiredCount"
  target_service_namespace  = "ecs"
  policies = [
    {
      name                    = "carshub-backend-autoscaling-policy-${var.env}-${var.region}"
      adjustment_type         = "ChangeInCapacity"
      cooldown                = 60
      metric_aggregation_type = "Average"
      steps = [
        {
          metric_interval_lower_bound = 0
          metric_interval_upper_bound = 20
          scaling_adjustment          = 1
        },
        {
          metric_interval_lower_bound = 20
          scaling_adjustment          = 2
        }
      ]
    }
  ]
}

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
}

# CPU Utilization Alarm
module "carshub_frontend_ecs_service_high_cpu" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${aws_ecs_cluster.carshub_cluster.name}-${module.carshub_frontend_ecs.name}-high-cpu-utilization-${var.env}-${var.region}"
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
    ClusterName = aws_ecs_cluster.carshub_cluster.name
    ServiceName = module.carshub_frontend_ecs.name
  }
}

# Memory Utilization Alarm
module "carshub_frontend_ecs_service_high_memory" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${aws_ecs_cluster.carshub_cluster.name}-${module.carshub_frontend_ecs.name}-high-memory-utilization-${var.env}-${var.region}"
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
    ClusterName = aws_ecs_cluster.carshub_cluster.name
    ServiceName = module.carshub_frontend_ecs.name
  }
}

# Service Running Tasks Alarm - alerts if there are fewer than expected tasks
module "carshub_frontend_ecs_service_running_tasks" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${aws_ecs_cluster.carshub_cluster.name}-${module.carshub_frontend_ecs.name}-low-running-tasks-${var.env}-${var.region}"
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
    ClusterName = aws_ecs_cluster.carshub_cluster.name
    ServiceName = module.carshub_frontend_ecs.name
  }
}

# Service Failed Deployment Alarm
module "carshub_frontend_ecs_failed_deployments" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${aws_ecs_cluster.carshub_cluster.name}-${module.carshub_frontend_ecs.name}-failed-deployments-${var.env}-${var.region}"
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
    ClusterName = aws_ecs_cluster.carshub_cluster.name
    ServiceName = module.carshub_frontend_ecs.name
  }
}

# Target Response Time Alarm (if using ALB)
module "carshub_frontend_ecs_alb_high_response_time" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${aws_ecs_cluster.carshub_cluster.name}-${module.carshub_frontend_ecs.name}-high-response-time-${var.env}-${var.region}"
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
  alarm_name          = "${aws_ecs_cluster.carshub_cluster.name}-${module.carshub_frontend_ecs.name}-high-5xx-errors-${var.env}-${var.region}"
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
    TargetGroup  = module.carshub_frontend_lb.target_groups[0].arn
    LoadBalancer = "${module.carshub_frontend_lb.arn}"
  }
}

# ECS Task Restart Count - alerts on excessive task restarts which might indicate instability
module "carshub_frontend_ecs_task_restarts" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${aws_ecs_cluster.carshub_cluster.name}-${module.carshub_frontend_ecs.name}-high-task-restarts-${var.env}-${var.region}"
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
    ClusterName = aws_ecs_cluster.carshub_cluster.name
    ServiceName = module.carshub_frontend_ecs.name
  }
}

# # -------------------------------------------------------------------------------------------------------------------------

# CPU Utilization Alarm
module "carshub_backend_ecs_service_high_cpu" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${aws_ecs_cluster.carshub_cluster.name}-${module.carshub_backend_ecs.name}-high-cpu-utilization-${var.env}-${var.region}"
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
    ClusterName = aws_ecs_cluster.carshub_cluster.name
    ServiceName = module.carshub_backend_ecs.name
  }

}

# Memory Utilization Alarm
module "carshub_backend_ecs_service_high_memory" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${aws_ecs_cluster.carshub_cluster.name}-${module.carshub_backend_ecs.name}-high-memory-utilization-${var.env}-${var.region}"
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
    ClusterName = aws_ecs_cluster.carshub_cluster.name
    ServiceName = module.carshub_backend_ecs.name
  }
}

# Service Running Tasks Alarm - alerts if there are fewer than expected tasks
module "carshub_backend_ecs_service_running_tasks" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${aws_ecs_cluster.carshub_cluster.name}-${module.carshub_backend_ecs.name}-low-running-tasks-${var.env}-${var.region}"
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
    ClusterName = aws_ecs_cluster.carshub_cluster.name
    ServiceName = module.carshub_backend_ecs.name
  }
}

# Service Failed Deployment Alarm
module "carshub_backend_ecs_failed_deployments" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${aws_ecs_cluster.carshub_cluster.name}-${module.carshub_backend_ecs.name}-failed-deployments-${var.env}-${var.region}"
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
    ClusterName = aws_ecs_cluster.carshub_cluster.name
    ServiceName = module.carshub_backend_ecs.name
  }
}

# Target Response Time Alarm (if using ALB)
module "carshub_backend_lb_high_response_time" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${aws_ecs_cluster.carshub_cluster.name}-${module.carshub_backend_ecs.name}-high-response-time-${var.env}-${var.region}"
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
    TargetGroup  = module.carshub_backend_lb.target_groups[0].arn
    LoadBalancer = "${module.carshub_backend_lb.arn}"
  }
}

# HTTP 5XX Error Rate Alarm (if using ALB)
module "carshub_backend_lb_high_5xx_errors" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${aws_ecs_cluster.carshub_cluster.name}-${module.carshub_backend_ecs.name}-high-5xx-errors-${var.env}-${var.region}"
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
    TargetGroup  = module.carshub_backend_lb.target_groups[0].arn
    LoadBalancer = "${module.carshub_backend_lb.arn}"
  }
}

# ECS Task Restart Count - alerts on excessive task restarts which might indicate instability
module "carshub_backend_ecs_task_restarts" {
  source              = "../../../modules/cloudwatch/cloudwatch-alarm"
  alarm_name          = "${aws_ecs_cluster.carshub_cluster.name}-${module.carshub_backend_ecs.name}-high-task-restarts-${var.env}-${var.region}"
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
    ClusterName = aws_ecs_cluster.carshub_cluster.name
    ServiceName = module.carshub_backend_ecs.name
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

# -----------------------------------------------------------------------------------------
# CodeBuild Configuration
# -----------------------------------------------------------------------------------------

module "codebuild_cache_bucket" {
  source        = "../../../modules/s3"
  bucket_name   = "codebuild-cache-bucket-${var.env}-${var.region}"
  objects       = []
  bucket_policy = ""
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
}

# CodeBuild IAM Role
module "carshub_codebuild_iam_role" {
  source             = "../../../modules/iam"
  role_name          = "carshub-codebuild-role-${var.env}-${var.region}"
  role_description   = "IAM role for creating a building and pushing images to ECR for carshub frontend and backend applications"
  policy_name        = "carshub-codebuild-policy-${var.env}-${var.region}"
  policy_description = "IAM policy for creating a building and pushing images to ECR for carshub frontend and backend applications"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                  "Service": "codebuild.amazonaws.com"
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
                "Resource": "*",
                "Effect": "Allow"
            },
            {
                "Action": [
                  "s3:GetObject",
                  "s3:PutObject",
                  "s3:GetObjectVersion",
                  "s3:GetBucketAcl",
                  "s3:GetBucketLocation"
                ],
                "Resource": [
                  "${module.codebuild_cache_bucket.arn}",
                  "${module.codebuild_cache_bucket.arn}/*"
                ],
                "Effect": "Allow"
            },
            {
                "Action": [
                  "ecr:GetAuthorizationToken"
                ],
                "Resource": "*",
                "Effect": "Allow"
            },
            {
                "Action": [
                  "ecr:BatchGetImage",
                  "ecr:BatchCheckLayerAvailability",
                  "ecr:CompleteLayerUpload",
                  "ecr:DescribeImages",
                  "ecr:DescribeRepositories",
                  "ecr:GetDownloadUrlForLayer",
                  "ecr:InitiateLayerUpload",
                  "ecr:ListImages",
                  "ecr:PutImage",
                  "ecr:UploadLayerPart"
                ],
                "Resource": [
                  "${module.carshub_frontend_container_registry.arn}",
                  "${module.carshub_backend_container_registry.arn}"
                ],
                "Effect": "Allow"
            }
        ]
    }
    EOF
}

module "carshub_codebuild_frontend" {
  source                        = "../../../modules/devops/codebuild"
  build_timeout                 = 60
  cache_bucket_name             = module.codebuild_cache_bucket.bucket
  cloudwatch_group_name         = "/aws/codebuild/carshub-codebuiild-frontend-${var.env}-${var.region}"
  cloudwatch_stream_name        = "carshub-codebuiild-frontend-stream-${var.env}-${var.region}"
  codebuild_project_description = "carshub-codebuild-frontend-${var.env}-${var.region}"
  codebuild_project_name        = "carshub-codebuild-frontend-${var.env}-${var.region}"
  role                          = module.carshub_codebuild_iam_role.arn
  compute_type                  = "BUILD_GENERAL1_SMALL"
  env_image                     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  env_type                      = "LINUX_CONTAINER"
  fetch_submodules              = true
  force_destroy_cache_bucket    = true
  image_pull_credentials_type   = "CODEBUILD"
  privileged_mode               = true
  source_location               = "https://github.com/mmdcloud/aws-carshub-rest-ecs.git"
  source_git_clone_depth        = "1"
  source_type                   = "GITHUB"
  source_version                = "frontend"
  environment_variables = [
    {
      name  = "ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    },
    {
      name  = "REGION"
      value = "${var.region}"
    },
    {
      name  = "REPO"
      value = "carshub-frontend-${var.env}"
    }
  ]
}

module "carshub_codebuild_backend" {
  source                        = "../../../modules/devops/codebuild"
  build_timeout                 = 60
  cache_bucket_name             = module.codebuild_cache_bucket.bucket
  cloudwatch_group_name         = "/aws/codebuild/carshub-codebuiild-backend-${var.env}-${var.region}"
  cloudwatch_stream_name        = "carshub-codebuiild-backend-stream-${var.env}-${var.region}"
  codebuild_project_description = "carshub-codebuild-backend-${var.env}-${var.region}"
  codebuild_project_name        = "carshub-codebuild-backend-${var.env}-${var.region}"
  role                          = module.carshub_codebuild_iam_role.arn
  compute_type                  = "BUILD_GENERAL1_SMALL"
  env_image                     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  env_type                      = "LINUX_CONTAINER"
  fetch_submodules              = true
  force_destroy_cache_bucket    = true
  image_pull_credentials_type   = "CODEBUILD"
  privileged_mode               = true
  source_location               = "https://github.com/mmdcloud/aws-carshub-rest-ecs.git"
  source_git_clone_depth        = "1"
  source_type                   = "GITHUB"
  source_version                = "backend"
  environment_variables = [
    {
      name  = "ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    },
    {
      name  = "REGION"
      value = "${var.region}"
    },
    {
      name  = "REPO"
      value = "carshub-backend-${var.env}"
    }
  ]
}

# -----------------------------------------------------------------------------------------
# CodePipeline Configuration
# -----------------------------------------------------------------------------------------

module "carshub_frontend_codepipeline_bucket" {
  source        = "../../../modules/s3"
  bucket_name   = "carshub-frontend-codepipeline-bucket-${var.env}-${var.region}"
  objects       = []
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

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CodePipeline backend artifact bucket
module "carshub_backend_codepipeline_bucket" {
  source        = "../../../modules/s3"
  bucket_name   = "carshub-backend-codepipeline-bucket-${var.env}-${var.region}"
  objects       = []
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

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CodePipleine IAM Role
resource "aws_codestarconnections_connection" "carshub_codepipeline_codestar_connection" {
  name          = "carshub-codestar-connection"
  provider_type = "GitHub"
}

module "carshub_codepipeline_role" {
  source             = "../../../modules/iam"
  role_name          = "carshub-codepipeline-role-${var.env}-${var.region}"
  role_description   = "IAM role for carshub codepipeline to access S3, CodeDeploy, CodeStar Connections, and CodeBuild"
  policy_name        = "carshub-codepipeline-policy-${var.env}-${var.region}"
  policy_description = "IAM policy for carshub codepipeline to access S3, CodeDeploy, CodeStar Connections, and CodeBuild"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                  "Service": "codepipeline.amazonaws.com"
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
                  "s3:GetObject",
                  "s3:GetObjectVersion",
                  "s3:GetBucketVersioning",
                  "s3:PutObjectAcl",
                  "s3:PutObject"
                ],
                "Resource": [
                  "${module.carshub_frontend_codepipeline_bucket.arn}",
                  "${module.carshub_frontend_codepipeline_bucket.arn}/*",
                  "${module.carshub_backend_codepipeline_bucket.arn}",
                  "${module.carshub_backend_codepipeline_bucket.arn}/*"
                ],
                "Effect": "Allow"
            },
            {
                "Action": [
                  "codedeploy:GetDeploymentConfig"
                ],
                "Resource": [
                  "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.OneAtATime"
                ],
                "Effect": "Allow"
            },
            {
                "Action": [
                  "codestar-connections:UseConnection"
                ],
                "Resource": [
                  "${aws_codestarconnections_connection.carshub_codepipeline_codestar_connection.arn}"
                ],
                "Effect": "Allow"
            },
            {
                "Action": [
                  "codebuild:BatchGetBuilds",
                  "codebuild:StartBuild"
                ],
                "Resource": [
                  "${module.carshub_codebuild_frontend.arn}",
                  "${module.carshub_codebuild_backend.arn}"                
                ],
                "Effect": "Allow"
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline_ecs_full_access" {
  role       = module.carshub_codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# CodePipeline for Frontend
module "carshub_frontend_codepipeline" {
  source              = "../../../modules/devops/codepipeline"
  name                = "carshub-frontend-codepipeline-${var.env}-${var.region}"
  role_arn            = module.carshub_codepipeline_role.arn
  artifact_bucket     = module.carshub_frontend_codepipeline_bucket.bucket
  artifact_store_type = "S3"
  stages = [
    {
      name = "Source"
      actions = [
        {
          name             = "Source"
          category         = "Source"
          owner            = "AWS"
          provider         = "CodeStarSourceConnection"
          version          = "1"
          action_type_id   = "Source"
          run_order        = 1
          input_artifacts  = []
          output_artifacts = ["source_output"]
          configuration = {
            FullRepositoryId = "mmdcloud/aws-carshub-rest-ecs"
            BranchName       = "frontend"
            ConnectionArn    = "${aws_codestarconnections_connection.carshub_codepipeline_codestar_connection.arn}"
          }
        }
      ]
    },
    {
      name = "Build"
      actions = [
        {
          name             = "Build"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          action_type_id   = "Build"
          run_order        = 1
          input_artifacts  = ["source_output"]
          output_artifacts = ["build_output"]
          configuration = {
            ProjectName   = "${module.carshub_codebuild_frontend.project_name}"
            PrimarySource = "source_output"
            # EnvironmentVariables = jsonencode(module.carshub_codebuild_frontend.environment_variables)
          }
        }
      ]
    },
    {
      name = "Approval"
      actions = [{
        name             = "ManualApproval"
        category         = "Approval"
        owner            = "AWS"
        provider         = "Manual"
        input_artifacts  = []
        output_artifacts = []
        version          = "1"
        configuration = {
          NotificationArn = "${module.carshub_alarm_notifications.topic_arn}"
          CustomData      = "Approve production deployment"
        }
      }]
    },
    {
      name = "Deploy"
      actions = [
        {
          name             = "DeployToECS"
          category         = "Deploy"
          owner            = "AWS"
          provider         = "ECS"
          version          = "1"
          action_type_id   = "DeployToECS"
          run_order        = 1
          input_artifacts  = ["build_output"]
          output_artifacts = []
          configuration = {
            ClusterName = "${aws_ecs_cluster.carshub_cluster.name}"
            ServiceName = "${module.carshub_frontend_ecs.name}"
            FileName    = "imagedefinitions.json"
          }
        }
      ]
    }
  ]
}

# CodePipeline for Backend
module "carshub_backend_codepipeline" {
  source              = "../../../modules/devops/codepipeline"
  name                = "carshub-backend-codepipeline-${var.env}-${var.region}"
  role_arn            = module.carshub_codepipeline_role.arn
  artifact_bucket     = module.carshub_backend_codepipeline_bucket.bucket
  artifact_store_type = "S3"
  stages = [
    {
      name = "Source"
      actions = [
        {
          name             = "Source"
          category         = "Source"
          owner            = "AWS"
          provider         = "CodeStarSourceConnection"
          version          = "1"
          action_type_id   = "Source"
          run_order        = 1
          input_artifacts  = []
          output_artifacts = ["source_output"]
          configuration = {
            FullRepositoryId = "mmdcloud/aws-carshub-rest-ecs"
            BranchName       = "backend"
            ConnectionArn    = "${aws_codestarconnections_connection.carshub_codepipeline_codestar_connection.arn}"
          }
        }
      ]
    },
    {
      name = "Build"
      actions = [
        {
          name             = "Build"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          action_type_id   = "Build"
          run_order        = 1
          input_artifacts  = ["source_output"]
          output_artifacts = ["build_output"]
          configuration = {
            ProjectName   = "${module.carshub_codebuild_backend.project_name}"
            PrimarySource = "source_output"
            # EnvironmentVariables = jsonencode(module.carshub_codebuild_frontend.environment_variables)
          }
        }
      ]
    },
    {
      name = "Approval"
      actions = [{
        name             = "ManualApproval"
        category         = "Approval"
        owner            = "AWS"
        provider         = "Manual"
        version          = "1"
        input_artifacts  = []
        output_artifacts = []
        configuration = {
          NotificationArn = "${module.carshub_alarm_notifications.topic_arn}"
          CustomData      = "Approve production deployment"
        }
      }]
    },
    {
      name = "Deploy"
      actions = [
        {
          name             = "DeployToECS"
          category         = "Deploy"
          owner            = "AWS"
          provider         = "ECS"
          version          = "1"
          action_type_id   = "DeployToECS"
          run_order        = 1
          input_artifacts  = ["build_output"]
          output_artifacts = []
          configuration = {
            ClusterName = "${aws_ecs_cluster.carshub_cluster.name}"
            ServiceName = "${module.carshub_backend_ecs.name}"
            FileName    = "imagedefinitions.json"
          }
        }
      ]
    }
  ]
}