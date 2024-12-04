# Using Vault Secrets
data "vault_generic_secret" "rds" {
  path = "secret/rds"
}