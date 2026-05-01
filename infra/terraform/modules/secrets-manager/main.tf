# Secret Manager resource for storing RDS credentials
resource "aws_secretsmanager_secret" "secret" {
  name                    = var.name
  recovery_window_in_days = var.recovery_window_in_days
  description             = var.description
  dynamic "replica" {
    for_each = var.replica
    content {
      region     = replica.value.region
      kms_key_id = replica.value.kms_key_id
    }
  }  
  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.secret_string
}