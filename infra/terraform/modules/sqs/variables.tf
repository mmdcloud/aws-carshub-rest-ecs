variable "queue_name" {}
variable "delay_seconds" {}
variable "max_message_size" {}
variable "message_retention_seconds" {}
variable "visibility_timeout_seconds" {}
variable "receive_wait_time_seconds" {}
variable "maxReceiveCount" {
  default = 3
}
variable "dead_letter_target_arn" {
  type    = string
  default = null
}
variable "policy" {}
variable "tags" {
  type    = map(string)
  default = {}  
}