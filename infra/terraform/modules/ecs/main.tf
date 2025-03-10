# data "aws_iam_policy_document" "s3_put_object_policy_document" {
#   statement {
#     effect    = "Allow"
#     actions   = ["s3:PutObject"]
#     resources = ["*"]
#   }
# }

# resource "aws_iam_policy" "s3_put_policy" {
#   name        = "s3_put_policy"
#   description = "Policy for allowing PutObject action"
#   policy      = data.aws_iam_policy_document.s3_put_object_policy_document.json
# }

# # ECR-ECS IAM Role
# resource "aws_iam_role" "ecs-task-execution-role" {
#   name               = "ecs-task-execution-role"
#   assume_role_policy = <<EOF
#     {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#         "Effect": "Allow",
#         "Principal": {
#             "Service": "ecs-tasks.amazonaws.com"
#         },
#         "Action": "sts:AssumeRole"
#         }
#     ]
#     }
#     EOF
# }

# # ECR-ECS policy attachment 
# resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
#   role       = aws_iam_role.ecs-task-execution-role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# resource "aws_iam_role_policy_attachment" "s3-put-object-role-policy-attachment" {
#   role       = aws_iam_role.ecs-task-execution-role.name
#   policy_arn = aws_iam_policy.s3_put_policy.arn
# }

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}


# ECS Task Definition
resource "aws_ecs_task_definition" "carshub_task_definition" {
  family                   = var.task_definition_family
  requires_compatibilities = var.task_definition_requires_compatibilities
  cpu                      = var.task_definition_cpu
  memory                   = var.task_definition_memory
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = var.task_definition_network_mode  
  runtime_platform {
    cpu_architecture        = var.task_definition_cpu_architecture
    operating_system_family = var.task_definition_operating_system_family
  }
  container_definitions = var.task_definition_container_definitions
  tags_all = {
    Name = var.task_definition_family
  }
}

# ECS Service
resource "aws_ecs_service" "carshub-service" {
  name                 = var.service_name
  cluster              = var.service_cluster
  task_definition      = aws_ecs_task_definition.carshub_task_definition.arn
  launch_type          = var.service_launch_type
  scheduling_strategy  = var.service_scheduling_strategy
  desired_count        = var.service_desired_count
  force_new_deployment = var.service_force_new_deployment
  triggers = {
    redeployment = plantimestamp()
  }
  network_configuration {
    security_groups  = var.security_groups
    subnets          = var.subnets
    assign_public_ip = var.assign_public_ip
  }
  deployment_controller {
    type = var.deployment_controller_type
  }
  dynamic "load_balancer" {
    for_each = var.load_balancer_config
    content {
      container_name   = load_balancer.value["container_name"]
      container_port   = load_balancer.value["container_port"]
      target_group_arn = load_balancer.value["target_group_arn"]
    }
  }
}
