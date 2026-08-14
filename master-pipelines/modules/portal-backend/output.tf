# Outputs

output "codebuild_project_name" {
  description = "Name of the created CodeBuild project"
  value       = aws_codebuild_project.pw-contact.name
}

output "codebuild_project_arn" {
  description = "ARN of the created CodeBuild project"
  value       = aws_codebuild_project.pw-contact.arn
}

output "codepipeline_name" {
  description = "Name of the created CodePipeline"
  value       = aws_codepipeline.pw-contact.name
}

output "codepipeline_arn" {
  description = "ARN of the created CodePipeline"
  value       = aws_codepipeline.pw-contact.arn
}

output "webhook_url" {
  description = "URL of the created webhook"
  value       = aws_codepipeline_webhook.bitbucket_webhook.url
  sensitive   = true
}

# output "webhook_secret" {
#   description = "Secret token of the created webhook"
#   value       = aws_codepipeline_webhook.bitbucket_webhook.authentication_configuration[0].secret_token
#   sensitive   = true
# }






































# # Data sources
# data "aws_caller_identity" "current" {}
# data "aws_region" "current" {}


# # Data source for existing logs bucket
# data "aws_s3_bucket" "access_logs" {
#   bucket = "pw-access-logs-${var.env}"
# }

# # S3 Bucket configuration
# resource "aws_s3_bucket" "frontend" {
#   bucket = replace(var.bucket_name, "_", "-")
  
#   # Enable Object Lock
#   # object_lock_enabled = true

#   tags = merge(
#     var.tags,
#     {
#       Name = replace(var.bucket_name, "_", "-")
#     }
#   )
# }

# # # Configure Object Lock default retention
# # resource "aws_s3_bucket_object_lock_configuration" "frontend" {
# #   bucket = aws_s3_bucket.frontend.id

# #   rule {
# #     default_retention {
# #       mode = "COMPLIANCE"  # Can be "GOVERNANCE" or "COMPLIANCE"
# #       days = 30           # Retention period in days
# #     }
# #   }
# # }

# # Enable versioning
# resource "aws_s3_bucket_versioning" "frontend" {
#   bucket = aws_s3_bucket.frontend.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# # Enable S3 encryption with AWS managed key
# resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
#   bucket = aws_s3_bucket.frontend.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm     = "aws:kms"
#       kms_master_key_id = "alias/aws/s3"
#     }
#   }
# }

# # Website configuration
# resource "aws_s3_bucket_website_configuration" "frontend" {
#   bucket = aws_s3_bucket.frontend.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "index.html"
#   }
# }

# # Public access block
# resource "aws_s3_bucket_public_access_block" "frontend" {
#   bucket = aws_s3_bucket.frontend.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# # Bucket policy
# resource "aws_s3_bucket_policy" "frontend" {
#   bucket = aws_s3_bucket.frontend.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Deny"
#         Principal = "*"
#         Action = "s3:*"
#         Resource = [
#           aws_s3_bucket.frontend.arn,
#           "${aws_s3_bucket.frontend.arn}/*"
#         ]
#         Condition = {
#           Bool = {
#             "aws:SecureTransport" = "false"
#           }
#         }
#       },
#       {
#         Action = "s3:GetObject"
#         Effect = "Allow"
#         Principal = {
#           AWS = "AIDAIBYQL5WBZLW3VNJJC"
#         }
#         Resource = "${aws_s3_bucket.frontend.arn}/*"
#         Sid = "2"
#       },
#       {
#         Sid = "AllowCloudFrontServicePrincipal"
#         Effect = "Allow"
#         Principal = {
#           Service = "cloudfront.amazonaws.com"
#         }
#         Action = "s3:GetObject"
#         Resource = "${aws_s3_bucket.frontend.arn}/*"
#         Condition = {
#           StringEquals = {
#             "AWS:SourceArn" = var.cloudfront_full_arn
#           }
#         }
#       }
#     ]
#   })

#   lifecycle {
#     ignore_changes = [policy]
#   }
# }

# # SNS Topic with AWS managed KMS encryption
# resource "aws_sns_topic" "s3_events_topic" {
#   name              = "pw-pulse-${var.env}-s3-events-topic"
#   kms_master_key_id = "alias/aws/sns"

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-pulse-${var.env}-s3-events-topic"
#     }
#   )
# }

# # SNS Topic Policy
# resource "aws_sns_topic_policy" "allow_s3" {
#   arn = aws_sns_topic.s3_events_topic.arn

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "AllowS3BucketNotifications",
#         Effect = "Allow",
#         Principal = {
#           Service = "s3.amazonaws.com"
#         },
#         Action   = "SNS:Publish",
#         Resource = aws_sns_topic.s3_events_topic.arn,
#         Condition = {
#           StringEquals = {
#             "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
#           },
#           ArnLike = {
#             "AWS:SourceArn" = aws_s3_bucket.frontend.arn
#           }
#         }
#       }
#     ]
#   })
# }

