# -----------------------------------------------------------------------------------------
# AWS WAF v2 - Production Web Application Firewall
# Protects: Frontend ALB (public-facing)
# -----------------------------------------------------------------------------------------

# ---------------------------------------------------
# CloudWatch Log Group for WAF Logs
# NOTE: WAF log group name MUST start with "aws-waf-logs-"
# ---------------------------------------------------
resource "aws_cloudwatch_log_group" "waf_log_group" {
  name              = "aws-waf-logs-${var.name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# ---------------------------------------------------
# IP Sets
# ---------------------------------------------------

# Blocklist - manually blocked IPs (threat intel, abusive actors)
resource "aws_wafv2_ip_set" "blocked_ips" {
  name               = "${var.name}-blocked-ips"
  description        = "Manually blocked IP addresses"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.blocked_ip_list

  tags = var.tags
}

# Allowlist - trusted IPs that bypass rate limiting (office, CI/CD, partners)
resource "aws_wafv2_ip_set" "allowed_ips" {
  name               = "${var.name}-allowed-ips"
  description        = "Trusted IPs that bypass rate limiting"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.allowed_ip_list

  tags = var.tags
}

# ---------------------------------------------------
# WAF Web ACL
# ---------------------------------------------------
resource "aws_wafv2_web_acl" "main" {
  name        = "${var.name}-web-acl"
  description = "Production WAF for ${var.name} - protects frontend ALB"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # -----------------------------------------------
  # RULE 1 — Block manually listed IPs (Priority 1)
  # Highest priority — explicit blocklist wins first
  # -----------------------------------------------
  rule {
    name     = "BlocklistedIPs"
    priority = 1

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blocked_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-blocklisted-ips"
      sampled_requests_enabled   = true
    }
  }

  # -----------------------------------------------
  # RULE 2 — Allow trusted IPs, skip rate limiting (Priority 2)
  # -----------------------------------------------
  rule {
    name     = "AllowlistedIPs"
    priority = 2

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allowed_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-allowlisted-ips"
      sampled_requests_enabled   = true
    }
  }

  # -----------------------------------------------
  # RULE 3 — AWS IP Reputation List (Priority 3)
  # Blocks known malicious IPs: botnets, scanners, TOR exit nodes
  # -----------------------------------------------
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-ip-reputation"
      sampled_requests_enabled   = true
    }
  }

  # -----------------------------------------------
  # RULE 4 — Anonymous IP List (Priority 4)
  # Blocks VPNs, proxies, Tor — reduces fraudulent traffic
  # -----------------------------------------------
  rule {
    name     = "AWSManagedRulesAnonymousIpList"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"

        # Uncomment to COUNT instead of block during initial rollout
        # rule_action_override {
        #   name = "AnonymousIPList"
        #   action_to_use { count {} }
        # }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-anonymous-ip"
      sampled_requests_enabled   = true
    }
  }

  # -----------------------------------------------
  # RULE 5 — Core Rule Set (Priority 5)
  # OWASP Top 10 protection: XSS, LFI, RFI, RCE, SSRF, etc.
  # -----------------------------------------------
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 5

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        # SizeRestrictions_BODY can cause false positives on file uploads
        # Exclude it if your app accepts large file uploads via ALB directly
        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            count {}
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-crs"
      sampled_requests_enabled   = true
    }
  }

  # -----------------------------------------------
  # RULE 6 — Known Bad Inputs (Priority 6)
  # Blocks Log4SHELL, SSRF, known CVEs
  # -----------------------------------------------
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 6

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  # -----------------------------------------------
  # RULE 7 — SQL Injection (Priority 7)
  # Dedicated SQLi protection (CRS covers some, this goes deeper)
  # -----------------------------------------------
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 7

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-sqli"
      sampled_requests_enabled   = true
    }
  }

  # -----------------------------------------------
  # RULE 8 — Linux OS Rule Set (Priority 8)
  # Protects Linux-based ECS containers from OS-level exploits
  # -----------------------------------------------
  rule {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 8

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-linux-ruleset"
      sampled_requests_enabled   = true
    }
  }

  # -----------------------------------------------
  # RULE 9 — Geo Blocking (Priority 9)
  # Block traffic from countries not relevant to your business
  # Leave var.blocked_countries empty to skip this rule
  # -----------------------------------------------
  dynamic "rule" {
    for_each = length(var.blocked_countries) > 0 ? [1] : []

    content {
      name     = "GeoBlockRule"
      priority = 9

      action {
        block {}
      }

      statement {
        geo_match_statement {
          country_codes = var.blocked_countries
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-geo-block"
        sampled_requests_enabled   = true
      }
    }
  }

  # -----------------------------------------------
  # RULE 10 — Rate Limiting (Priority 10)
  # Per-IP rate limiting — protects against brute force & scraping
  # -----------------------------------------------
  rule {
    name     = "RateLimitPerIP"
    priority = 10

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit_requests      # requests per 5-minute window
        aggregate_key_type = "IP"

        # Exempt allowlisted IPs from rate limiting
        scope_down_statement {
          not_statement {
            statement {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.allowed_ips.arn
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  # -----------------------------------------------
  # RULE 11 — Strict Rate Limiting on Auth Endpoints (Priority 11)
  # Tighter throttle on /login, /register, /forgot-password, /api/auth
  # Prevents credential stuffing and brute force on auth
  # -----------------------------------------------
  rule {
    name     = "RateLimitAuthEndpoints"
    priority = 11

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.auth_rate_limit_requests  # much stricter limit
        aggregate_key_type = "IP"

        scope_down_statement {
          or_statement {
                        
            statement {
              byte_match_statement {
                search_string         = "/login"
                positional_constraint = "STARTS_WITH"
                field_to_match {
                  uri_path {}
                }
                text_transformation {
                  priority = 0
                  type     = "LOWERCASE"
                }
              }
            }

            statement {
              byte_match_statement {
                search_string         = "/register"
                positional_constraint = "STARTS_WITH"
                field_to_match {
                  uri_path {}
                }
                text_transformation {
                  priority = 0
                  type     = "LOWERCASE"
                }
              }
            }

            statement {
              byte_match_statement {
                search_string         = "/api/auth"
                positional_constraint = "STARTS_WITH"
                field_to_match {
                  uri_path {}
                }
                text_transformation {
                  priority = 0
                  type     = "LOWERCASE"
                }
              }
            }

            statement {
              byte_match_statement {
                search_string         = "/forgot-password"
                positional_constraint = "STARTS_WITH"
                field_to_match {
                  uri_path {}
                }
                text_transformation {
                  priority = 0
                  type     = "LOWERCASE"
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-auth-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  # -----------------------------------------------
  # Global visibility config (for default_action allow)
  # -----------------------------------------------
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-web-acl"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

# ---------------------------------------------------
# Associate WAF with Frontend ALB
# ---------------------------------------------------
resource "aws_wafv2_web_acl_association" "frontend_alb" {
  resource_arn = var.frontend_alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# ---------------------------------------------------
# WAF Logging Configuration → CloudWatch
# ---------------------------------------------------
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_log_group.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn

  # Redact sensitive fields from WAF logs
  redacted_fields {
    single_header {
      name = "authorization"
    }
  }

  redacted_fields {
    single_header {
      name = "cookie"
    }
  }

  # Only log blocked/counted requests (reduces log volume & cost)
  logging_filter {
    default_behavior = "DROP"

    filter {
      behavior = "KEEP"

      condition {
        action_condition {
          action = "BLOCK"
        }
      }

      requirement = "MEETS_ANY"
    }

    filter {
      behavior = "KEEP"

      condition {
        action_condition {
          action = "COUNT"
        }
      }

      requirement = "MEETS_ANY"
    }
  }
}

# ---------------------------------------------------
# Resource Policy — Allow WAF to write to CloudWatch
# ---------------------------------------------------
resource "aws_cloudwatch_log_resource_policy" "waf_logging_policy" {
  policy_name = "${var.name}-waf-logging-policy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.waf_log_group.arn}:*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:logs:${var.aws_region}:${var.account_id}:*"
          }
        }
      }
    ]
  })
}

# ---------------------------------------------------
# CloudWatch Alarms — WAF Metrics
# Follows exact same pattern as your existing alarms
# ---------------------------------------------------

# High Block Rate — sudden spike in blocked requests
module "waf_high_block_rate" {
  source              = "../cloudwatch/cloudwatch-alarm"
  alarm_name          = "${var.name}-waf-high-block-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.alarm_blocked_requests_threshold
  alarm_description   = "WAF is blocking an unusually high number of requests — possible attack in progress"
  alarm_actions       = [var.alarm_topic_arn]
  ok_actions          = [var.alarm_topic_arn]

  dimensions = {
    WebACL = aws_wafv2_web_acl.main.name
    Region = var.aws_region
    Rule   = "ALL"
  }
}

# Rate Limit Triggered — brute force or scraping detected
module "waf_rate_limit_triggered" {
  source              = "../cloudwatch/cloudwatch-alarm"
  alarm_name          = "${var.name}-waf-rate-limit-triggered"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.alarm_rate_limit_threshold
  alarm_description   = "WAF rate limiting is being triggered — possible brute force or scraping"
  alarm_actions       = [var.alarm_topic_arn]
  ok_actions          = [var.alarm_topic_arn]

  dimensions = {
    WebACL = aws_wafv2_web_acl.main.name
    Region = var.aws_region
    Rule   = "RateLimitPerIP"
  }
}

# Auth Endpoint Abuse — credential stuffing
module "waf_auth_rate_limit_triggered" {
  source              = "../cloudwatch/cloudwatch-alarm"
  alarm_name          = "${var.name}-waf-auth-rate-limit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.alarm_auth_rate_limit_threshold
  alarm_description   = "WAF is blocking repeated auth endpoint requests — possible credential stuffing"
  alarm_actions       = [var.alarm_topic_arn]
  ok_actions          = [var.alarm_topic_arn]

  dimensions = {
    WebACL = aws_wafv2_web_acl.main.name
    Region = var.aws_region
    Rule   = "RateLimitAuthEndpoints"
  }
}

# SQLi Detected
module "waf_sqli_detected" {
  source              = "../cloudwatch/cloudwatch-alarm"
  alarm_name          = "${var.name}-waf-sqli-detected"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "WAF is detecting SQL injection attempts"
  alarm_actions       = [var.alarm_topic_arn]
  ok_actions          = [var.alarm_topic_arn]

  dimensions = {
    WebACL = aws_wafv2_web_acl.main.name
    Region = var.aws_region
    Rule   = "AWSManagedRulesSQLiRuleSet"
  }
}