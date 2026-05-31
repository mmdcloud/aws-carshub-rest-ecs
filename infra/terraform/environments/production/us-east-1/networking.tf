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