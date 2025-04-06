# App Auto Scaling Target
resource "aws_appautoscaling_target" "target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = var.target_resource_id
  scalable_dimension = var.target_scalable_dimension
  service_namespace  = var.target_service_namespace
}

# CPU Scale Up Policy
resource "aws_appautoscaling_policy" "policy" {
  count = length(var.policies)
  name               = var.policies[count.index].name
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.target.resource_id
  scalable_dimension = aws_appautoscaling_target.target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 20
      scaling_adjustment          = 1
    }

    step_adjustment {
      metric_interval_lower_bound = 20
      scaling_adjustment          = 2
    }
  }
}