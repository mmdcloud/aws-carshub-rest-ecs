# Common tags for all resources
locals {
  common_tags = {
    Environment  = var.env
    Project      = "carshub"
    ManagedBy    = "terraform"
    Owner        = "platform-team"
    CostCenter   = "engineering"
    BackupPolicy = "daily"
    Compliance   = "required"
  }
}