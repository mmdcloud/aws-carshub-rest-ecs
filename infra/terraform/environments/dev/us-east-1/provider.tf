terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "carshubuseast1tfstate"
    key            = "dev/us-east-1/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "carshub-terraform-state-dev-useast1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  # allowed_account_ids = ["585230455590"]
}

provider "vault" {}
