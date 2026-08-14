data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


# # Define IAM Role for CodeBuild
# resource "aws_iam_role" "codebuild_role" {
#   name               = "pw-role-pulse-role"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "codebuild.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF

#   # Add tags to the IAM role
#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-role-pulse-role"
#     }
#   )
# }


# Define IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "pw-role-pulse-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount": data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn": "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/*"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "pw-role-pulse-role"
    }
  )
}


######################################################################################################

# # Define the policy for CodeBuild role
# resource "aws_iam_policy" "codebuild_s3_policy" {
#   name        = "pw-role-pulse-s3-policy"
#   description = "Policy to allow CodeBuild to manage S3 buckets with least privilege"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:CreateBucket",
#           "s3:PutBucketPolicy",
#           "s3:PutBucketTagging",
#           "s3:GetBucketLocation",
#           "s3:ListBucket",
#           "s3:PutObject",
#           "s3:GetObject",
#           "s3:DeleteObject",
#           "s3:PutBucketPublicAccessBlock"
#         ]
#         Resource = [
#           "arn:aws:s3:::${var.bucket_name}",
#           "arn:aws:s3:::${var.bucket_name}/*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "iam:GetPolicy",
#           "iam:GetPolicyVersion"
#         ]
#         Resource = [
#           "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/pw-*"
#           # "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/pw-*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Resource = [
#           "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/pw-*",
#           "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/pw-*:*"
#         ]
#       }
#     ]
#   })

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-role-pulse-s3-policy"
#     }
#   )
# }


resource "aws_iam_policy" "codebuild_s3_policy" {
 name        = "pw-role-pulse-s3-policy"
 description = "Policy to allow CodeBuild to manage S3 buckets with least privilege"

 policy = jsonencode({
   Version = "2012-10-17"
   Statement = [
     {
       Effect = "Allow"
       Action = [
         "s3:ListBucket",
         "s3:GetBucketLocation",
         "s3:PutObject",
         "s3:GetObject",
         "s3:DeleteObject"
       ]
       Resource = [
         "arn:aws:s3:::${var.bucket_name}",
         "arn:aws:s3:::${var.bucket_name}/*"
       ]
     },
     {
       Effect = "Allow"
       Action = [
         "logs:CreateLogGroup",
         "logs:CreateLogStream",
         "logs:PutLogEvents"
       ]
       Resource = [
         "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/pw-*",
         "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/pw-*:*"
       ]
     }
   ]
 })

 tags = merge(
   var.tags,
   {
     Name = "pw-role-pulse-s3-policy"
   }
 )
}

#################################################################################################

# Attach the policy to the CodeBuild role
resource "aws_iam_role_policy_attachment" "attach_codebuild_s3_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_s3_policy.arn
}



# # Define the policy for CodeBuild role
# resource "aws_iam_policy" "codebuild_s3_policy" {
#   name        = "pw-role-pulse-s3-policy"
#   description = "Policy to allow CodeBuild to create and manage S3 buckets and IAM policies"

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Action": [
#           "s3:CreateBucket",
#           "s3:PutBucketPolicy",
#           "s3:PutBucketTagging",
#           "s3:GetBucketLocation",
#           "s3:ListBucket",
#           "s3:PutObject",
#           "s3:GetObject",
#           "s3:DeleteObject",
#           "s3:PutBucketPublicAccessBlock"
#         ],
#         "Resource": [
#           "arn:aws:s3:::${var.bucket_name}",
#           "arn:aws:s3:::${var.bucket_name}/*"
#         ]
#       },
#       {
#         "Effect": "Allow",
#         "Action": [
#           "iam:GetPolicy",
#           "iam:CreatePolicy",
#           "iam:AttachRolePolicy",
#           "iam:PassRole",
#           "iam:GetPolicyVersion"
#         ],
#         "Resource": "*"
#       }
#     ]
#   })
# }

# # Attach the policy to the CodeBuild role
# resource "aws_iam_role_policy_attachment" "attach_codebuild_s3_policy" {
#   role       = aws_iam_role.codebuild_role.name
#   policy_arn = aws_iam_policy.codebuild_s3_policy.arn
# }
