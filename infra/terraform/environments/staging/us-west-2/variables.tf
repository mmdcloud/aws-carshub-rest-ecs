variable "region" {
  type    = string
  default = "us-west-2"
}

variable "db_name" {
  type    = string
  default = "carshub"
}

variable "env" {
  type    = string
  default = "staging"
}

variable "vehicle-images-code-version" {
  type    = string
  default = "1"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
