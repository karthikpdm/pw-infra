

# # CodeBuild project for EKS deployment
# resource "aws_codebuild_project" "pw_contact" {
#   name         = "pw-cb-${var.project_name}-deploy-${var.environment}"
#   description  = "Deploy to EKS cluster for ${var.environment}"
#   service_role = var.codebuild_infra_role_arn

#   artifacts {
#     type = "CODEPIPELINE"
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"

#     environment_variable {
#       name  = "EKS_CLUSTER_NAME"
#       value = "pw-eks-cluster-${var.environment}"
#     }

#     environment_variable {
#       name  = "EKS_CLUSTER_REGION"
#       value = var.eks_cluster_region
#     }

#     environment_variable {
#       name  = "DEPLOYMENT_ROLE_ARN"
#       value = var.deployment_role_arn
#     }

#     environment_variable {
#       name  = "ENVIRONMENT"
#       value = var.environment
#     }
#   }

#   source {
#     type      = "CODEPIPELINE"
#     buildspec = "buildspec.yml"
#   }

#   logs_config {
#     cloudwatch_logs {
#       status      = "ENABLED"
#       group_name  = "/aws/codebuild/pw-cb-${var.project_name}-deploy-${var.environment}"
#       stream_name = "pw-cb-${var.project_name}-deploy-${var.environment}-log-stream"
#     }

#     s3_logs {
#       status              = "ENABLED"
#       location            = "${var.build-logs_bucket_name}/pw-cb-${var.project_name}-deploy-${var.environment}/codebuild-logs"
#       encryption_disabled = false
#     }
#   }

#   # Tags for CodeBuild project
#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-cb-${var.project_name}-deploy-${var.environment}"
#     }
#   )
# }

# # CodePipeline
# resource "aws_codepipeline" "pw_contact" {
#   name     = "pw-cp-${var.project_name}-${var.environment}"
#   role_arn = var.codepipeline_infra_role_arn

#   artifact_store {
#     location = var.artifact_bucket_name
#     type     = "S3"
#   }

#   # Tags for CodePipeline
#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-cp-${var.project_name}-${var.environment}"
#     }
#   )

#   stage {
#     name = "Source"

#     action {
#       name             = "Source"
#       category         = "Source"
#       owner            = "AWS"
#       provider         = "CodeStarSourceConnection"
#       version          = "1"
#       output_artifacts = ["source_output"]

#       configuration = {
#         ConnectionArn    = var.bitbucket_connection_arn
#         FullRepositoryId = "${var.bitbucket_account}/${var.bitbucket_repo_name}"
#         BranchName       = var.branch
#         DetectChanges    = true
#       }
#     }
#   }

#   stage {
#     name = "Deploy"

#     action {
#       name            = "Deploy-to-EKS"
#       category        = "Build"
#       owner           = "AWS"
#       provider        = "CodeBuild"
#       input_artifacts = ["source_output"]
#       version         = "1"

#       configuration = {
#         ProjectName = aws_codebuild_project.pw_contact.name
#       }
#     }
#   }
# }

# # Configure the webhook for the pipeline
# resource "aws_codepipeline_webhook" "bitbucket_webhook" {
#   name            = "pw-webhook-${var.project_name}-${var.environment}"
#   authentication  = "UNAUTHENTICATED"
#   target_action   = "Source"
#   target_pipeline = aws_codepipeline.pw_contact.name

#   filter {
#     json_path    = "$.pullrequest.state"
#     match_equals = "MERGED"
#   }

#   filter {
#     json_path    = "$.pullrequest.destination.branch.name"
#     match_equals = join("|", ["demo", "uat", "main"])
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-webhook-${var.project_name}-${var.environment}"
#     }
#   )
# }


##############################################################################################

# # CodeBuild project for EKS deployment
# resource "aws_codebuild_project" "pw-contact" {
#   name         = "pw-cb-${var.project_name}-deplooy-${var.environment}"
#   description  = "Deploy to EKS cluster for ${var.environment}"
#   service_role = var.codebuild_infra_role_arn

#   artifacts {
#     type = "CODEPIPELINE"
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"

