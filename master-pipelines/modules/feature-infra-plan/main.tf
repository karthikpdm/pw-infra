# CodeBuild project for Terraform plan
resource "aws_codebuild_project" "terraform_plan" {
  name         = "pw-cb-${var.project_name}-plan"
  description  = "Terraform plan stage"
  service_role = var.codebuild_infra_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/buildspec_plan.yml"
  }

  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = "/aws/codebuild/pw-cb-${var.project_name}-plan-${var.environment}"
      stream_name = "pw-cb-${var.project_name}-plan-${var.environment}-log-stream"
    }

    s3_logs {
      status              = "ENABLED"
      location            = "${var.build-logs_bucket_name}/pw-cb-${var.project_name}-plan-${var.environment}/codebuild-logs"
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
resource "aws_codepipeline" "plan_pipeline" {
  name     = "pw-cp-${var.project_name}-plan"
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
    name = "Plan"

    action {
      name             = "Terraform-Plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["plan_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_plan.name
        EnvironmentVariables = jsonencode([
          {
            name  = "ENV_DIR"
            value = "environments/${var.environment}"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }
}

# Configure the webhook for the pipeline
resource "aws_codepipeline_webhook" "bitbucket_webhook" {
  name            = "pw-webhook-${var.project_name}-${var.environment}"
  authentication  = "UNAUTHENTICATED"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.plan_pipeline.name

  filter {
    json_path    = "$.push.changes[0].new.type"
    match_equals = "branch"
  }

  filter {
    json_path    = "$.pullrequest.destination.branch.name"
    match_equals = join("|", ["feature-eks-karpenter", "feature1", "feature2"])
  }

  tags = merge(
    var.tags,
    {
      Name = "pw-webhook-${var.project_name}-${var.environment}"
    }
  )
}