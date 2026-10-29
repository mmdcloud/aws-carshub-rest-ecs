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