#     environment_variable {
#       name  = "EKS_CLUSTER_NAME"
#       value = "pw-eks-cluster-${var.environment}"
#     }

#     environment_variable {
#       name  = "EKS_CLUSTER_REGION"
#       value = var.eks_cluster_region
#     }

#     environment_variable {
#       name  = "DEPLOYMENT_ROLE_ARN"
#       value = var.deployment_role_arn
#     }

#     environment_variable {
#       name  = "ENVIRONMENT"
#       value = var.environment
#     }
#   }

#   source {
#     type      = "CODEPIPELINE"
#     buildspec = "buildspec.yml"
#   }

#   logs_config {
#     cloudwatch_logs {
#       status      = "ENABLED"
#       group_name  = "/aws/codebuild/pw-cb-${var.project_name}-apply-${var.environment}"
#       stream_name = "pw-cb-${var.project_name}-apply-${var.environment}-log-stream"
#     }

#     s3_logs {
#       status              = "ENABLED"
#       location            = "${var.build-logs_bucket_name}/pw-cb-${var.project_name}-apply-${var.environment}/codebuild-logs"
#       encryption_disabled = false
#     }
#   }
#     # Tags for CodeBuild project
#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-cb-${var.project_name}-deploy-${var.environment}"
#     }
#   ) 
# }

# # CodePipeline
# resource "aws_codepipeline" "pw-contact" {
#   name     = "pw-cp-${var.project_name}-${var.environment}"
#   role_arn = var.codepipeline_infra_role_arn

#   artifact_store {
#     location = var.artifact_bucket_name
#     type     = "S3"
#   }

#   # Tags for CodePipeline
#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-cp-${var.project_name}-${var.environment}"
#     }
#   )

#   stage {
#     name = "Source"

#     action {
#       name             = "Source"
#       category         = "Source"
#       owner            = "AWS"
#       provider         = "CodeStarSourceConnection"
#       version          = "1"
#       output_artifacts = ["source_output"]

#       configuration = {
#         ConnectionArn    = var.bitbucket_connection_arn
#         FullRepositoryId = "${var.bitbucket_account}/${var.bitbucket_repo_name}"
#         BranchName       = var.branch
#         DetectChanges    = true
#       }
#     }
#   }

#   stage {
#     name = "Deploy"

#     action {
#       name            = "Deploy-to-EKS"
#       category        = "Build"
#       owner           = "AWS"
#       provider        = "CodeBuild"
#       input_artifacts = ["source_output"]
#       version         = "1"

#       configuration = {
#         ProjectName = aws_codebuild_project.pw-contact.name
#       }
#     }
#   }
# }

# # Configure the webhook for the pipeline
# resource "aws_codepipeline_webhook" "bitbucket_webhook" {
#   name            = "pw-webhook-${var.project_name}-${var.environment}"
#   authentication  = "UNAUTHENTICATED"
#   target_action   = "Source"
#   target_pipeline = aws_codepipeline.pw-contact.name

#   filter {
#     json_path    = "$.pullrequest.state"
#     match_equals = "MERGED"
#   }

#   filter {
#     json_path    = "$.pullrequest.destination.branch.name"
#     match_equals = join("|", ["demo", "uat", "main"])
#   }

  
#   tags = merge(
#     var.tags,
#     {
#       name = "pw-webhook-${var.project_name}-${var.environment}"
#     }
#   )
# }


#######################################################################################################

# CodeGuru Review role
# resource "aws_iam_role" "codeguru_review_role" {
#   name = "pw-codeguru-review-role-${var.environment}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "codeguru-reviewer.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-codeguru-review-role-${var.environment}"
#     }
#   )
# }

