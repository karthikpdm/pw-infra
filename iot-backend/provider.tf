provider "aws" {
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  }
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.64.0"
    }
  }
}

