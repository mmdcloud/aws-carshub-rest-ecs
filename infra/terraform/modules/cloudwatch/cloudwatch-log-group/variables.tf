variable "log_group_name" {}
variable "retention_in_days" {}
variable "skip_destroy" {}
variable "tags" {
  type = map(string)
  default = {}
}