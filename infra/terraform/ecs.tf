# ECS Cluster
resource "aws_ecs_cluster" "carshub-cluster" {
  name = "carshub-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }

}

resource "aws_cloudwatch_log_group" "carshub-log-group" {
  name = "carshub-log-group"

  tags = {
    Name = "carshub-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "carshub-log-stream" {
  name           = "carshub-log-stream"
  log_group_name = aws_cloudwatch_log_group.carshub-log-group.name
}

data "aws_iam_policy_document" "s3_put_object_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "s3_put_policy" {
  name        = "s3_put_policy"
  description = "Policy for allowing PutObject action"
  policy      = data.aws_iam_policy_document.s3_put_object_policy_document.json
}

# ECR-ECS IAM Role
resource "aws_iam_role" "ecs-task-execution-role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
    EOF
}

# ECR-ECS policy attachment 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "s3-put-object-role-policy-attachment" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = aws_iam_policy.s3_put_policy.arn
}

# ECS Task Definition
resource "aws_ecs_task_definition" "carshub-task-definition" {
  family                   = "carshub-task-definition"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn            = aws_iam_role.ecs-task-execution-role.arn
  network_mode             = "awsvpc"
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  container_definitions = jsonencode(
    [
      {
        "name" : "carshub",
        "image" : "${aws_ecr_repository.carshub.repository_url}:latest",
        "cpu" : 1024,
        "memory" : 2048,
        "essential" : true,
        "portMappings" : [
          {
            "containerPort" : 8080,
            "hostPort" : 8080,
            "name" : "carshub-http-80",
            "appProtocol" : "http",
            "protocol" : "tcp"
          }
        ],
      }
  ])
  tags_all = {
    Name = "carshub-task-definition"
  }
}

resource "aws_ecs_task_definition" "carshub-frontend-task-definition" {
  family                   = "carshub-frontend-task-definition"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn            = aws_iam_role.ecs-task-execution-role.arn
  network_mode             = "awsvpc"
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  container_definitions = jsonencode(
    [
      {
        "name" : "carshub-frontend",
        "image" : "${aws_ecr_repository.carshub-frontend.repository_url}:latest",
        "cpu" : 1024,
        "memory" : 2048,
        "essential" : true,
        "portMappings" : [
          {
            "containerPort" : 3000,
            "hostPort" : 3000,
            "name" : "carshub-frontend-http-3000",
            "appProtocol" : "http",
            "protocol" : "tcp"
          }
        ],
      }
  ])
  tags_all = {
    Name = "carshub-frontend-task-definition"
  }
}

# ECS Service
resource "aws_ecs_service" "carshub-service" {
  name                 = "carshub-service"
  cluster              = aws_ecs_cluster.carshub-cluster.id
  task_definition      = aws_ecs_task_definition.carshub-task-definition.arn
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true
  triggers = {
    redeployment = plantimestamp()
  }
  network_configuration {
    security_groups  = [aws_security_group.security_group.id]
    subnets          = aws_subnet.public_subnets[*].id
    assign_public_ip = true
  }
  deployment_controller {
    type = "ECS"
  }
  load_balancer {
    container_name   = "carshub"
    container_port   = 8080
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
  depends_on = [null_resource.push_to_ecr]
}

resource "aws_ecs_service" "carshub-frontend-service" {
  name                 = "carshub-frontend-service"
  cluster              = aws_ecs_cluster.carshub-cluster.id
  task_definition      = aws_ecs_task_definition.carshub-frontend-task-definition.arn
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true
  triggers = {
    redeployment = plantimestamp()
  }
  network_configuration {
    security_groups  = [aws_security_group.security_group.id]
    subnets          = aws_subnet.public_subnets[*].id
    assign_public_ip = true
  }
  deployment_controller {
    type = "ECS"
  }
  load_balancer {
    container_name   = "carshub-frontend"
    container_port   = 3000
    target_group_arn = aws_lb_target_group.frontend_lb_target_group.arn
  }
  depends_on = [null_resource.push_frontend_to_ecr]
}
