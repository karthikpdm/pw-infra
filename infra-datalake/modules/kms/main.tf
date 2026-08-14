# data "aws_caller_identity" "current" {}

# resource "aws_kms_key" "s3_datalake_encryption" {
#   description             = "KMS CMK for encrypting s3 datalake buckets"
#   deletion_window_in_days = 7
#   enable_key_rotation     = true

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       # Statement 1: Root Account Access
#       {
#         Sid    = "EnableRootAccountFullAccess"
#         Effect = "Allow"
#         Principal = {
#           AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#         }
#         Action   = "kms:*"
#         Resource = "*"
#       },
      
#       # Statement 2: CloudWatch Logs Service Access for Specific Log Groups
#       {
#         Sid    = "AllowCloudWatchLogsForSpecificLogGroups"
#         Effect = "Allow"
#         Principal = {
#           Service = "logs.${data.aws_region.current.name}.amazonaws.com"
#         }
#         Action = [
#           "kms:Encrypt",
#           "kms:Decrypt",
#           "kms:ReEncrypt*",
#           "kms:GenerateDataKey*",
#           "kms:DescribeKey"
#         ],
#         Resource = "*",
#         Condition = {
#           ArnEquals = {
#             "kms:EncryptionContext:aws:logs:arn": [
#               var.incremental_log_group_arn,
#               var.data_ingestion_netsuite_log_group_arn,
#               var.platform_data_incremental_log_group_arn,
#               var.dossier_delta_load_log_group_arn,
#               var.data_cleansing_log_group_arn,
#               var.connect_files_log_group_arn,
#               var.heavy_haul_file_log_group_arn,
#               var.residential_file_data_log_group_arn
#             ]
#           }
#         }
#       },
      
#       # Statement 3: S3 Service Access for Specific Buckets
#       {
#         Sid    = "AllowS3ServiceAccessForSpecificBuckets",
#         Effect = "Allow",
#         Principal = {
#           Service = "s3.amazonaws.com"
#         },
#         Action = [
#           "kms:Encrypt",
#           "kms:Decrypt",
#           "kms:ReEncrypt*",
#           "kms:GenerateDataKey*",
#           "kms:DescribeKey"
#         ],
#         Resource = "*",
#         Condition = {
#           StringLike = {
#             "kms:EncryptionContext:aws:s3:arn": [
#               var.raw_bucket_arn,
#               var.cleansed_bucket_arn,
#               var.curated_bucket_arn,
#               var.operational_bucket_arn,
#               var.platform_data_bucket_arn,
#               var.temp_bucket_arn,
#               var.aws_glue_bucket_arn,
#               var.dossier_layer_bucket_arn,
#               var.pw_reporting_bucket_arn,
#               var.pw_amcs_historical_bucket_arn
#             ]
#           }
#         }
#       },
      
#       # Statement 4: AWS Glue Service Access for Specific Jobs
#       {
#         Sid    = "AllowGlueServiceAccessForSpecificJobs",
#         Effect = "Allow",
#         Principal = {
#           Service = "glue.amazonaws.com"
#         },
#         Action = [
#           "kms:Encrypt",
#           "kms:Decrypt",
#           "kms:ReEncrypt*",
#           "kms:GenerateDataKey*",
#           "kms:DescribeKey"
#         ],
#         Resource = "*",
#         Condition = {
#           StringEquals = {
#             "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
#           },
#           StringLike = {
#             "kms:EncryptionContext:aws:glue:job": [
#               var.glue_amcs_incremental_job_name,
#               var.glue_data_ingestion_netsuite_job_name,
#               var.glue_platform_data_incremental_load_job_name,
#               var.glue_dossier_delta_load_job_name,
#               var.glue_data_cleansing_job_name,
#               var.glue_connect_files_job_name,
#               var.glue_heavy_haul_file_job_name,
#               var.glue_residential_file_data_job_name
#             ]
#           }
#         }
#       },
      
#       # # Statement 5: AWS Glue Security Configuration
#       # {
#       #   Sid    = "AllowGlueSecurityConfiguration",
#       #   Effect = "Allow",
#       #   Principal = {
#       #     Service = "glue.amazonaws.com"
#       #   },
#       #   Action = [
#       #     "kms:Encrypt",
#       #     "kms:Decrypt",
#       #     "kms:ReEncrypt*",
#       #     "kms:GenerateDataKey*",
#       #     "kms:DescribeKey"
#       #   ],
#       #   Resource = "*",
#       #   Condition = {
#       #     StringEquals = {
#       #       "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
#       #     },
#       #     StringLike = {
#       #       "kms:EncryptionContext:aws:glue:security-configuration": [
#       #         var.glue_security_config_pattern
#       #       ]
#       #     }
#       #   }
#       # },
      
#       # Statement 6: Allow Grant Operations for AWS Services
#       {
#         Sid    = "AllowGrantOperationsForAWSServices",
#         Effect = "Allow",
#         Principal = {
#           AWS = "*"
#         },
#         Action = [
#           "kms:CreateGrant",
#           "kms:ListGrants",
#           "kms:RevokeGrant"
#         ],
#         Resource = "*",
#         Condition = {
#           Bool = {
#             "kms:GrantIsForAWSResource": "true"
#           },
#           StringEquals = {
#             "aws:PrincipalAccount": "${data.aws_caller_identity.current.account_id}"
#           }
#         }
#       },
      
#       # Statement 7: Allow Specific IAM Role for Glue Jobs to Use the Key
#       {
#         Sid    = "AllowSpecificGlueRoleToUseKey",
#         Effect = "Allow",
#         Principal = {
#           AWS = var.glue_role_arn
#         },
#         Action = [
#           "kms:Encrypt",
#           "kms:Decrypt",
#           "kms:ReEncrypt*",
#           "kms:GenerateDataKey*",
#           "kms:DescribeKey"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
  
  


#   tags = merge(var.tags, {
#     Name = "pw-kms-${var.env}-datalake-s3-encryption"
#   })
# }



# resource "aws_kms_alias" "s3_encryption_alias" {
#   name          = "alias/pw-kms-${var.env}-datalake-s3-encryption"
#   target_key_id = aws_kms_key.s3_datalake_encryption.id
# }





data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create a KMS key with a basic policy
resource "aws_kms_key" "datalake_kms_encryption" {
  description             = "KMS CMK for encrypting s3 datalake buckets"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  # Initial policy with minimal permissions
  # This avoids circular dependencies
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccountFullAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowServiceAccess"
        Effect = "Allow"
        Principal = {
          Service = [
            "logs.${data.aws_region.current.name}.amazonaws.com",
            "s3.amazonaws.com",
            "glue.amazonaws.com"
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowGrantOperationsForAWSServices"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource": "true"
          },
          StringEquals = {
            "aws:PrincipalAccount": "${data.aws_caller_identity.current.account_id}"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "pw-${var.env}-datalake-encryption-kms"
  })
}

resource "aws_kms_alias" "s3_encryption_alias" {
  name          = "alias/pw-${var.env}-datalake-encryption-kms"  #for s3,cloudwatch,ddb
  target_key_id = aws_kms_key.datalake_kms_encryption.id
}