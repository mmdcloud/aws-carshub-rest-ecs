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