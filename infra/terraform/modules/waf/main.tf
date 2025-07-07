# -----------------------------------------------------------------------------------------
# WAF Configuration for Application Security
# -----------------------------------------------------------------------------------------

resource "aws_wafv2_web_acl" "carshub_waf" {
  name  = "carshub-waf-${var.env}"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                 = "CommonRuleSetMetric"
      sampled_requests_enabled    = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

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
      metric_name                 = "KnownBadInputsRuleSetMetric"
      sampled_requests_enabled    = true
    }
  }

  rule {
    name     = "RateLimitRule"
    priority = 3

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                 = "RateLimitRule"
      sampled_requests_enabled    = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                 = "carshubWAF"
    sampled_requests_enabled    = true
  }

  tags = {
    Name        = "carshub-waf-${var.env}"
    Environment = var.env
  }
}

# Associate WAF with Load Balancer
resource "aws_wafv2_web_acl_association" "carshub_frontend_waf_association" {
  resource_arn = module.carshub_frontend_lb.arn
  web_acl_arn  = aws_wafv2_web_acl.carshub_waf.arn
}

resource "aws_wafv2_web_acl_association" "carshub_backend_waf_association" {
  resource_arn = module.carshub_backend_lb.arn
  web_acl_arn  = aws_wafv2_web_acl.carshub_waf.arn
}