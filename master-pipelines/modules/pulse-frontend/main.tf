# CodeBuild project for S3 deployment
resource "aws_codebuild_project" "pulse" {
  name         = "pw-cb-${var.project_name}-deploy-${var.environment}"
  description  = "Deploy pulse to S3 bucket for ${var.environment}"
  service_role = var.codebuild_infra_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "S3_BUCKET_NAME"
      value = "pw-pulse-${var.environment}"
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }

    environment_variable {
      name  = "DEPLOYMENT_ROLE_ARN"
      value = var.deployment_role_arn
    }

    environment_variable {
      name  = "CONFIGURATION"
      value = var.configuration
    }
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
      Name = "pw-cb-${var.project_name}-${var.environment}"
    }
  )
}

# CodePipeline
resource "aws_codepipeline" "pulse" {
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
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.pulse.name
      }
    }
  }

}

# Configure the webhook for the pipeline
resource "aws_codepipeline_webhook" "bitbucket_webhook" {
  name            = "pulse-webhook-${var.project_name}-${var.environment}"
  authentication  = "UNAUTHENTICATED"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.pulse.name

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
  name            = "pulse-webhook-${var.project_name}-${var.environment}"
    }
  )
}