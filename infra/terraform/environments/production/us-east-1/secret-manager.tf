# -----------------------------------------------------------------------------------------
# Secrets Manager
# -----------------------------------------------------------------------------------------
module "carshub_db_credentials" {
  source                  = "../../../modules/secrets-manager"
  name                    = "carshub-rds-secrets-${var.env}-${var.region}"
  description             = "Secret for storing RDS credentials"
  recovery_window_in_days = 0
  secret_string = jsonencode({
    username = tostring(data.vault_generic_secret.rds.data["username"])
    password = tostring(data.vault_generic_secret.rds.data["password"])
  })
  replica = [
    {
      region     = "us-west-2"
      kms_key_id = "alias/aws/secretsmanager"
    }
  ]
  tags = {
    Name        = "carshub-rds-secrets-${var.env}-${var.region}"
    Environment = var.env
    Project     = var.project
  }
}