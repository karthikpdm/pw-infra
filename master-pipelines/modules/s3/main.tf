# S3 bucket for artifacts
resource "aws_s3_bucket" "artifact_store" {
  bucket = var.artifact_bucket_name

  tags = merge(
    var.tags,
    {
      Name = "pw-s3-${var.artifact_bucket_name}"
    }
  )
  
}

# Versioning and MFA delete for the artifact bucket
resource "aws_s3_bucket_versioning" "artifacts_versioning" {
  bucket = aws_s3_bucket.artifact_store.id
  versioning_configuration {
    status = "Enabled"
    # mfa_delete = true
  }
}

# Enable server access logging for the artifact bucket
resource "aws_s3_bucket_logging" "artifact_store_logging" {
  bucket        = aws_s3_bucket.artifact_store.id
  target_bucket = aws_s3_bucket.access_logs_store.id
  target_prefix = "${aws_s3_bucket.artifact_store.bucket}/logs/"
}

# S3 bucket policy including SecureTransport condition
resource "aws_s3_bucket_policy" "artifact_store_policy" {
  bucket = aws_s3_bucket.artifact_store.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCodePipeline",
        Effect = "Allow",
        Principal = {
          AWS = var.codepipeline_infra_role_arn
        },
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = [
          aws_s3_bucket.artifact_store.arn,
          "${aws_s3_bucket.artifact_store.arn}/*"
        ]
      },
      {
        Sid    = "DenyUnencryptedRequests",
        Effect = "Deny",
        Principal = "*",
        Action = "s3:*",
        Resource = [
          aws_s3_bucket.artifact_store.arn,
          "${aws_s3_bucket.artifact_store.arn}/*"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}

# ########################################################################################################


# S3 bucket for logs
resource "aws_s3_bucket" "build-logs_store" {
  bucket = var.build-logs_bucket_name

  tags = merge(
    var.tags,
    {
      Name = "pw-s3-${var.build-logs_bucket_name}"
    }
  )
}

# Versioning for the build logs bucket
resource "aws_s3_bucket_versioning" "buildlogs_versioning" {
  bucket = aws_s3_bucket.build-logs_store.id
  versioning_configuration {
    status = "Enabled"
    # mfa_delete = true
  }
}

# Enable server access logging for the build logs bucket
resource "aws_s3_bucket_logging" "build_logs_store_logging" {
  bucket        = aws_s3_bucket.build-logs_store.id
  target_bucket = aws_s3_bucket.access_logs_store.id
  target_prefix = "${aws_s3_bucket.build-logs_store.bucket}/logs/"
}

# S3 bucket policy for build logs store to enforce SecureTransport
resource "aws_s3_bucket_policy" "buildlogs_store_policy" {
  bucket = aws_s3_bucket.build-logs_store.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "DenyUnencryptedRequests",
        Effect = "Deny",
        Principal = "*",
        Action = "s3:*",
        Resource = [
          aws_s3_bucket.build-logs_store.arn,
          "${aws_s3_bucket.build-logs_store.arn}/*"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}

# ########################################################################################################

# S3 bucket for access logs
resource "aws_s3_bucket" "access_logs_store" {
  bucket = var.access_logs_bucket_name

   tags = merge(
    var.tags,
    {
      Name = "pw-s3-${var.access_logs_bucket_name}"
    }
  )
}

# Versioning and MFA delete for the access logs bucket
resource "aws_s3_bucket_versioning" "accesslogs_versioning" {
  bucket = aws_s3_bucket.access_logs_store.id
  versioning_configuration {
    status = "Enabled"
    # mfa_delete = true
  }
}

# S3 bucket policy for access logs store to enforce SecureTransport
resource "aws_s3_bucket_policy" "accesslogs_store_policy" {
  bucket = aws_s3_bucket.access_logs_store.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "DenyUnencryptedRequests",
        Effect = "Deny",
        Principal = "*",
        Action = "s3:*",
        Resource = [
          aws_s3_bucket.access_logs_store.arn,
          "${aws_s3_bucket.access_logs_store.arn}/*"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}


# ########################################################################################################

# # S3 bucket for artifacts
# resource "aws_s3_bucket" "artifact_store" {
#   bucket = var.artifact_bucket_name
# }

# # Versioning and MFA delete for the artifact bucket
# resource "aws_s3_bucket_versioning" "artifacts_versioning" {
#   bucket = aws_s3_bucket.artifact_store.id
#   versioning_configuration {
#     status = "Enabled"
#     # mfa_delete = true
#   }
# }

# # Enable server access logging for the artifact bucket
# resource "aws_s3_bucket_logging" "artifact_store_logging" {
#   bucket        = aws_s3_bucket.artifact_store.id
#   target_bucket = aws_s3_bucket.access_logs_store.id
#   target_prefix = "${aws_s3_bucket.artifact_store.bucket}/logs/"
# }

# # S3 bucket policy including SecureTransport condition
# resource "aws_s3_bucket_policy" "artifact_store_policy" {
#   bucket = aws_s3_bucket.artifact_store.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid    = "AllowCodePipeline",
#         Effect = "Allow",
#         Principal = {
#           AWS = var.codepipeline_infra_role_arn
#         },
#         Action = [
#           "s3:GetObject",
#           "s3:GetObjectVersion",
#           "s3:GetBucketVersioning",
#           "s3:PutObject",
#           "s3:PutObjectAcl"
#         ],
#         Resource = [
#           aws_s3_bucket.artifact_store.arn,
#           "${aws_s3_bucket.artifact_store.arn}/*"
#         ]
#       },
#       {
#         Sid    = "DenyUnencryptedRequests",
#         Effect = "Deny",
#         Principal = "*",
#         Action = "s3:*",
#         Resource = [
#           aws_s3_bucket.artifact_store.arn,
#           "${aws_s3_bucket.artifact_store.arn}/*"
#         ],
#         Condition = {
#           Bool = {
#             "aws:SecureTransport": "false"
#           }
#         }
#       }
#     ]
#   })
# }

# ########################################################################################################

# # S3 bucket for build logs
# resource "aws_s3_bucket" "build_logs_store" {
#   bucket = var.build-logs_bucket_name
# }

# # Versioning for the build logs bucket
# resource "aws_s3_bucket_versioning" "buildlogs_versioning" {
#   bucket = aws_s3_bucket.build_logs_store.id
#   versioning_configuration {
#     status = "Enabled"
#     # mfa_delete = true
#   }
# }

# # Enable server access logging for the build logs bucket
# resource "aws_s3_bucket_logging" "build_logs_store_logging" {
#   bucket        = aws_s3_bucket.build_logs_store.id
#   target_bucket = aws_s3_bucket.access_logs_store.id
#   target_prefix = "${aws_s3_bucket.build_logs_store.bucket}/logs/"
# }

# # S3 bucket policy for build logs store to enforce SecureTransport
# resource "aws_s3_bucket_policy" "buildlogs_store_policy" {
#   bucket = aws_s3_bucket.build_logs_store.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid    = "DenyUnencryptedRequests",
#         Effect = "Deny",
#         Principal = "*",
#         Action = "s3:*",
#         Resource = [
#           aws_s3_bucket.build_logs_store.arn,
#           "${aws_s3_bucket.build_logs_store.arn}/*"
#         ],
#         Condition = {
#           Bool = {
#             "aws:SecureTransport": "false"
#           }
#         }
#       }
#     ]
#   })
# }

# ########################################################################################################

# # S3 bucket for access logs
# resource "aws_s3_bucket" "access_logs_store" {
#   bucket = var.access_logs_bucket_name
# }

# # Versioning and MFA delete for the access logs bucket
# resource "aws_s3_bucket_versioning" "accesslogs_versioning" {
#   bucket = aws_s3_bucket.access_logs_store.id
#   versioning_configuration {
#     status = "Enabled"
#     # mfa_delete = true
#   }
# }

# # S3 bucket policy for access logs store to enforce SecureTransport
# resource "aws_s3_bucket_policy" "accesslogs_store_policy" {
#   bucket = aws_s3_bucket.access_logs_store.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid    = "DenyUnencryptedRequests",
#         Effect = "Deny",
#         Principal = "*",
#         Action = "s3:*",
#         Resource = [
#           aws_s3_bucket.access_logs_store.arn,
#           "${aws_s3_bucket.access_logs_store.arn}/*"
#         ],
#         Condition = {
#           Bool = {
#             "aws:SecureTransport": "false"
#           }
#         }
#       }
#     ]
#   })
# }
