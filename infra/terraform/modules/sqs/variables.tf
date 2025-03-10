variable "queue_name" {}
variable "delay_seconds" {}
variable "max_message_size" {}
variable "message_retention_seconds" {}
variable "visibility_timeout_seconds" {}
variable "receive_wait_time_seconds" {}
variable "deadLetterTargetArn" {}
variable "delMaxReceiveCount" {}

variable "dlq_name" {}
variable "dlq_message_retention_seconds" {}