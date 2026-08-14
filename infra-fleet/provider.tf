terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.64.0"
    }
    #  awscc = {
    #   source  = "hashicorp/awscc"
    #   version = "~> 1.0"
    # }
  }
}

provider "aws" {
  ##alias  = "App-Dev"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  }
}

# provider "awscc" {
#   region = var.region

#   assume_role {
#     role_arn = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
#   }
# }



