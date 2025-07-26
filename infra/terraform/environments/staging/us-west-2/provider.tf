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
    key            = "staging/us-west-2/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "carshub-terraform-state-staging-uswest2"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

provider "vault" {}
