 # Add required data sources if not already present
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

 ############################ ECS #################################

# Trust relationship for the ECS Task Execution Role with Enhanced Security
data "aws_iam_policy_document" "ecs_task_execution_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    # Optional: Add root account as a principal if cross-account access is needed
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    # Confused Deputy Prevention Conditions
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [
        "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
        "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task/*"
      ]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project_name}-ecs_task_execution_role-pulse-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_policy.json

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ecs_task_execution_role-pulse-${var.env}"
    }
  )
}

# ECR Access Policy with Scoped Resource
resource "aws_iam_policy" "ecr_access_policy" {
  name        = "${var.project_name}-ECRAccessPolicy-pulse-${var.env}"
  description = "Policy to provide access to ECR repository for ECS tasks"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# CloudWatch Logs Policy with Limited Scope
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "${var.project_name}-CloudWatchLogsPolicy-pulse-${var.env}"
  description = "Policy to provide access to CloudWatch Logs for ECS tasks"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.project_name}-pulse-${var.env}:*"
      }
    ]
  })
  tags = var.tags
}

# Policy Attachments
resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# # Trust relationship for the ECS Task Execution Role
# data "aws_iam_policy_document" "ecs_task_execution_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }

#     condition {
#       test     = "ArnLike"
#       variable = "aws:SourceArn"
#       values   = ["arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
#     }
    
#     condition {
#       test     = "StringEquals"
#       variable = "aws:SourceAccount"
#       values   = [data.aws_caller_identity.current.account_id]
#     }
#   }
# }


# # IAM Role for ECS Task Execution
# resource "aws_iam_role" "ecs_task_execution_role" {
#   name               = "${var.project_name}-ecs_task_execution_role-pulse-${var.env}"
#   assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_policy.json

  
#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.project_name}-ecs_task_execution_role-pulse-${var.env}"
#     }
#   )
# }

# # ECR access policy
# resource "aws_iam_policy" "ecr_access_policy" {
#   name        = "${var.project_name}-ECRAccessPolicy-pulse-${var.env}"
#   description = "Policy to provide access to ECR repository for ECS tasks"
#   policy      = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect   = "Allow",
#         Action   = [
#           "ecr:GetAuthorizationToken",
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:BatchGetImage"
#         ],
#         Resource = "*"
#         # Resource = "arn:aws:ecr:us-east-1:339713024244:repository/prioritywaste/pulse"

#       },
#       {
#         Effect   = "Allow",
#         Action   = "ecr:GetAuthorizationToken",
#         Resource = "*"
#       }
#     ]
#   })
# }

# # CloudWatch Logs access policy
# resource "aws_iam_policy" "cloudwatch_logs_policy" {
#   name        = "${var.project_name}-CloudWatchLogsPolicy-pulse-${var.env}"
#   description = "Policy to provide access to CloudWatch Logs for ECS tasks"
#   policy      = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "logs:DescribeLogStreams"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Attach ECR access policy to the ECS Task Execution Role
# resource "aws_iam_role_policy_attachment" "ecr_policy_attachment_execution" {
#   role       = aws_iam_role.ecs_task_execution_role.name
#   policy_arn = aws_iam_policy.ecr_access_policy.arn
# }

# # Attach CloudWatch Logs Policy to the Role
# resource "aws_iam_role_policy_attachment" "cloudwatch_logs_policy_attachment" {
#   role       = aws_iam_role.ecs_task_execution_role.name
#   policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
# }

# # Attach AWS Managed Policy for ECS Task Execution
# resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed_policy_attachment" {
#   role       = aws_iam_role.ecs_task_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }
########################     ecs task ########################



# Define the trust relationship policy for ECS Task Role
data "aws_iam_policy_document" "ecs_task_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::339713024244:root"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.project_name}-ecs_task_role-pulse-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_policy.json

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ecs_task_role-pulse-${var.env}"
    }
  )
}

# DynamoDB Policy
resource "aws_iam_policy" "dynamodb" {
  name        = "${var.project_name}-dynamodb-pulse-${var.env}"
  description = "Policy that allows access to DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:UpdateTimeToLive",
          "dynamodb:PutItem",
          "dynamodb:DescribeTable",
          "dynamodb:ListTables",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:UpdateTable"
        ]
        Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/*"
      }
    ]
  })

  tags = var.tags
}

# Attach DynamoDB Policy to ECS Task Role
resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.dynamodb.arn
}

# # Define the trust relationship policy for ECS Task Role
# data "aws_iam_policy_document" "ecs_task_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }

#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::339713024244:root"]
#     }

#     condition {
#       test     = "ArnLike"
#       variable = "aws:SourceArn"
#       values   = ["arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
#     }
    
#     condition {
#       test     = "StringEquals"
#       variable = "aws:SourceAccount"
#       values   = [data.aws_caller_identity.current.account_id]
#     }
#   }
# }



# # IAM Role for ECS Task
# resource "aws_iam_role" "ecs_task_role" {
#   name               = "${var.project_name}-ecs_task_role-pulse-${var.env}"
#   assume_role_policy = data.aws_iam_policy_document.ecs_task_role_policy.json

 

#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.project_name}-ecs_task_role-pulse-${var.env}"
#     }
#   )
# }



# resource "aws_iam_policy" "dynamodb" {
#   name        = "${var.project_name}-dynamodb-pulse-${var.env}"
#   description = "Policy that allows access to DynamoDB"
 
#  policy = <<EOF
# {
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Effect": "Allow",
#            "Action": [
#                "dynamodb:CreateTable",
#                "dynamodb:UpdateTimeToLive",
#                "dynamodb:PutItem",
#                "dynamodb:DescribeTable",
#                "dynamodb:ListTables",
#                "dynamodb:DeleteItem",
#                "dynamodb:GetItem",
#                "dynamodb:Scan",
#                "dynamodb:Query",
#                "dynamodb:UpdateItem",
#                "dynamodb:UpdateTable"
#            ],
#            "Resource": "*"
#        }
#    ]
# }
# EOF
# }
 
# resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
#   role       = aws_iam_role.ecs_task_role.name
#   policy_arn = aws_iam_policy.dynamodb.arn
# }



########################################################################



