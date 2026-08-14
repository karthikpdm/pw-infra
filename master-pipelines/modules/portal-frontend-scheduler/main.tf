##############################################################################################

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["pw-private-subnet-devops-az1", "pw-private-subnet-devops-az2"]
  }
}

data "aws_security_group" "devops" {
  id = "sg-0ff2b49fe7588bc79"
}

# ##############################################################################################
# ####################### CodeBuild Project for CodeGuru Review  ################################
# ##############################################################################################

# resource "aws_codebuild_project" "codeguru_review" {
#   name         = "pw-cb-${var.project_name}-codeguru-review-${var.environment}"
#   description  = "CodeGuru Review for ${var.environment}"
#   service_role = var.codebuild_infra_role_arn

#   artifacts {
#     type = "CODEPIPELINE"
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"

#     environment_variable {
#       name  = "ENABLE_CODEGURU_REVIEW"
#       value = "true"
#     }

#     environment_variable {
#       name  = "BRANCH"
#       value = var.branch
#     }

#      environment_variable {
#       name  = "AMPLIFY_APP_NAME"
#       value = "pw-amplify-scheduler-${var.environment}"
#     }

#     environment_variable {
#       name = "REPOSITORY_NAME"
#       value = var.bitbucket_repo_name
#     }
#   }

  

#   source {
#     type      = "CODEPIPELINE"
#     buildspec = "buildspecs/buildspec-codeguru-review.yml"  # Reference the external buildspec file
#   }

#   logs_config {
#     cloudwatch_logs {
#       status      = "ENABLED"
#       group_name  = "/aws/codebuild/pw-cb-${var.project_name}-codeguru-review-${var.environment}"
#       stream_name = "pw-cb-${var.project_name}-codeguru-review-${var.environment}-log-stream"
#     }

#     s3_logs {
#       status              = "ENABLED"
#       location            = "${var.build-logs_bucket_name}/pw-cb-${var.project_name}-codeguru-review-${var.environment}/codebuild-logs"
#       encryption_disabled = false
#     }
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-cb-${var.project_name}-codeguru-review-${var.environment}"
#     }
#   )
# }


##############################################################################################
####################### CodeBuild Project for CodeGuru Security  ################################
##############################################################################################

resource "aws_codebuild_project" "codeguru_security" {
  name            = "pw-cb-${var.project_name}-codeguru-security-${var.environment}"
  description     = "AWS CodeBuild project for CodeGuru Security"

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/buildspec-codeguru-security.yml"  # Change if using an inline buildspec
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true  # Enable privileged mode for Docker builds

    environment_variable {
      name  = "BRANCH"
      value = var.branch
    }

    environment_variable {
      name = "REPOSITORY_NAME"
      value = var.bitbucket_repo_name
    }

  }

  service_role = var.codebuild_infra_role_arn

  logs_config {
    cloudwatch_logs {
      group_name         = "/aws/codebuild/pw-cb-${var.project_name}-codeguru-Security-${var.environment}"
      stream_name        = "pw-cb-${var.project_name}-Codeguru-Security-${var.environment}-log-stream"
      status             = "ENABLED"
    }

    s3_logs {
      status            = "ENABLED"
      location          = "${var.build-logs_bucket_name}/pw-cb-${var.project_name}-codeguru-security-${var.environment}/codebuild-logs"  # Replace with your S3 bucket path
      encryption_disabled = false
    }
  }

   tags = merge(
    var.tags,
    {
      Name = "pw-cb-${var.project_name}-codeguru-security-${var.environment}"
    }
  )
}

########################################################################################33

# CodeBuild project for amplify deployment
resource "aws_codebuild_project" "pw-contact" {
  name         = "pw-cb-${var.project_name}-deploy-${var.environment}"
  description  = "Deploy to amplify for ${var.environment}"
  service_role = var.codebuild_infra_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true  # Enable privileged mode for Docker builds

     environment_variable {
      name  = "AMPLIFY_APP_NAME"
      value = "pw-amplify-${var.environment}-scheduler-app"
    }


    environment_variable {
      name  = "DEPLOYMENT_ROLE_ARN"
      value = var.deployment_role_arn
    }

    environment_variable {
      name  = "BRANCH_NAME"
      value = var.branch
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }
  }

  # vpc_config {
  #   vpc_id             = "vpc-061ad18ab42e4e486"  # Using your existing VPC ID directly
  #   subnets            = data.aws_subnets.private.ids
  #   security_group_ids = [data.aws_security_group.devops.id]
  # }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/buildspec.yml"
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
  name         = "pw-cb-${var.project_name}-deploy-${var.environment}"
    }
  )
}

###############################################################################################
###################################### CodePipeline ###########################################
############################################################################################3
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
      name = "pw-cp-${var.project_name}-${var.environment}"
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


  # # CodeGuru Review stage
  # stage {
  #   name = "CodeReview"

  #   action {
  #     name             = "CodeGuru-Review"
  #     category         = "Build"
  #     owner            = "AWS"
  #     provider         = "CodeBuild"
  #     input_artifacts  = ["source_output"]
  #     version          = "1"

  #     configuration = {
  #       ProjectName = aws_codebuild_project.codeguru_review.name
  #     }
  #   }
  # }

  # CodeGuru security stage

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

  stage {
    name = "Deploy"

    action {
      name            = "Deploy-to-AMPLIFY"
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
    match_equals = join("|", ["dev", "uat", "main"])
  }

  tags = merge(
    var.tags,
    {
      name            = "pw-webhook-${var.project_name}-${var.environment}"
    }
  )
}