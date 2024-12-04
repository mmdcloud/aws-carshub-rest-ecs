# Secret Manager resource for storing RDS credentials
resource "aws_secretsmanager_secret" "rds_creds" {
  name                    = "rds_carshub_credentials"
  recovery_window_in_days = 0
  description             = "This secret stores the credentials for RDS database"
}

resource "aws_secretsmanager_secret_version" "rds_creds_version" {
  secret_id = aws_secretsmanager_secret.rds_creds.id
  secret_string = jsonencode({
    username = tostring(data.vault_generic_secret.rds.data["username"])
    password = tostring(data.vault_generic_secret.rds.data["password"])
  })
}
