data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# This module takes an existing KMS key and updates its policy
# after all dependent resources have been created

resource "aws_kms_key_policy" "updated_kms_policy" {
  key_id = var.datalake_kms_key_arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Statement 1: Root Account Access
      {
        Sid    = "EnableRootAccountFullAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      
      # Statement 2: CloudWatch Logs Service Access for Specific Log Groups
      {
        Sid    = "AllowCloudWatchLogsForSpecificLogGroups"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*",
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn": var.log_group_arns
          }
        }
      },
      
      # Statement 3: S3 Service Access for Specific Buckets
      {
        Sid    = "AllowS3ServiceAccessForSpecificBuckets",
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*",
        Condition = {
          StringLike = {
            "kms:EncryptionContext:aws:s3:arn": var.bucket_arns
          }
        }
      },
      
      # Statement 4: AWS Glue Service Access for Specific Jobs
      {
        Sid    = "AllowGlueServiceAccessForSpecificJobs",
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
          },
          StringLike = {
            "kms:EncryptionContext:aws:glue:job": var.glue_job_names
          }
        }
      },
      
      # Statement 5: Allow Grant Operations for AWS Services
      {
        Sid    = "AllowGrantOperationsForAWSServices",
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        Resource = "*",
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource": "true"
          },
          StringEquals = {
            "aws:PrincipalAccount": "${data.aws_caller_identity.current.account_id}"
          }
        }
      },
      
      # Statement 6: Allow Specific IAM Role for Glue Jobs to Use the Key
      {
        Sid    = "AllowSpecificGlueRoleToUseKey",
        Effect = "Allow",
        Principal = {
          AWS = var.glue_role_arn
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}