# # CodeGuru Review role policy
# resource "aws_iam_role_policy" "codeguru_review_policy" {
#   name = "pw-codeguru-${var.environment}"
#   role = aws_iam_role.codeguru_review_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "codecommit:GetRepository",
#           "codecommit:GetBranch",
#           "codecommit:GetCommit",
#           "codecommit:GetDifferences",
#           "codecommit:GetBlob",
#           "codecommit:PostCommentForPullRequest"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# Additional IAM policy for CodeBuild role to interact with CodeGuru
# resource "aws_iam_policy" "codebuild_codeguru_policy" {
#   name = "pw-codeguru-policy-${var.environment}"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "codeguru-reviewer:CreateCodeReview",
#           "codeguru-reviewer:DescribeCodeReview",
#           "codeguru-reviewer:ListRecommendations",
#           "codeguru-reviewer:ListFindings",
#           "codeguru-profiler:ConfigureAgent",
#           "codeguru-profiler:CreateProfilingGroup",
#           "codeguru-profiler:UpdateProfilingGroup",
#           "codeguru-profiler:PostAgentProfile",
#           "codeguru-profiler:GetFindings",
#           "codeguru-reviewer:AssociateRepository",
#           "codeguru-reviewer:DescribeRepositoryAssociation",
#           "codeguru-reviewer:DisassociateRepository",
#           "codeguru-reviewer:ListRepositoryAssociations"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "codebuild_codeguru_policy" {
#   role       = "pw-role-codebuild-infra_role"  # Ensure this role name is valid
#   policy_arn = aws_iam_policy.codebuild_codeguru_policy.arn
# }

# CodeGuru Repository Association
# resource "aws_codegurureviewer_repository_association" "example" {
#   repository {
#     bitbucket {
#       connection_arn = var.bitbucket_connection_arn
#       name           = var.bitbucket_repo_name
#       owner          = "prioritywaste"  # Bitbucket workspace name
#     }
#   }


# resource "aws_codegurureviewer_repository_association" "example" {
#   # name = var.bitbucket_repo_name  # Add this line
  
#   repository {
#     bitbucket {
#       connection_arn = var.bitbucket_connection_arn
#       name          = var.bitbucket_repo_name
#       owner         = "prioritywaste"
#     }
#   }

 

  # depends_on = [
  #   aws_iam_role.codeguru_review_role,
  #   aws_iam_role_policy.codeguru_review_policy
  # ]

  #  provider_type = "Bitbucket"

  # tags = merge(
  #   var.tags,
  #   {
  #     Name = "pw-codeguru-association-${var.environment}"
  #   }
  # )
# Add this line to associate the IAM role
  # iam_role_arn = aws_iam_role.codeguru_review_role.arn

# timeouts {
#     create = "30m"
#   }

# }

# CodeBuild project for EKS deployment
resource "aws_codebuild_project" "pw-contact" {
  name         = "pw-cb-${var.project_name}-deploy-${var.environment}"
  description  = "Deploy to EKS cluster for ${var.environment} with CodeGuru analysis"
  service_role = var.codebuild_infra_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = "pw-eks-cluster-${var.environment}"
    }

    environment_variable {
      name  = "EKS_CLUSTER_REGION"
      value = var.eks_cluster_region
    }

    environment_variable {
      name  = "DEPLOYMENT_ROLE_ARN"
      value = var.deployment_role_arn
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }

    environment_variable {
      name  = "CODEGURU_PROFILER_GROUP_NAME"
      value = "${var.project_name}-${var.environment}"
    }

    environment_variable {
      name  = "ENABLE_CODEGURU_PROFILER"
      value = "true"
    }

    # environment_variable {
    #   name  = "CODEGURU_REPOSITORY_ARN"
    #   value = aws_codegurureviewer_repository_association.example.arn
    # }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = "/aws/codebuild/pw-cb-${var.project_name}-apply-${var.environment}"
      stream_name = "pw-cb-${var.project_name}-apply-${var.environment}-log-stream"
    }

    s3_logs {
      status              = "ENABLED"
      location            = "${var.build-logs_bucket_name}/pw-cb-${var.project_name}-apply-${var.environment}/codebuild-logs"
      encryption_disabled = false
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "pw-cb-${var.project_name}-deploy-${var.environment}"
    }
  )
}







