# -----------------------------------------------------------------------------------------
# WAF Module Variables
# -----------------------------------------------------------------------------------------

variable "name" {
  description = "Base name for all WAF resources (e.g. carshub-dev-ap-southeast-1)"
  type        = string
}

variable "frontend_alb_arn" {
  description = "ARN of the frontend ALB to associate the WAF with"
  type        = string
}

variable "alarm_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications (reuse carshub_alarm_notifications)"
  type        = string
}

variable "account_id" {
  description = "AWS account ID — used for log resource policy"
  type        = string
}

variable "aws_region" {
  description = "AWS region (e.g. ap-southeast-1)"
  type        = string
}

# ---------------------------------------------------
# IP Sets
# ---------------------------------------------------

variable "blocked_ip_list" {
  description = "List of CIDR blocks to explicitly block (e.g. known attackers, threat intel feeds)"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for ip in var.blocked_ip_list : can(cidrnetmask(ip))])
    error_message = "All entries in blocked_ip_list must be valid CIDR blocks (e.g. 203.0.113.0/24)."
  }
}

variable "allowed_ip_list" {
  description = "List of CIDR blocks to trust — exempted from rate limiting (e.g. office IP, CI/CD runners)"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for ip in var.allowed_ip_list : can(cidrnetmask(ip))])
    error_message = "All entries in allowed_ip_list must be valid CIDR blocks (e.g. 203.0.113.5/32)."
  }
}

# ---------------------------------------------------
# Geo Blocking
# ---------------------------------------------------

variable "blocked_countries" {
  description = "List of ISO 3166-1 alpha-2 country codes to block. Leave empty to disable geo-blocking."
  type        = list(string)
  default     = []

  # Example: ["CN", "RU", "KP", "IR"] — block countries not in your target market
  # Full list: https://docs.aws.amazon.com/waf/latest/APIReference/API_GeoMatchStatement.html
}

# ---------------------------------------------------
# Rate Limiting
# ---------------------------------------------------

variable "rate_limit_requests" {
  description = "Max requests per IP per 5-minute window for general traffic"
  type        = number
  default     = 2000

  validation {
    condition     = var.rate_limit_requests >= 100 && var.rate_limit_requests <= 20000000
    error_message = "Rate limit must be between 100 and 20,000,000 per AWS limits."
  }
}

variable "auth_rate_limit_requests" {
  description = "Max requests per IP per 5-minute window on auth endpoints (/login, /register, /api/auth)"
  type        = number
  default     = 100

  validation {
    condition     = var.auth_rate_limit_requests >= 100
    error_message = "Auth rate limit must be at least 100 per AWS limits."
  }
}

# ---------------------------------------------------
# Logging
# ---------------------------------------------------

variable "log_retention_days" {
  description = "How long to retain WAF logs in CloudWatch (days)"
  type        = number
  default     = 90

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "log_retention_days must be a valid CloudWatch retention value."
  }
}

# ---------------------------------------------------
# Alarm Thresholds
# ---------------------------------------------------

variable "alarm_blocked_requests_threshold" {
  description = "Total blocked requests in 5 minutes before alerting (overall WAF)"
  type        = number
  default     = 500
}

variable "alarm_rate_limit_threshold" {
  description = "Rate-limit triggered blocks in 5 minutes before alerting"
  type        = number
  default     = 100
}

variable "alarm_auth_rate_limit_threshold" {
  description = "Auth endpoint rate-limit blocks in 5 minutes before alerting"
  type        = number
  default     = 20
}

# ---------------------------------------------------
# Tags
# ---------------------------------------------------

variable "tags" {
  description = "Tags to apply to all WAF resources"
  type        = map(string)
  default     = {}
}