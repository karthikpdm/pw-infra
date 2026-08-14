data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Data source for existing logs bucket
data "aws_s3_bucket" "access_logs" {
  bucket = "pw-access-logs-${var.env}"
}


resource "aws_s3_bucket" "frontend" {
  bucket = replace(var.bucket_name, "_", "-")

  tags = merge(
    var.tags,
    {
      Name = replace(var.bucket_name, "_", "-")
    }
  )
}

# Enable versioning
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::pw-pulse-${var.env}",
          "arn:aws:s3:::pw-pulse-${var.env}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      # {
      #   Action = "s3:GetObject"
      #   Effect = "Allow"
      #   Principal = {
      #     AWS = "AIDAIBYQL5WBZLW3VNJJC"
      #   }
      #   Resource = "arn:aws:s3:::pw-pulse-${var.env}/*"
      #   Sid = "2"
      # },
      {
        Sid = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = "arn:aws:s3:::pw-pulse-${var.env}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.cloudfront_full_arn
          }
        }
      }
    ]
  })

  lifecycle {
    ignore_changes = [policy]
  }
}


# Custom KMS key for S3 encryption

resource "aws_kms_alias" "s3_encryption_key_alias" {
  name          = "alias/pw-s3-encryption-key-pulse-${var.env}"
  target_key_id = aws_kms_key.s3_encryption_key.key_id
}

resource "aws_kms_key" "s3_encryption_key" {
  description             = "Custom KMS key for S3 bucket encryption pulse"
  deletion_window_in_days = 30
  enable_key_rotation     = true 

  policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "key-consolepolicy-3",
    "Statement": [
      {
        "Sid": "Allow CloudFront use of the key",
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudfront.amazonaws.com"
        },
        "Action": [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ],
        "Resource": "*",
        "Condition": {
          "StringEquals": {
            "aws:SourceArn": var.cloudfront_full_arn
          }
        }
      },
      {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "AllowCloudWatchLogs",
        "Effect": "Allow",
        "Principal": {
          "Service": "logs.${data.aws_region.current.name}.amazonaws.com"
        },
        "Action": [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource": "*",
        "Condition": {
          "ArnEquals": {
            "kms:EncryptionContext:aws:logs:arn": [
              "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:aws-waf-logs-${var.env}"
            ]
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "pw-s3-encryption-key-pulse-${var.env}"
    }
  )
}

# resource "aws_kms_key" "s3_encryption_key" {
#   description             = "Custom KMS key for S3 bucket encryption pulse"
#   deletion_window_in_days = 10

#     policy = jsonencode({
#     "Version": "2012-10-17",
#     "Id": "key-consolepolicy-3",
#     "Statement": [
#       {
#         "Sid": "Allow CloudFront use of the key",
#         "Effect": "Allow",
#         "Principal": {
#           "Service": "cloudfront.amazonaws.com"
#         },
#         "Action": [
#           "kms:Decrypt",
#           "kms:Encrypt",
#           "kms:GenerateDataKey*"
#         ],
#         "Resource": "*",
#         "Condition": {
#           "StringEquals": {
#             "aws:SourceArn": var.cloudfront_full_arn
#           }
#         }
#       },
#       {
#         "Sid": "Enable IAM User Permissions",
#         "Effect": "Allow",
#         "Principal": {
#           "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#         },
#         "Action": "kms:*",
#         "Resource": "*"
#       }
#     ]
#   })

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-s3-encryption-key-pulse-${var.env}"
#     }
#   )
# }


############################################################################################

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Id": "key-consolepolicy-3",
#     "Statement": [
#       {
#         "Sid": "Allow use of the key",
#         "Effect": "Allow",
#         "Principal": {
#           "Service": "cloudfront.amazonaws.com"
#         },
#         "Action": [
#           "kms:Decrypt",
#           "kms:Encrypt",
#           "kms:GenerateDataKey*"
#         ],
#         "Resource": "*",
#         "Condition": {
#           "StringEquals": {
#             "aws:SourceArn": var.cloudfront_full_arn
#           }
#         }
#       },
#       {
#         "Sid": "Enable IAM User Permissions",
#         "Effect": "Allow",
#         "Principal": {
#           "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#         },
#         "Action": "kms:*",
#         "Resource": "*"
#       },
#       {
#         "Sid": "Allow access for Key Administrators",
#         "Effect": "Allow",
#         "Principal": {
#           "AWS": [
#             "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/devops",
#             "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/pulse"
#           ]
#         },
#         "Action": [
#           "kms:*"
#         ],
#         "Resource": "*"
#       },
#       {
#         "Sid": "Allow use of the key",
#         "Effect": "Allow",
#         "Principal": {
#           "AWS": [
#             "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/devops",
#             "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/pulse"
#           ]
#         },
#         "Action": [
#           "kms:Encrypt",
#           "kms:Decrypt",
#           "kms:ReEncrypt*",
#           "kms:GenerateDataKey*",
#           "kms:DescribeKey"
#         ],
#         "Resource": "*"
#       },
#       {
#         "Sid": "Allow attachment of persistent resources",
#         "Effect": "Allow",
#         "Principal": {
#           "AWS": [
#             "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/devops",
#             "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/pulse"
#           ]
#         },
#         "Action": [
#           "kms:CreateGrant",
#           "kms:ListGrants",
#           "kms:RevokeGrant"
#         ],
#         "Resource": "*",
#         "Condition": {
#           "Bool": {
#             "kms:GrantIsForAWSResource": "true"
#           }
#         }
#       }
#     ]
#   })

#    tags = merge(
#     var.tags,
#     {
#       Name = "pw-s3-encryption-key-pulse-${var.env}"
#     }
#   )
# }

# S3 bucket encryption with custom KMS key
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_encryption_key.arn
    }
  }
}