# CodeBuild Project for CodeGuru Review
resource "aws_codebuild_project" "codeguru_review" {
  name         = "pw-cb-${var.project_name}-codeguru-review-${var.environment}"
  description  = "CodeGuru Review for ${var.environment}"
  service_role = var.codebuild_infra_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ENABLE_CODEGURU_REVIEW"
      value = "true"
    }

    environment_variable {
      name  = "BRANCH"
      value = var.branch
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-codeguru.yml"  # Reference the external buildspec file
  }

  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = "/aws/codebuild/pw-cb-${var.project_name}-codeguru-review-${var.environment}"
      stream_name = "pw-cb-${var.project_name}-codeguru-review-${var.environment}-log-stream"
    }

    s3_logs {
      status              = "ENABLED"
      location            = "${var.build-logs_bucket_name}/pw-cb-${var.project_name}-codeguru-review-${var.environment}/codebuild-logs"
      encryption_disabled = false
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "pw-cb-${var.project_name}-codeguru-review-${var.environment}"
    }
  )
}


#####################################################################################################

resource "aws_codebuild_project" "codeguru_security" {
  name            = "pw-CodeGuruSecurity"
  description     = "AWS CodeBuild project for CodeGuru Security"

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-security.yml"  # Change if using an inline buildspec
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

  }

  # environment {
  #   type                = "LINUX_CONTAINER"
  #   image               = "public.ecr.aws/l6c8c5q3/codegurusecurity-actions-public:latest"
  #   compute_type        = "BUILD_GENERAL1_SMALL"
  #   image_pull_credentials_type = "CODEBUILD"  # If using a private registry, update this with "SERVICE_ROLE" and add credentials

  #   # environment_variables {
  #   #   name  = "ENV_VAR_NAME"  # Replace with your actual environment variables
  #   #   value = "ENV_VAR_VALUE"
  #   # }

  #   privileged_mode = false  # Set to true if your build requires Docker-in-Docker
  # }

  service_role = var.codebuild_infra_role_arn

  logs_config {
    cloudwatch_logs {
      group_name         = "/aws/codebuild/CodeGuruSecurity"
      stream_name        = "codeguru_security_logs"
      status             = "ENABLED"
    }

    s3_logs {
      status            = "ENABLED"
      location          = "${var.build-logs_bucket_name}/pw-cb-${var.project_name}-codeguru-security-${var.environment}/codebuild-logs"  # Replace with your S3 bucket path
      encryption_disabled = false
    }
  }

  tags = {
    Environment = "Production"
    Project     = "CodeGuruSecurity"
  }
}

####################################################################################################

# CodePipeline configuration
resource "aws_codepipeline" "pw-contact" {
  name     = "pw-cp-${var.project_name}-${var.environment}"
  role_arn = var.codepipeline_infra_role_arn

  artifact_store {
    location = var.artifact_bucket_name
    type     = "S3"
  }

  tags = merge(
    var.tags,
    {
      Name = "pw-cp-${var.project_name}-${var.environment}"
    }
  )

  # Source stage from Bitbucket
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.bitbucket_connection_arn
        FullRepositoryId = "${var.bitbucket_account}/${var.bitbucket_repo_name}"
        BranchName       = var.branch
        DetectChanges    = true
      }
    }
  }

  # CodeGuru Review stage
  stage {
    name = "CodeReview"

    action {
      name             = "CodeGuru-Review"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codeguru_review.name
      }
    }
  }

  # CodeGuru Review stage

  stage {
    name = "Codesecurity"

    action {
      name             = "CodeGuru-security"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codeguru_security.name
      }
    }
  }


  # Deploy stage to EKS
  stage {
    name = "Deploy"

    action {
      name            = "Deploy-to-EKS"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.pw-contact.name
      }
    }
  }
}

# Webhook configuration for triggering the pipeline on Bitbucket PR merge
resource "aws_codepipeline_webhook" "bitbucket_webhook" {
  name            = "pw-webhook-${var.project_name}-${var.environment}"
  authentication  = "UNAUTHENTICATED"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.pw-contact.name

  filter {
    json_path    = "$.pullrequest.state"
    match_equals = "MERGED"
  }

  filter {
    json_path    = "$.pullrequest.destination.branch.name"
    match_equals = join("|", ["demo", "uat", "main"])
  }

  tags = merge(
    var.tags,
    {
      name = "pw-webhook-${var.project_name}-${var.environment}"
    }
  )
}
