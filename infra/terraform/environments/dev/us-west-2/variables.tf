variable "region" {
  type    = string
  default = "us-west-2"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "db_name" {
  type    = string
  default = "carshub"
}

variable "project" {
  type    = string
  default = "CarsHub"
}

variable "vehicle-images-code-version" {
  type    = string
  default = "1"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "database_subnets" {
  type        = list(string)
  description = "Database Subnet CIDR values"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}