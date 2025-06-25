resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-primary-zone"
    }
  )
}

# DNS Security (DNSSEC)
resource "aws_route53_key_signing_key" "signing_key" {
  count = var.enable_dnssec ? 1 : 0

  hosted_zone_id             = aws_route53_zone.hosted_zone.hosted_zone_id
  key_management_service_arn = aws_kms_key.dnssec[0].arn
  name                       = "${var.domain_name}-dnssec-key"
}

resource "aws_route53_hosted_zone_dnssec" "primary" {
  count = var.enable_dnssec ? 1 : 0

  hosted_zone_id = aws_route53_key_signing_key.signing_key[0].hosted_zone_id

  depends_on = [aws_route53_key_signing_key.signing_key]
}

# Health Checks for Failover
resource "aws_route53_health_check" "health_check" {
  for_each = var.health_checks

  ip_address        = each.value.ip_address
  port              = each.value.port
  type              = each.value.type
  resource_path     = each.value.resource_path
  failure_threshold = each.value.failure_threshold
  request_interval  = each.value.request_interval

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${each.key}-health-check"
    }
  )
}

# Primary/Secondary Record Sets with Failover
resource "aws_route53_record" "primary" {
  for_each = var.records

  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl

  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  dynamic "failover_routing_policy" {
    for_each = each.value.failover != null ? [each.value.failover] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  health_check_id = each.value.health_check_id
  set_identifier  = each.value.set_identifier

  dynamic "weighted_routing_policy" {
    for_each = each.value.weight != null ? [each.value.weight] : []
    content {
      weight = weighted_routing_policy.value
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = each.value.geolocation != null ? [each.value.geolocation] : []
    content {
      continent   = geolocation_routing_policy.value.continent
      country     = geolocation_routing_policy.value.country
      subdivision = geolocation_routing_policy.value.subdivision
    }
  }
}