# # S3 Bucket Notification
# resource "aws_s3_bucket_notification" "bucket_notifications" {
#   bucket = aws_s3_bucket.frontend.id

#   topic {
#     topic_arn = aws_sns_topic.s3_events_topic.arn
#     events = [
#       "s3:ObjectCreated:*",
#       "s3:ObjectRemoved:*",
#       "s3:ObjectRestore:Post",
#       "s3:ObjectRestore:Completed",
#       "s3:ObjectRestore:Delete"
#     ]
#   }

#   depends_on = [aws_sns_topic_policy.allow_s3]
# }

# # Enable logging on the source bucket
# resource "aws_s3_bucket_logging" "frontend" {
#   bucket = aws_s3_bucket.frontend.id
#   target_bucket = data.aws_s3_bucket.access_logs.id
#   target_prefix = "${replace(var.bucket_name, "_", "-")}/access-logs/"
# }

# # S3 bucket policy for access logs
# resource "aws_s3_bucket_policy" "access_logs" {
#   bucket = data.aws_s3_bucket.access_logs.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "AllowS3LogDelivery",
#         Effect = "Allow",
#         Principal = {
#           Service = "logging.s3.amazonaws.com"
#         },
#         Action = [
#           "s3:PutObject"
#         ],
#         Resource = [
#           "${data.aws_s3_bucket.access_logs.arn}/*"
#         ],
#         Condition = {
#           StringEquals = {
#             "aws:SourceAccount" = data.aws_caller_identity.current.account_id
#           },
#           ArnLike = {
#             "aws:SourceArn" = aws_s3_bucket.frontend.arn
#           }
#         }
#       }
#     ]
#   })
# }

# # # S3 Bucket Lifecycle Configuration for the source buckt
# # resource "aws_s3_bucket_lifecycle_configuration" "frontend" {
# #   bucket = aws_s3_bucket.frontend.id

# #   rule {
# #     id     = "transition_to_glacier"
# #     status = "Enabled"

# #     transition {
# #       days          = 90
# #       storage_class = "GLACIER"
# #     }

# #     expiration {
# #       days = 365
# #     }
# #   }
# # }

# # # Lifecycle policy for log files for the destination bucket
# # resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
# #   bucket = data.aws_s3_bucket.access_logs.id

# #   rule {
# #     id     = "cleanup_old_logs"
# #     status = "Enabled"

# #     transition {
# #       days          = 90
# #       storage_class = "GLACIER"
# #     }

# #     expiration {
# #       days = 365
# #     }
# #   }
# # }
# ###########################################################################################

# # # S3 Bucket Definition
# # resource "aws_s3_bucket" "frontend" {
# #   bucket = "${replace(var.bucket_name, "_", "-")}"  # Ensure no underscores are used

# #   lifecycle {
# #     ignore_changes = [
# #       bucket,  # Ignore changes to the bucket name
# #     ]
# #   }

# #   tags = merge(
# #     var.tags,
# #     {
# #       Name = "${replace(var.bucket_name, "_", "-")}"
# #     }
# #   )
# # }

# # # Enable static website hosting for the S3 bucket
# # resource "aws_s3_bucket_website_configuration" "frontend" {
# #   bucket = aws_s3_bucket.frontend.id

# #   index_document {
# #     suffix = "index.html"
# #   }

# #   error_document {
# #     key = "index.html"
# #   }
# # }

# # # S3 Bucket Public Access Block (Disable block_public_policy to allow public policies)
# # resource "aws_s3_bucket_public_access_block" "frontend" {
# #   bucket = aws_s3_bucket.frontend.id

# #   block_public_acls       = true
# #   block_public_policy     = true  # Allow public policies
# #   ignore_public_acls      = true
# #   restrict_public_buckets = true  # Allow public access to the bucket
# # }

# # # S3 Bucket Policy to allow public read access and enforce SSL
# # resource "aws_s3_bucket_policy" "frontend" {
# #   bucket = aws_s3_bucket.frontend.id

# #   policy = <<EOF
# # {
# #     "Version": "2012-10-17",
# #     "Statement": [
# #         {
# #             "Effect": "Deny",
# #             "Principal": "*",
# #             "Action": "s3:*",
# #             "Resource": [
# #                 "arn:aws:s3:::pw-pulse-${var.env}",
# #                 "arn:aws:s3:::pw-pulse-${var.env}/*"
# #             ],
# #             "Condition": {
# #                 "Bool": {
# #                     "aws:SecureTransport": "false"
# #                 }
# #             }
# #         },
# #         {
# #             "Sid": "2",
# #             "Effect": "Allow",
# #             "Principal": {
# #                 "AWS": "${var.cloudfront_oai_iam_arn}"
# #             },
# #             "Action": "s3:GetObject",
# #             "Resource": "arn:aws:s3:::pw-pulse-${var.env}/*"
# #         }

