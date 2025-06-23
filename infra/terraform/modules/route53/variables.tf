variable "domain_name" {}
variable "tags" {}
variable "environment" {}
variable "tags" {}
variable "records" {

}
variable "health_checks" {
  type = map(object({
    ip_address        = string
    port              = number
    type              = string
    resource_path     = string
    failure_threshold = number
    request_interval  = number
  }))
  default = {}
}

variable "enable_dnssec" {
  type    = bool
  default = false
}
