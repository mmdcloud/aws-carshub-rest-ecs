variable "env" {
  type        = string
  description = "Environment name"
  default     = "prod"
}

variable "us_east_1_lb_arn" {
  type        = string
  description = "ARN of the load balancer in us-east-1"
}

variable "us_west_2_lb_arn" {
  type        = string
  description = "ARN of the load balancer in us-west-2"
}