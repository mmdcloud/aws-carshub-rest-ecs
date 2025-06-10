# Add WAF for the ALBs
resource "aws_wafv2_web_acl" "carshub_waf" {
  name        = "carshub-waf-${var.env}"
  scope       = "REGIONAL"
  description = "WAF for CarsHub application"

  default_action {
    allow {}
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "default-action-allow"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
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
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
}

# Attach WAF to ALBs
resource "aws_wafv2_web_acl_association" "frontend" {
  resource_arn = module.carshub_frontend_lb.arn
  web_acl_arn  = aws_wafv2_web_acl.carshub_waf.arn
}