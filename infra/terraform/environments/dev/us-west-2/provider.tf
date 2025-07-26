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
    bucket         = "carshubuswest2tfstate"
    key            = "dev/us-west-2/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "carshub-terraform-state-dev-uswest2"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
  # allowed_account_ids = ["585230455590"]
}

provider "vault" {}
