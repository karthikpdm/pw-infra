
# ##############################################################################################
# ####################### CodeBuild Project for CodeGuru Security  ################################
# ##############################################################################################

# resource "aws_codebuild_project" "codeguru_security" {
#   name            = "pw-cb-${var.project_name}-codeguru-security-${var.environment}"
#   description     = "AWS CodeBuild project for CodeGuru Security"

#   source {
#     type      = "CODEPIPELINE"
#     buildspec = "buildspecs/buildspec-codeguru-security.yml"  # Change if using an inline buildspec
#   }

#   artifacts {
#     type = "CODEPIPELINE"
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"
#     privileged_mode             = true  # Enable privileged mode for Docker builds

#     environment_variable {
#       name  = "BRANCH"
#       value = var.branch
#     }

#     environment_variable {
#       name = "REPOSITORY_NAME"
#       value = var.bitbucket_repo_name
#     }

#   }

#   service_role = var.codebuild_infra_role_arn

#   logs_config {
#     cloudwatch_logs {
#       group_name         = "/aws/codebuild/pw-cb-${var.project_name}-codeguru-Security-${var.environment}"
#       stream_name        = "pw-cb-${var.project_name}-Codeguru-Security-${var.environment}-log-stream"
#       status             = "ENABLED"
#     }

#     s3_logs {
#       status            = "ENABLED"
#       location          = "${var.build-logs_bucket_name}/pw-cb-${var.project_name}-codeguru-security-${var.environment}/codebuild-logs"  # Replace with your S3 bucket path
#       encryption_disabled = false
#     }
#   }

#    tags = merge(
#     var.tags,
#     {
#       Name = "pw-cb-${var.project_name}-codeguru-security-${var.environment}"
#     }
#   )
# }


##############################################################################################


# CodeBuild project for EKS deployment
resource "aws_codebuild_project" "pw-contact" {
  name         = "pw-cb-${var.project_name}-deploy-${var.environment}"
  description  = "Deploy to EKS cluster"
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
      value = var.eks_cluster_name
    }

    environment_variable {
      name  = "EKS_CLUSTER_REGION"
      value = var.eks_cluster_region
    }

    environment_variable {
      name  = "TARGET_ROLE_ARN"
      value = var.target_role_arn
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/buildspec_deploy.yml"
  }

  logs_config {
    cloudwatch_logs {
      status     = "ENABLED"
      group_name = "/aws/codebuild/pw-cb-${var.project_name}-deploy-${var.environment}"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "pw-cb-${var.project_name}-${var.environment}"
    }
  )
}

# CodePipeline
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
      Name = "pw-cp-${var.project_name}-plan-${var.environment}"
    }
  )

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

# Configure the webhook for the pipeline
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
    match_equals = join("|", ["dev", "uat", "prod"])
  }

  tags = merge(
    var.tags,
    {
      Name = "pw-webhook-${var.project_name}-${var.environment}"
    }
  )
}