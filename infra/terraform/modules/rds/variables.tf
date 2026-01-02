variable "allocated_storage" {}
variable "db_name" {}
variable "engine" {}
variable "identifier"{}
variable "iops"{}
variable "storage_throughput"{}
variable "auto_minor_version_upgrade"{}
variable "iam_database_authentication_enabled"{}
variable "copy_tags_to_snapshot"{}
variable "final_snapshot_identifier"{}
variable "maintenance_window"{}
variable "performance_insights_kms_key_id" {
  type = string
  default = null
}
variable "engine_version" {}
variable "kms_key_id" {
  type = string
  default = null
}
variable "publicly_accessible" {}
variable "multi_az" {}
variable "instance_class" {}
variable "storage_encrypted" {
  type = bool
  default = false
}
variable "username" {}
variable "password" {}
variable "parameter_group_name" {}
variable "parameter_group_family" {}
variable "parameters" {
  type = list(object({
    name  = string
    value = string
  }))
}
variable "skip_final_snapshot" {}
variable "storage_type" {}
variable "subnet_group_name" {}
variable "subnet_group_ids" {}
variable "vpc_security_group_ids" {}
variable "backup_retention_period" {}
variable "backup_window" {}
variable "deletion_protection" {}
variable "max_allocated_storage"{}
variable "performance_insights_enabled"{}
variable "performance_insights_retention_period"{}
variable "monitoring_interval"{}
variable "enabled_cloudwatch_logs_exports" {
  type = list(string)
  default = []
}
variable "monitoring_role_arn" {
  type = string
}
variable "tags" {
  type = map(string)
  default = {}    
}