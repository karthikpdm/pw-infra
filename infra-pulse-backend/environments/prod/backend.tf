terraform {
  backend "s3" {
    bucket         = "pw-s3-terraform-backend"
    key            = "prod/infra-pulse-backend/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "pw_dynamo_terraform_statelock"
    encrypt        = true
  }
}