# IAM Roles and Policies

##############################################################################

resource "aws_iam_role" "codebuild_role" {
  name = var.codebuild_infra_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:sts::767397709508:assumed-role/pw-role-dev-crossaccount_infra_role/EKSDeploySession",
            "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
          ]
        }
      }
    ]
  })
}

# Inline policy for CodeBuild to manage IAM, access S3, logs, DynamoDB, etc.

resource "aws_iam_role_policy" "codebuild_inline_policy" {
  name = "codebuild_inline_policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:UpdateAssumeRolePolicy",  # Permission to update assume role policy
          "iam:PassRole",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "sts:AssumeRole"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = [
          "arn:aws:iam::767397709508:role/pw-ecs_task_role-pulse-dev",
          "arn:aws:iam::767397709508:role/pw-ecs_task_execution_role_name-pulse-dev",
          "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role",
          "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetObjectVersion",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:PutObject"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:GetLogGroupFields",
          "logs:GetQueryResults"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "codepipeline:StartPipelineExecution",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeVpcs"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterfacePermission"
        ],
        Resource = "arn:aws:ec2:us-east-1:339713024244:network-interface/*",
        Condition = {
          StringEquals = {
            "ec2:Subnet" = [
              "arn:aws:ec2:us-east-1:339713024244:subnet/subnet-0a96aab32ee6b2431",
              "arn:aws:ec2:us-east-1:339713024244:subnet/subnet-0b105a211ffc5fe4d"
            ],
            "ec2:AuthorizedService" = "codebuild.amazonaws.com"
          }
        }
      }
    ]
  })
}

# resource "aws_iam_role_policy" "codebuild_inline_policy" {
#   name = "codebuild_inline_policy"
#   role = aws_iam_role.codebuild_role.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "iam:UpdateAssumeRolePolicy",  # Permission to update assume role policy
#           "iam:PassRole",
#           "iam:CreatePolicy",
#           "iam:DeletePolicy",
#           "iam:CreateRole",
#           "iam:DeleteRole",
#           "iam:AttachRolePolicy",
#           "iam:DetachRolePolicy",
#           "iam:PutRolePolicy",
#           "iam:DeleteRolePolicy",
#           "sts:AssumeRole"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = "sts:AssumeRole",
#         Resource = [
#           "arn:aws:iam::767397709508:role/pw-ecs_task_role-pulse-dev",
#           "arn:aws:iam::767397709508:role/pw-ecs_task_execution_role_name-pulse-dev",
#           "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role",
#           "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
#         ]
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "s3:GetObject",
#           "s3:ListBucket",
#           "s3:GetObjectVersion",
#           "s3:GetBucketLocation",
#           "s3:GetBucketVersioning",
#           "s3:PutObject"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "logs:GetLogEvents",
#           "logs:GetLogGroupFields",
#           "logs:GetQueryResults"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = "codepipeline:StartPipelineExecution",
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "dynamodb:GetItem",
#           "dynamodb:PutItem",
#           "dynamodb:DeleteItem"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# Attach managed policies for CodeBuild, ECR, and ECS
resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_ecs_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}






##############################################################################
# IAM Role for CodeBuild
# resource "aws_iam_role" "codebuild_role" {
#   name = var.codebuild_infra_role_name

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "codebuild.amazonaws.com"
#         }
#       },
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           AWS = [
#             "arn:aws:sts::767397709508:assumed-role/pw-role-dev-crossaccount_infra_role/EKSDeploySession",
#             "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
#           ]
#         }
#       }
#     ]
#   })
# }

# # Inline policy for CodeBuild to assume roles, manage IAM, access S3, logs, DynamoDB, etc.
# resource "aws_iam_role_policy" "codebuild_inline_policy" {
#   name = "codebuild_inline_policy"
#   role = aws_iam_role.codebuild_role.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "iam:CreatePolicy",
#           "iam:DeletePolicy",
#           "iam:CreateRole",
#           "iam:DeleteRole",
#           "iam:AttachRolePolicy",
#           "iam:DetachRolePolicy",
#           "iam:PutRolePolicy",
#           "iam:DeleteRolePolicy",
#           "iam:PassRole",
#           "iam:UpdateAssumeRolePolicy",  # Permission to update assume role policy
#           "sts:AssumeRole"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = "sts:AssumeRole",
#         Resource = [
#           "arn:aws:iam::767397709508:role/pw-ecs_task_role-pulse-dev",
#           "arn:aws:iam::767397709508:role/pw-ecs_task_execution_role_name-pulse-dev",
#           "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role",
#           "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
#         ]
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "s3:GetObject",
#           "s3:ListBucket",
#           "s3:GetObjectVersion",
#           "s3:GetBucketLocation",
#           "s3:GetBucketVersioning",
#           "s3:PutObject"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "logs:GetLogEvents",
#           "logs:GetLogGroupFields",
#           "logs:GetQueryResults"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = "codepipeline:StartPipelineExecution",
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "dynamodb:GetItem",
#           "dynamodb:PutItem",
#           "dynamodb:DeleteItem"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Attach managed policies for CodeBuild, ECR, and ECS
# resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
#   role       = aws_iam_role.codebuild_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
# }

# resource "aws_iam_role_policy_attachment" "codebuild_ecr_policy_attachment" {
#   role       = aws_iam_role.codebuild_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
# }

# resource "aws_iam_role_policy_attachment" "codebuild_ecs_policy_attachment" {
#   role       = aws_iam_role.codebuild_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
# }

###############################################################################

resource "aws_iam_role" "codepipeline_role" {
  name = var.codepipeline_infra_role_name
   tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          var.artifact_bucket_arn,
          "${var.artifact_bucket_arn}/*",
          var.build_logs_store_arn,
          "${var.build_logs_store_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = [
          var.pw_codebuild_infra_terraform_plan_arn,
          var.pw_codebuild_infra_terraform_apply_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.aws_sns_topic_manual_approval_arn
      },
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = var.bitbucket_connection_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

###############################################################################################

# IAM role for CodeGuru Reviewer
resource "aws_iam_role" "codeguru_role" {
  name = var.codeguru_reviewer_role_name
  tags = var.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "codeguru-reviewer.amazonaws.com"
      }
    }]
  })
}

# IAM policy for CodeGuru Reviewer
resource "aws_iam_role_policy" "codeguru_policy" {
  role = aws_iam_role.codeguru_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "codeguru-reviewer:CreateCodeReview",
        "codeguru-reviewer:ListCodeReviews",
        "codeguru-reviewer:DescribeCodeReview"
      ],
      Resource = "*"
    }]
  })
   
}

###############################################################################################

# resource "aws_iam_role" "codepipeline_role" {
#   name = var.codepipeline_infra_role_name

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "codepipeline.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "codepipeline_policy" {
#   role = aws_iam_role.codepipeline_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:GetObjectVersion",
#           "s3:GetBucketVersioning",
#           "s3:PutObject"
#         ]
#         Resource = [
#           var.artifact_bucket_arn,
#           var.build_logs_store_arn,
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "codebuild:BatchGetBuilds",
#           "codebuild:StartBuild"
#         ]
#         Resource = [
#           var.pw_codebuild_infra_terraform_plan_arn,
#           var.pw_codebuild_infra_terraform_apply_arn
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "sns:Publish"
#         ]
#         Resource = var.aws_sns_topic_manual_approval_arn
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "codestar-connections:UseConnection"
#         ]
#         Resource = var.bitbucket_connection_arn
#       }
#     ]
#   })
# }