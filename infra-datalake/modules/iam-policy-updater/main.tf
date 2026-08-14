# Data sources for AWS account and region information
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Lookup the Secret for AMCS
data "aws_secretsmanager_secret" "amcs_secret" {
  name = var.amcs_secret_name
}

# Update Lambda IAM policy with specific permissions
resource "aws_iam_role_policy" "lambda_policy" {
  name = "pw-lambda-${var.env}-all-datasources-policy"
  role = var.lambda_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.raw_bucket_name}",
          "arn:aws:s3:::${var.raw_bucket_name}/*",
          "arn:aws:s3:::${var.cleansed_bucket_name}",
          "arn:aws:s3:::${var.cleansed_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [
          var.failure-notification-topic-arn,
          var.success-notification-topic-arn
          # var.platform_data_failure_topic_arn,
          # var.cleaning_data_success_topic_arn,
          # var.cleaning_data_failure_topic_arn,
          # var.platform_data_success_topic_arn,
          # var.dossier_success_topic_arn,
          # var.dossier_failure_topic_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:pw-amcs-secret*"
      }
    ]
  })
}

# Update Glue S3 access policy
resource "aws_iam_policy" "glue_s3_access" {
  name        = "amcs-glue-s3-access-specific"
  description = "Policy for AMCS Glue job to access specific S3 buckets"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.raw_bucket_name}",
          "arn:aws:s3:::${var.raw_bucket_name}/*",
          # "arn:aws:s3:::${var.aws_glue_bucket_name}",
          # "arn:aws:s3:::${var.aws_glue_bucket_name}/*",
          "arn:aws:s3:::${var.cleansed_bucket_name}",
          "arn:aws:s3:::${var.cleansed_bucket_name}/*",
          "arn:aws:s3:::${var.curated_bucket_name}",
          "arn:aws:s3:::${var.curated_bucket_name}/*",
          "arn:aws:s3:::${var.operational_bucket_name}",
          "arn:aws:s3:::${var.operational_bucket_name}/*",
          
        ]
      }
    ]
  })
}

# Attach updated S3 access policy
resource "aws_iam_role_policy_attachment" "glue_s3_access" {
  role       = var.glue_role_name
  policy_arn = aws_iam_policy.glue_s3_access.arn
}

# Update Secrets Manager access policy
resource "aws_iam_policy" "glue_secrets_access" {
  name        = "amcs-glue-secrets-access-specific"
  description = "Policy for AMCS Glue job to access specific secrets"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          data.aws_secretsmanager_secret.amcs_secret.arn
        ]
      }
    ]
  })
}

# Attach Secrets Manager access policy
resource "aws_iam_role_policy_attachment" "glue_secrets_access" {
  role       = var.glue_role_name
  policy_arn = aws_iam_policy.glue_secrets_access.arn
}

# Update Step Function IAM policy
resource "aws_iam_policy" "step_function_detailed_policy" {
  name        = "pw-step-function-detailed-policy"
  description = "Detailed policy for Step Function with specific resources"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.audit_lambda_name}",
          "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.all_datasources_lambda_arn}"
          # "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.amcs_schema_counts_lambda_name}",
          # "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.dossier_audit_lambda_name}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJobRuns",
          "glue:BatchStopJobRun"
        ]
        Resource = [
          "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:job/${var.amcs-data-ingestion-glue_name}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [
          var.failure-notification-topic-arn,
          var.success-notification-topic-arn
          # var.platform_data_failure_topic_arn,
          # var.cleaning_data_success_topic_arn,
          # var.cleaning_data_failure_topic_arn,
          # var.platform_data_success_topic_arn,
          # var.dossier_success_topic_arn,
          # var.dossier_failure_topic_arn
        ]
      }
    ]
  })
}

# Attach the detailed policy to the Step Function role
resource "aws_iam_role_policy_attachment" "step_function_detailed_policy_attachment" {
  role       = var.step_function_role_name
  policy_arn = aws_iam_policy.step_function_detailed_policy.arn
}