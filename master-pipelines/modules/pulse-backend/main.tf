# CodeBuild Project for ECS Deployment
resource "aws_codebuild_project" "ecs_build_project" {
  name         = "pw-cb-${var.project_name}-${var.environment}"
  description   = "Build project for ECS deployment in ${var.environment} environment"
  service_role = var.codebuild_infra_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "ENV"
      value = var.environment
    }

    environment_variable {
      name  = "ECS_CLUSTER_NAME"
      value = "pw-ecs-cluster-pulse-${var.environment}"
    }

    environment_variable {
      name  = "ECS_TASK_DEFINITION"
      value = "pw-pulse_Task_Definitions-${var.environment}"
    }

    environment_variable {
      name  = "DEPLOYMENT_ROLE_ARN"
      value = var.deployment_role_arn
    }

    environment_variable {
      name  = "ECS_SERVICE_NAME"
      value = "pw-pulse-service-${var.environment}"
    }

    environment_variable {
      name  = "ECS_TASK_DEF_JSON"
      value = "ecs-task-def-${var.environment}.json"
    }

    
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec/buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = "/aws/codebuild/pw-cb-${var.project_name}-${var.environment}"
      stream_name = "pw-cb-${var.project_name}-${var.environment}-log-stream"
    }

    s3_logs {
      status              = "ENABLED"
      location            = "${var.build-logs_bucket_name}/pw-cb-${var.project_name}-${var.environment}/codebuild-logs"
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







# CodePipeline for ECS Deployment
resource "aws_codepipeline" "ecs_pipeline" {
  name     = "pw-cp-${var.project_name}-${var.environment}"
  role_arn = var.codepipeline_infra_role_arn

  artifact_store {
    type     = "S3"
    location = var.artifact_bucket_name
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
      output_artifacts = ["SourceOutput"]

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
      name            = "BuildAction"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]

      configuration = {
        ProjectName = aws_codebuild_project.ecs_build_project.name
      }
    }
  }

  
}


# Configure the webhook for the pipeline
resource "aws_codepipeline_webhook" "bitbucket_webhook" {
  name            = "pulse-webhook-${var.project_name}-${var.environment}"
  authentication  = "UNAUTHENTICATED"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.ecs_pipeline.name

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