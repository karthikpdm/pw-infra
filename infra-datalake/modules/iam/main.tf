# # Data sources for AWS account and region information
# data "aws_caller_identity" "current" {}
# data "aws_region" "current" {}

# data "aws_secretsmanager_secret" "amcs_secret" {
#   name = var.amcs_secret_name  # This should be passed from your root module
# }


# #################################################################################################

# # IAM role for the Lambda function
# resource "aws_iam_role" "lambda_role" {
#   name = "pw-lambda-${var.env}-all-datasources-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = var.tags
# }

# # IAM policy for the Lambda role
# resource "aws_iam_role_policy" "lambda_policy" {
#   name = "pw-lambda-${var.env}-all-datasources-policy"
#   role = aws_iam_role.lambda_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Resource = "arn:aws:logs:*:*:*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:CreateNetworkInterface",
#           "ec2:DescribeNetworkInterfaces",
#           "ec2:DeleteNetworkInterface"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:ListBucket"
#         ]
#         Resource = [
#            "*"
#           # "arn:aws:s3:::${var.raw_bucket_name}",
#           # "arn:aws:s3:::${var.cleansed_bucket_name}/*"
#           # var.raw_bucket_name,
#           # var.raw_bucket_name/*,
#           # var.cleansed_bucket_name

#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "sns:Publish"
#         ]
#         Resource = [
#           "*"
#           # "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:amcs-s3-failure",
#           # "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:pw-dossier-failure",
#           # "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:pw-platformdata-failure",
#           # "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:amcs-s3-success",
#           # "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:pw-dossier-success",
#           # var.amcs_s3_failure_topic_arn,
#           # var.dossier_failure_topic_arn,
#           # var.dossier_success_topic_arn,
#           # var.platform_data_failure_topic_arn,
#           # var.platform_data_success_topic_arn,
#           # var.amcs_s3_success_topic_arn,
#           # var.cleaning_data_failure_topic_arn,
#           # var.cleaning_data_success_topic_arn


#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "secretsmanager:GetSecretValue"
#         ]
#         Resource = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:pw-amcs-secret*"
#       }
#     ]
#   })
# }

# # Attach AWS managed policy for Lambda VPC access
# resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
# }



# #############################################################################################################


# # IAM Role for Glue job
# resource "aws_iam_role" "glue_role" {
#   name = "glue-job-role"
  
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "glue.amazonaws.com"
#         }
#       }
#     ]
#   })
  
#   tags = var.tags
# }

# # Attach AWS managed policy for Glue service
# resource "aws_iam_role_policy_attachment" "glue_service" {
#   role       = aws_iam_role.glue_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
# }

# # Custom policy for S3 access to read/write data
# resource "aws_iam_policy" "s3_access" {
#   name        = "amcs-glue-s3-access"
#   description = "Policy for AMCS Glue job to access S3 buckets"
  
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:DeleteObject",
#           "s3:ListBucket"
#         ]
#         Resource = [
#           "*"
#           # "arn:aws:s3:::${var.raw_bucket_name}",
#           # "arn:aws:s3:::${var.raw_bucket_name}/*",
#           # "arn:aws:s3:::${var.aws_glue_bucket_name}",
#           # "arn:aws:s3:::${var.aws_glue_bucket_name}/*"
#         ]
#       }
#     ]
#   })
# }

# # Attach S3 access policy
# resource "aws_iam_role_policy_attachment" "s3_access" {
#   role       = aws_iam_role.glue_role.name
#   policy_arn = aws_iam_policy.s3_access.arn
# }

