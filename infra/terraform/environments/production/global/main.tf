data "aws_lb" "carshub_frontend_lb_us_east_1" {
  name = "frontend-lb-prod-us-east-1"
}

data "aws_lb" "carshub_backend_lb_us_east_1" {
  name = "backend-lb-prod-us-east-1"
}

data "aws_lb" "carshub_frontend_lb_us_west_2" {
  name = "frontend-lb-prod-us-west-2"
}

data "aws_lb" "carshub_backend_lb_us_west_2" {
  name = "backend-lb-prod-us-west-2"
}

# Global accelerator configuration for production environment
module "global_accelerator" {
  source          = "../../../modules/global-accelerator"
  name            = "carshub-ga-${var.env}"
  ip_address_type = "IPV4"
  enabled         = true
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"
  port_ranges = [
    {
      from_port = 80
      to_port   = 80
    },
    {
      from_port = 443
      to_port   = 443
    }
  ]

  endpoint_groups = [
    {
      endpoint_group_region = "us-east-1"
      endpoint_configuration = [
        {
          client_ip_preservation_enabled = true
          endpoint_id                    = var.us_east_1_lb_arn
          weight                         = 128
        }
      ]
    },
    {
      endpoint_group_region = "us-west-2"
      endpoint_configuration = [
        {
          client_ip_preservation_enabled = true
          endpoint_id                    = var.us_west_2_lb_arn
          weight                         = 128
        }
      ]
    }
  ]
}

resource "aws_route53_health_check" "primary" {
  fqdn              = aws_lb.primary.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
}

resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.example.com"
  type    = "A"
  alias {
    name                   = aws_lb.primary.dns_name
    zone_id                = aws_lb.primary.zone_id
    evaluate_target_health = true
  }
  set_identifier = "primary"
  failover_routing_policy {
    type = "PRIMARY"
  }
  health_check_id = aws_route53_health_check.primary.id
}

resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.example.com"
  type    = "A"
  alias {
    name                   = aws_lb.secondary.dns_name
    zone_id                = aws_lb.secondary.zone_id
    evaluate_target_health = false
  }
  set_identifier = "secondary"
  failover_routing_policy {
    type = "SECONDARY"
  }
}