# Enable logging on the source bucket
resource "aws_s3_bucket_logging" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  target_bucket = data.aws_s3_bucket.access_logs.id
  target_prefix = "${replace(var.bucket_name, "_", "-")}/access-logs/"
}

# S3 bucket policy for access logs
resource "aws_s3_bucket_policy" "access_logs" {
  bucket = data.aws_s3_bucket.access_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3LogDelivery",
        Effect = "Allow",
        Principal = {
          Service = "logging.s3.amazonaws.com"
        },
        Action = [
          "s3:PutObject"
        ],
        Resource = [
          "${data.aws_s3_bucket.access_logs.arn}/*"
        ],
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          },
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.frontend.arn
          }
        }
      }
    ]
  })
}





# Create SNS Topic for S3 delete notifications
resource "aws_sns_topic" "s3_event_notifications" {
  name = "pw-s3-event-notifications-${var.env}"
  kms_master_key_id = aws_kms_key.s3_encryption_key.id
  
  tags = merge(
    var.tags,
    {
      Name = "pw-s3-event-notifications-${var.env}"
    }
  )
}

# SNS Topic Policy to allow S3 to publish
resource "aws_sns_topic_policy" "s3_event_notifications" {
  arn = aws_sns_topic.s3_event_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowPulseBuckets"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.s3_event_notifications.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::pw-pulse-*"
          }
        }
      },
      {
        Sid = "AllowAccessLogsBucket"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.s3_event_notifications.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::pw-access-logs-${var.env}"
          }
        }
      }
    ]
  })
}

# # SNS Topic Policy to allow S3 to publish
# resource "aws_sns_topic_policy" "s3_event_notifications" {
#   arn = aws_sns_topic.s3_event_notifications.arn

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "s3.amazonaws.com"
#         }
#         Action = "SNS:Publish"
#         Resource = aws_sns_topic.s3_event_notifications.arn
#         Condition = {
#           StringEquals = {
#             "aws:SourceAccount" = data.aws_caller_identity.current.account_id
#           }
#           ArnLike = {
#             # "aws:SourceArn" = "arn:aws:s3:::pw-pulse-${var.env}",
#             "aws:SourceArn" = "arn:aws:s3:::pw-pulse-*",
#             "aws:SourceArn" = "arn:aws:s3:::pw-access-logs-${var.env}",
#             # "aws:SourceArn" = "arn:aws:s3:::pw-pulse-stg-${var.env}"
#           }
#         }
#       }
#     ]
#   })
# }

# S3 Bucket Notification Configuration
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "pw-pulse-${var.env}"

  topic {
    topic_arn = aws_sns_topic.s3_event_notifications.arn
    events    = [
      "s3:ObjectRemoved:Delete",
      "s3:ObjectRemoved:DeleteMarkerCreated"
    ]
  }

  depends_on = [aws_sns_topic_policy.s3_event_notifications]
}


###########################################################################################

# # S3 Bucket Definition
# resource "aws_s3_bucket" "frontend" {
#   bucket = "${replace(var.bucket_name, "_", "-")}"  # Ensure no underscores are used

#   lifecycle {
#     ignore_changes = [
#       bucket,  # Ignore changes to the bucket name
#     ]
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name = "${replace(var.bucket_name, "_", "-")}"
#     }
#   )
# }

# # Enable static website hosting for the S3 bucket
# resource "aws_s3_bucket_website_configuration" "frontend" {
#   bucket = aws_s3_bucket.frontend.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "index.html"
#   }
# }

