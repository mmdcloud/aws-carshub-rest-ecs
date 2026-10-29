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
            }
          ]
          secrets = [
            {
              name      = "UN"
              valueFrom = "${module.carshub_db_credentials.arn}:username::"
            },
            {
              name      = "CREDS"
              valueFrom = "${module.carshub_db_credentials.arn}:password::"
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
      predictive_scaling_policy_configuration      = null
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