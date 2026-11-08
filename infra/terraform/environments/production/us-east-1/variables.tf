variable "region" {
  type = string
}

variable "db_name" {
  type = string
}

variable "env" {
  type = string
}

variable "vehicle-images-code-version" {
  type = string
}

variable "public_subnets" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}

variable "project" {
  type    = string
  default = "CarsHub"
}

variable "database_subnets" {
  type        = list(string)
  description = "Database Subnet CIDR values"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
}

variable "domain_name" {
  type        = string
  description = "Domain name for ACM Certificate and Route53"
  default     = "carshub.com"
}

variable "certificate_arn" {
  type        = string
  description = "Existing ACM Certificate ARN. If empty, a managed ACM certificate is created."
  default     = ""
}