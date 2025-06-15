variable "name" {}
variable "rules" {
    type = list(object({
        rule_name = string
        target_vault_name = string
        schedule = string
        delete_after = number
    }))
    default = []
}
variable "backup_selections" {
    type = list(object({
        name = string
        iam_role_arn = string
        resources = list(string)
    }))
    default = []
}