variable "name" {}
variable "ip_address_type" {}
variable "enabled" {}
variable "client_affinity" {}
variable "protocol" {}
variable "port_ranges" {
  type = list(object({
    from_port = number
    to_port   = number
  }))
}
variable "endpoint_groups" {
  type = list(object({
    endpoint_group_region = string
    endpoint_configuration = list(object({
      client_ip_preservation_enabled = bool
      endpoint_id                    = string
      weight                         = number
    }))
  }))
}
