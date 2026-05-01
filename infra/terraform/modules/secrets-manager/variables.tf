variable "name" {}
variable "description" {}
variable "recovery_window_in_days" {}
variable "secret_string" {}
variable "tags" {
  type = map(string)
  default = {}  
}
variable "replica" {
  description = "A set of replica configurations for the secret"
  type = set(object({
    region     = string
    kms_key_id = optional(string)
  }))
  default = []
}