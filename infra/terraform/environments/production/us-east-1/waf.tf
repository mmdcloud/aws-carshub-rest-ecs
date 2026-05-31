# -----------------------------------------------------------------------------------------
# WAF Configuration
# -----------------------------------------------------------------------------------------
module "carshub_waf" {
  source = "../../../modules/waf"

  # Naming — matches your existing convention
  name = "carshub-waf-${var.env}-${var.region}"

  # Attach WAF to the public-facing Frontend ALB
  # Replace with your actual frontend ALB ARN output
  frontend_alb_arn = module.carshub_frontend_lb.arn

  # Reuse your existing SNS alarm topic — no new infra needed
  alarm_topic_arn = module.carshub_alarm_notifications.topic_arn

  # Account + region for log resource policy
  account_id = data.aws_caller_identity.current.account_id
  aws_region = var.region

  # ---------------------------------------------------
  # IP Management
  # ---------------------------------------------------

  # IPs to always block — add known attackers, threat intel here
  blocked_ip_list = [
    # "203.0.113.0/24",  # Example: known scanner range
  ]

  # IPs that bypass rate limiting — office, CI/CD, trusted partners
  allowed_ip_list = [
    # "YOUR_OFFICE_IP/32",
    # "YOUR_CICD_RUNNER_IP/32",
  ]

  # ---------------------------------------------------
  # Geo Blocking
  # ---------------------------------------------------

  # Block countries not in your target market
  # Remove or leave empty [] if you serve global traffic
  blocked_countries = [
    # "KP",  # North Korea
    # "IR",  # Iran
    # "CU",  # Cuba
    # "SY",  # Syria
  ]

  # ---------------------------------------------------
  # Rate Limiting
  # ---------------------------------------------------

  # General rate limit per IP per 5-minute window
  # 2000 = ~6-7 requests/second — comfortable for real users, blocks bots
  rate_limit_requests = 2000

  # Auth endpoints get a much tighter limit
  # 100 = ~1 login attempt every 3 seconds per IP
  auth_rate_limit_requests = 100

  # ---------------------------------------------------
  # Logging
  # ---------------------------------------------------

  # How long to keep WAF logs in CloudWatch
  log_retention_days = 90

  # ---------------------------------------------------
  # Alarm Thresholds — tune after observing normal traffic
  # ---------------------------------------------------

  alarm_blocked_requests_threshold = 500
  alarm_rate_limit_threshold       = 100
  alarm_auth_rate_limit_threshold  = 20

  tags = {
    Name        = "carshub-waf-${var.env}-${var.region}"
    Environment = var.env
    Project     = var.project
  }
}