# # Policy for CloudWatch Logs access
# resource "aws_iam_policy" "cloudwatch_logs" {
#   name        = "amcs-glue-cloudwatch-logs"
#   description = "Policy for AMCS Glue job to write to CloudWatch Logs"
  
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Resource = [
#           "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/jobs/*"
#         ]
#       }
#     ]
#   })
# }

# # Attach CloudWatch Logs policy
# resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
#   role       = aws_iam_role.glue_role.name
#   policy_arn = aws_iam_policy.cloudwatch_logs.arn
# }

# # Policy for KMS access for encryption/decryption
# resource "aws_iam_policy" "kms_access" {
#   name        = "amcs-glue-kms-access"
#   description = "Policy for AMCS Glue job to use KMS keys"
  
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "kms:Decrypt",
#           "kms:Encrypt",
#           "kms:GenerateDataKey"
#         ]
#         Resource = [
#           var.s3_kms_key_arn
#         ]
#       }
#     ]
#   })
# }

# # Attach KMS access policy
# resource "aws_iam_role_policy_attachment" "kms_access" {
#   role       = aws_iam_role.glue_role.name
#   policy_arn = aws_iam_policy.kms_access.arn
# }

# # Policy for Secrets Manager access
# resource "aws_iam_policy" "secrets_access" {
#   name        = "amcs-glue-secrets-access"
#   description = "Policy for AMCS Glue job to access secrets"
  
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "secretsmanager:GetSecretValue"
#         ]
#         Resource = [
#           data.aws_secretsmanager_secret.amcs_secret.arn
#         ]
#       }
#     ]
#   })
# }

# # Attach Secrets Manager access policy
# resource "aws_iam_role_policy_attachment" "secrets_access" {
#   role       = aws_iam_role.glue_role.name
#   policy_arn = aws_iam_policy.secrets_access.arn
# }

# # Policy for SNS publication
# resource "aws_iam_policy" "sns_publish" {
#   name        = "amcs-glue-sns-publish"
#   description = "Policy for AMCS Glue job to publish to SNS"
  
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "sns:Publish"
#         ]
#         Resource = [
#           "arn:aws:sns:us-east-1:${data.aws_caller_identity.current.account_id}:*"
#         ]
#       }
#     ]
#   })
# }

# # Attach SNS publish policy
# resource "aws_iam_role_policy_attachment" "sns_publish" {
#   role       = aws_iam_role.glue_role.name
#   policy_arn = aws_iam_policy.sns_publish.arn
# }


# ######################################################################################################################


# # IAM role for the Step Function

# resource "aws_iam_role" "step_function_role" {
#   name = "pw-step-function-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "states.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = var.tags
# }

# # IAM policy for the Step Function
# resource "aws_iam_policy" "step_function_policy" {
#   name        = "pw-step-function-policy"
#   description = "Policy for AMCS delta audit Step Function"
  
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "lambda:InvokeFunction"
#         ]
#         Resource = [
#           "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.audit_lambda_name}",
#           "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.amcs_s3_lambda_sns_name}",
#           "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.amcs_schema_counts_lambda_name}",
#           "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.dossier_audit_lambda_name}",
#           "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.cleansed_schema_counts_lambda_name}"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "glue:StartJobRun",
#           "glue:GetJobRun",
#           "glue:GetJobRuns",
#           "glue:BatchStopJobRun"
#         ]
#         Resource = [
#           "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:job/${var.glue_amcs_incremental_job_name}"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "sns:Publish"
#         ]
#         Resource = [
#           "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.amcs_s3_success_topic_arn}",
#           "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.amcs_s3_failure_topic_arn}",
#           "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.platform_data_failure_topic_arn}",
#           "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.cleaning_data_success_topic_arn}",
#           "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.cleaning_data_failure_topic_arn}",
#           "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.platform_data_success_topic_arn}"
          
#         ]
#       }
#     ]
#   })
# }

# # Attach the policy to the role
# resource "aws_iam_role_policy_attachment" "step_function_policy_attachment" {
#   role       = aws_iam_role.step_function_role.name
#   policy_arn = aws_iam_policy.step_function_policy.arn
# }








# Data sources for AWS account and region information
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create a basic IAM role for Lambda with minimal permissions
resource "aws_iam_role" "lambda_role" {
  name = "pw-${var.env}-lambda-role"

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

# Attach basic Lambda execution role policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach AWS managed policy for Lambda VPC access
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# IAM Role for Glue job
resource "aws_iam_role" "glue_role" {
  name = "pw-${var.env}-glue-role"
  
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

# Attach AWS managed policy for Glue service
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Basic KMS access policy for Glue
resource "aws_iam_policy" "kms_access" {
  name        = "basic-glue-kms-access"
  description = "Basic policy for Glue job to use KMS keys"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [
          var.datalake_kms_key_arn == "" ? "*" : var.datalake_kms_key_arn
        ]
      }
    ]
  })
}

# Attach KMS access policy
resource "aws_iam_role_policy_attachment" "kms_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.kms_access.arn
}

# IAM role for the Step Function
resource "aws_iam_role" "step_function_role" {
  name = "pw-${var.env}-stepfunction-role"

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

# Basic IAM policy for the Step Function
resource "aws_iam_policy" "step_function_policy" {
  name        = "pw-step-function-basic-policy"
  description = "Basic policy for Step Function"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJobRuns",
          "glue:BatchStopJobRun"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the basic policy to the role
resource "aws_iam_role_policy_attachment" "step_function_policy_attachment" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_policy.arn
}