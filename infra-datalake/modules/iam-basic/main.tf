# modules/iam-basic/main.tf
# This is a minimal IAM module that creates only the roles without any policies that depend on KMS

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create a basic IAM role for Lambda with minimal permissions
resource "aws_iam_role" "lambda_role" {
  name = "pw-lambda-${var.env}-all-datasources-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Role for Glue job - This is what KMS needs
resource "aws_iam_role" "glue_role" {
  name = "glue-job-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.tags
}

# IAM role for the Step Function
resource "aws_iam_role" "step_function_role" {
  name = "pw-step-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}