# # S3 Bucket Public Access Block (Disable block_public_policy to allow public policies)
# resource "aws_s3_bucket_public_access_block" "frontend" {
#   bucket = aws_s3_bucket.frontend.id

#   block_public_acls       = true
#   block_public_policy     = true  # Allow public policies
#   ignore_public_acls      = true
#   restrict_public_buckets = true  # Allow public access to the bucket
# }

# # S3 Bucket Policy to allow public read access and enforce SSL
# resource "aws_s3_bucket_policy" "frontend" {
#   bucket = aws_s3_bucket.frontend.id

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Deny",
#             "Principal": "*",
#             "Action": "s3:*",
#             "Resource": [
#                 "arn:aws:s3:::pw-pulse-${var.env}",
#                 "arn:aws:s3:::pw-pulse-${var.env}/*"
#             ],
#             "Condition": {
#                 "Bool": {
#                     "aws:SecureTransport": "false"
#                 }
#             }
#         },
#         {
#             "Sid": "2",
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": "${var.cloudfront_oai_iam_arn}"
#             },
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::pw-pulse-${var.env}/*"
#         }

#     ]
# }
# EOF
# }


#######################################################################################################

# # S3 Bucket Definition
# resource "aws_s3_bucket" "frontend" {
#   bucket = "${replace(var.bucket_name, "_", "-")}"  # Ensure no underscores are used

  

#   lifecycle {
#     ignore_changes = [
#       bucket,  # Ignore changes to the bucket name
#       tags     # Ignore changes to tags, if any
#     ]
#   }

  

#   tags = merge(
#     var.tags,
#     {
#       Name = "${replace(var.bucket_name, "_", "-")}"
#     }
#   )
# }

# # Enable static website hosting for the S3 bucket
# resource "aws_s3_bucket_website_configuration" "frontend" {
#   bucket = aws_s3_bucket.frontend.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "index.html"
#   }
# }

# # S3 Bucket Public Access Block (Disable block_public_policy to allow public policies)
# resource "aws_s3_bucket_public_access_block" "frontend" {
#   bucket = aws_s3_bucket.frontend.id

#   block_public_acls       = true
#   block_public_policy     = false  # Allow public policies
#   ignore_public_acls      = true
#   restrict_public_buckets = false  # Allow public access to the bucket
# }

# # S3 Bucket Policy to allow public read access (needed for static website hosting)
# resource "aws_s3_bucket_policy" "frontend" {
#   bucket = aws_s3_bucket.frontend.id
              
              
# # "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E3QEOY5PDSXMVZ"

#  policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "2",
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": "${var.cloudfront_oai_iam_arn}"
#             },
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::pw-pulse-${var.env}/*"
#         # },
#         # {
#         #     "Sid": "EnforceSSL",
#         #     "Effect": "Deny",
#         #     "Principal": "*",
#         #     "Action": "s3:*",
#         #     "Resource": [
#         #         "arn:aws:s3:::pw-pulse-${var.env}",
#         #         "arn:aws:s3:::pw-pulse-${var.env}/*"
#         #     ],
#         #     "Condition": {
#         #         "Bool": {
#         #             "aws:SecureTransport": "false"
#         #         }
#         #     }
#         # }
#     ]
# }
# EOF
# }


# ,
#         {
#             "Sid": "AllowCloudFrontOriginAccessIdentity",
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E3QEOY5PDSXMVZ"
#             },
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::pw-pulse-${var.env}/*"
#         }


# policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Deny",
#             "Principal": "*",
#             "Action": "s3:*",
#             "Resource": [
#                 "arn:aws:s3:::pw-pulse-${var.env}",
#                 "arn:aws:s3:::pw-pulse-${var.env}/*"
#             ],
#             "Condition": {
#                 "Bool": {
#                     "aws:SecureTransport": "false"
#                 }
#             }
#         },
#         {
#             "Sid": "AllowCloudFrontServicePrincipalReadOnly",
#             "Effect": "Allow",
#             "Principal": {
#                 "Service": "cloudfront.amazonaws.com"
#             },
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::pw-pulse-${var.env}/*",
#             "Condition": {
#                 "StringEquals": {
#                     "AWS:SourceArn": "arn:aws:cloudfront::767397709508:distribution/E3387Y2KKM2TYF"
#                 }
#             }
#         },
#         {
#             "Sid": "AllowCloudFrontOriginAccessIdentity",
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E3QEOY5PDSXMVZ"
#             },
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::pw-pulse-${var.env}/*"
#         }

#     ]
# }
# EOF
# }