# #     ]
# # }
# # EOF
# # }


# #######################################################################################################

# # # S3 Bucket Definition
# # resource "aws_s3_bucket" "frontend" {
# #   bucket = "${replace(var.bucket_name, "_", "-")}"  # Ensure no underscores are used

  

# #   lifecycle {
# #     ignore_changes = [
# #       bucket,  # Ignore changes to the bucket name
# #       tags     # Ignore changes to tags, if any
# #     ]
# #   }

  

# #   tags = merge(
# #     var.tags,
# #     {
# #       Name = "${replace(var.bucket_name, "_", "-")}"
# #     }
# #   )
# # }

# # # Enable static website hosting for the S3 bucket
# # resource "aws_s3_bucket_website_configuration" "frontend" {
# #   bucket = aws_s3_bucket.frontend.id

# #   index_document {
# #     suffix = "index.html"
# #   }

# #   error_document {
# #     key = "index.html"
# #   }
# # }

# # # S3 Bucket Public Access Block (Disable block_public_policy to allow public policies)
# # resource "aws_s3_bucket_public_access_block" "frontend" {
# #   bucket = aws_s3_bucket.frontend.id

# #   block_public_acls       = true
# #   block_public_policy     = false  # Allow public policies
# #   ignore_public_acls      = true
# #   restrict_public_buckets = false  # Allow public access to the bucket
# # }

# # # S3 Bucket Policy to allow public read access (needed for static website hosting)
# # resource "aws_s3_bucket_policy" "frontend" {
# #   bucket = aws_s3_bucket.frontend.id
              
              
# # # "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E3QEOY5PDSXMVZ"

# #  policy = <<EOF
# # {
# #     "Version": "2012-10-17",
# #     "Statement": [
# #         {
# #             "Sid": "2",
# #             "Effect": "Allow",
# #             "Principal": {
# #                 "AWS": "${var.cloudfront_oai_iam_arn}"
# #             },
# #             "Action": "s3:GetObject",
# #             "Resource": "arn:aws:s3:::pw-pulse-${var.env}/*"
# #         # },
# #         # {
# #         #     "Sid": "EnforceSSL",
# #         #     "Effect": "Deny",
# #         #     "Principal": "*",
# #         #     "Action": "s3:*",
# #         #     "Resource": [
# #         #         "arn:aws:s3:::pw-pulse-${var.env}",
# #         #         "arn:aws:s3:::pw-pulse-${var.env}/*"
# #         #     ],
# #         #     "Condition": {
# #         #         "Bool": {
# #         #             "aws:SecureTransport": "false"
# #         #         }
# #         #     }
# #         # }
# #     ]
# # }
# # EOF
# # }


# # ,
# #         {
# #             "Sid": "AllowCloudFrontOriginAccessIdentity",
# #             "Effect": "Allow",
# #             "Principal": {
# #                 "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E3QEOY5PDSXMVZ"
# #             },
# #             "Action": "s3:GetObject",
# #             "Resource": "arn:aws:s3:::pw-pulse-${var.env}/*"
# #         }


# # policy = <<EOF
# # {
# #     "Version": "2012-10-17",
# #     "Statement": [
# #         {
# #             "Effect": "Deny",
# #             "Principal": "*",
# #             "Action": "s3:*",
# #             "Resource": [
# #                 "arn:aws:s3:::pw-pulse-${var.env}",
# #                 "arn:aws:s3:::pw-pulse-${var.env}/*"
# #             ],
# #             "Condition": {
# #                 "Bool": {
# #                     "aws:SecureTransport": "false"
# #                 }
# #             }
# #         },
# #         {
# #             "Sid": "AllowCloudFrontServicePrincipalReadOnly",
# #             "Effect": "Allow",
# #             "Principal": {
# #                 "Service": "cloudfront.amazonaws.com"
# #             },
# #             "Action": "s3:GetObject",
# #             "Resource": "arn:aws:s3:::pw-pulse-${var.env}/*",
# #             "Condition": {
# #                 "StringEquals": {
# #                     "AWS:SourceArn": "arn:aws:cloudfront::767397709508:distribution/E3387Y2KKM2TYF"
# #                 }
# #             }
# #         },
# #         {
# #             "Sid": "AllowCloudFrontOriginAccessIdentity",
# #             "Effect": "Allow",
# #             "Principal": {
# #                 "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E3QEOY5PDSXMVZ"
# #             },
# #             "Action": "s3:GetObject",
# #             "Resource": "arn:aws:s3:::pw-pulse-${var.env}/*"
# #         }

# #     ]
# # }
# # EOF
# # }