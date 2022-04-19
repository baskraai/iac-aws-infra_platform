terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "eu-central-1"
  access_key = var.aws_key
  secret_key = var.aws_secret
  assume_role {
    role_arn     = var.aws_role
  }
}

provider "tfe" {
  token = var.tfc_token
}
