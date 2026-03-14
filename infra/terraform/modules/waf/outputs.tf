# -----------------------------------------------------------------------------------------
# WAF Module Outputs
# -----------------------------------------------------------------------------------------

output "web_acl_arn" {
  description = "ARN of the WAF Web ACL — use this to associate with CloudFront if needed"
  value       = aws_wafv2_web_acl.main.arn
}

output "web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.id
}

output "web_acl_name" {
  description = "Name of the WAF Web ACL — used in CloudWatch metric dimensions"
  value       = aws_wafv2_web_acl.main.name
}

output "web_acl_capacity" {
  description = "WAF capacity units (WCU) consumed — max is 1500 per ACL"
  value       = aws_wafv2_web_acl.main.capacity
}

output "blocked_ips_set_arn" {
  description = "ARN of the blocked IP set — use to add IPs programmatically via Lambda/automation"
  value       = aws_wafv2_ip_set.blocked_ips.arn
}

output "allowed_ips_set_arn" {
  description = "ARN of the allowed IP set"
  value       = aws_wafv2_ip_set.allowed_ips.arn
}

output "log_group_name" {
  description = "CloudWatch log group name for WAF logs"
  value       = aws_cloudwatch_log_group.waf_log_group.name
}

output "log_group_arn" {
  description = "CloudWatch log group ARN for WAF logs"
  value       = aws_cloudwatch_log_group.waf_log_group.arn
}