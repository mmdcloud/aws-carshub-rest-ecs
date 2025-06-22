# Global Accelerator Configuration
resource "aws_globalaccelerator_accelerator" "ga" {
  name            = var.name
  ip_address_type = var.ip_address_type
  enabled         = var.enabled
}

resource "aws_globalaccelerator_listener" "ga_listener" {
  accelerator_arn = aws_globalaccelerator_accelerator.ga.id
  client_affinity = var.client_affinity
  protocol        = var.protocol
  dynamic "port_range" {
    for_each = var.port_ranges
    content {
      from_port = each.value.from_port
      to_port   = each.value.to_port
    }
  }
}

resource "aws_globalaccelerator_endpoint_group" "ga_endpoint_group" {
  count                 = length(var.endpoint_groups)
  listener_arn          = aws_globalaccelerator_listener.ga_listener.id
  endpoint_group_region = var.endpoint_groups[count.index].endpoint_group_region
  dynamic "endpoint_configuration" {
    for_each = var.endpoint_groups[count.index].endpoint_configuration
    content {
      client_ip_preservation_enabled = each.value.client_ip_preservation_enabled
      endpoint_id                    = each.value.endpoint_id
      weight                         = each.value.weight
    }
  }
}