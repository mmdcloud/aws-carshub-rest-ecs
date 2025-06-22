# Global accelerator configuration for production environment
module "global_accelerator" {
  source          = "../../../modules/global-accelerator"
  name            = "ga"
  ip_address_type = "IPV4"
  enabled         = true
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"
  port_ranges = [
    {
      from_port = 80
      to_port   = 80
    }
  ]
  endpoint_groups = [
    {
      endpoint_group_region = "us-east-1"
      endpoint_configuration = [
        {
          client_ip_preservation_enabled = true
          endpoint_id                    = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-load-balancer/50dc6c495c0c9188"
          weight                         = 128
        }
      ]
    }
  ]
}
