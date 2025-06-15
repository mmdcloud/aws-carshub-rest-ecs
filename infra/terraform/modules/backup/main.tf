# # Add automated backups for critical resources
# resource "aws_backup_plan" "carshub_backup" {
#   name = "carshub-backup-plan-${var.env}"

#   rule {
#     rule_name         = "daily-backups"
#     target_vault_name = aws_backup_vault.carshub_vault.name
#     schedule          = "cron(0 5 * * ? *)" # Daily at 5AM

#     lifecycle {
#       delete_after = 35 # Matches RDS backup retention
#     }
#   }
# }

# resource "aws_backup_selection" "carshub_resources" {
#   plan_id = aws_backup_plan.carshub_backup.id
#   name    = "carshub-resources-${var.env}"

#   resources = [
#     module.carshub_db.arn,
#     module.carshub_media_bucket.arn,
#     # Add other critical resources
#   ]
# }
# Add automated backups for critical resources
resource "aws_backup_plan" "backup_plan" {
  name = var.name
  dynamic "rule" {
    for_each = var.rules
    content {
      rule_name         = rule.value.rule_name
      target_vault_name = rule.value.target_vault_name
      schedule          = rule.value.schedule
      lifecycle {
        delete_after = rule.value.delete_after
      }
    }
  }
}

resource "aws_backup_selection" "backup_resources" {
  count        = length(var.backup_selections)
  plan_id      = aws_backup_plan.backup_plan.id
  name         = var.backup_selections[count.index].name
  iam_role_arn = var.backup_selections[count.index].iam_role_arn
  resources    = var.backup_selections[count.index].resources
}
