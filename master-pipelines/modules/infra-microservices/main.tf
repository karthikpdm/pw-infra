# CodeBuild project for Terraform plan for the eks creation


# Data sources to fetch VPC, subnet and security group information
data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["pw-private-subnet-devops-az1", "pw-private-subnet-devops-az2"]
  }
}

data "aws_security_group" "devops" {
  id = "sg-0ff2b49fe7588bc79"
}


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

##############################################################################################

resource "aws_codebuild_project" "terraform_plan_eks" {
  name         = "pw-cb-eks-${var.project_name}-plan-${var.environment}"
  description  = "Terraform plan stage"
  service_role = var.codebuild_infra_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = "pw-eks-cluster-${var.environment}"
    }

    environment_variable {
      name  = "EKS_CLUSTER_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "DEPLOYMENT_ROLE_ARN"
      value = var.deployment_role_arn
    }
  }

  vpc_config {
    vpc_id             = "vpc-061ad18ab42e4e486"  # Using your existing VPC ID directly
    subnets            = data.aws_subnets.private.ids
    security_group_ids = [data.aws_security_group.devops.id]
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/buildspec_plan_eks.yml"
  }

  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = "/aws/codebuild/pw-cb-eks-${var.project_name}-plan-${var.environment}"
      stream_name = "pw-cb-eks-${var.project_name}-plan-${var.environment}-log-stream"
    }

    s3_logs {
      status              = "ENABLED"
      location            = "${var.build-logs_bucket_name}/pw-cb-eks-${var.project_name}-plan-${var.environment}/codebuild-logs"
      encryption_disabled = false
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "pw-cb-${var.project_name}-eks-plan-${var.environment}"
    }
  )
}

# resource "aws_codebuild_project" "terraform_plan_eks" {
#   name         = "pw-cb-eks-${var.project_name}-plan-${var.environment}"
#   description  = "Terraform plan stage"
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
#       name  = "EKS_CLUSTER_NAME"
#       value = "pw-eks-cluster-${var.environment}"
#     }

#     environment_variable {
#       name  = "EKS_CLUSTER_REGION"
#       value = var.aws_region
#     }

#     environment_variable {
#       name  = "DEPLOYMENT_ROLE_ARN"
#       value = var.deployment_role_arn
#     }

    

#   }


#   source {
#     type      = "CODEPIPELINE"
#     buildspec = "buildspecs/buildspec_plan_eks.yml"
#   }

#   logs_config {
#     cloudwatch_logs {
#       status      = "ENABLED"
#       group_name  = "/aws/codebuild/pw-cb-eks-${var.project_name}-plan-${var.environment}"
#       stream_name = "pw-cb-eks-${var.project_name}-plan-${var.environment}-log-stream"
#     }

#     s3_logs {
#       status              = "ENABLED"
#       location            = "${var.build-logs_bucket_name}/pw-cb-eks-${var.project_name}-plan-${var.environment}/codebuild-logs"
#       encryption_disabled = false
#     }
#   }
#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-cb-${var.project_name}-eks-plan-${var.environment}"
#     }
#   )
# }

##############################################################################################

# CodeBuild project for Terraform apply
resource "aws_codebuild_project" "terraform_apply_eks" {
  name         = "pw-cb-eks-${var.project_name}-apply-${var.environment}"
  description  = "Terraform apply stage"
  service_role = var.codebuild_infra_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  vpc_config {
    vpc_id             = "vpc-061ad18ab42e4e486"  # Using your existing VPC ID directly
    subnets            = data.aws_subnets.private.ids
    security_group_ids = [data.aws_security_group.devops.id]
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/buildspec_apply_eks.yml"
  }

  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = "/aws/codebuild/pw-cb-eks-${var.project_name}-apply-${var.environment}"
      stream_name = "pw-cb-eks-${var.project_name}-apply-${var.environment}-log-stream"
    }

    s3_logs {
      status              = "ENABLED"
      location            = "${var.build-logs_bucket_name}/pw-cb-eks-${var.project_name}-apply-${var.environment}/codebuild-logs"
      encryption_disabled = false
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "pw-cb-${var.project_name}-eks-apply-${var.environment}"
    }
  )
}

##############################################################################################3

# CodeBuild project for Terraform plan
resource "aws_codebuild_project" "terraform_plan" {
  name         = "pw-cb-${var.project_name}-plan-${var.environment}"
  description  = "Terraform plan stage"
  service_role = var.codebuild_infra_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = "pw-eks-cluster-${var.environment}"
    }

    environment_variable {
      name  = "EKS_CLUSTER_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "DEPLOYMENT_ROLE_ARN"
      value = var.deployment_role_arn
    }

  }

   vpc_config {
    vpc_id             = "vpc-061ad18ab42e4e486"  # Using your existing VPC ID directly
    subnets            = data.aws_subnets.private.ids
    security_group_ids = [data.aws_security_group.devops.id]
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
      name         = "pw-cb-${var.project_name}-plan-${var.environment}"
    }
  )
}

# CodeBuild project for Terraform apply
resource "aws_codebuild_project" "terraform_apply" {
  name         = "pw-cb-${var.project_name}-apply-${var.environment}"
  description  = "Terraform apply stage"
  service_role = var.codebuild_infra_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  vpc_config {
    vpc_id             = "vpc-061ad18ab42e4e486"  # Using your existing VPC ID directly
    subnets            = data.aws_subnets.private.ids
    security_group_ids = [data.aws_security_group.devops.id]
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/buildspec_apply.yml"
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
      Name = "pw-cb-${var.project_name}-apply-${var.environment}"
    }
  )
}

# SNS Topic for manual approval
resource "aws_sns_topic" "manual_approval" {
  name = "pw-sns-${var.project_name}-apply-${var.environment}-tf-approval"

  tags = merge(
    var.tags,
    {
       name = "pw-sns-${var.project_name}-apply-${var.environment}-tf-approval"

    }
  )
}


##############################################################################################
# CodePipeline
resource "aws_codepipeline" "multibranch_pipeline" {
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

  ##############################################################################################

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


  ############################################################################
  #for creating the eks cluster

  stage {
    name = "EKS-Plan"

    action {
      name             = "Terraform-Plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["plan_output_eks"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_plan_eks.name
        EnvironmentVariables = jsonencode([
          {
            name  = "ENV_DIR"
            value = "environments/${var.environment}"
            type  = "PLAINTEXT"
          },
          {
            name  = "TFVARS_FILE"
            value = var.TFVARS_FILE
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "EKS-Approval"

    action {
      name     = "Manual-Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        NotificationArn = aws_sns_topic.manual_approval.arn
        CustomData      = "Please review the Terraform plan and approve if changes are acceptable."

      }
    }
  }

  stage {
    name = "EKS-Apply"

    action {
      name            = "Terraform-Apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output", "plan_output_eks"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_apply_eks.name
        PrimarySource = "source_output"
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


#########################################################################################

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
          },
          {
            name  = "TFVARS_FILE"
            value = var.TFVARS_FILE
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "Approval"

    action {
      name     = "Manual-Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        NotificationArn = aws_sns_topic.manual_approval.arn
        CustomData      = "Please review the Terraform plan and approve if changes are acceptable."

      }
    }
  }

  stage {
    name = "Apply"

    action {
      name            = "Terraform-Apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output", "plan_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_apply.name
        PrimarySource = "source_output"
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
  target_pipeline = aws_codepipeline.multibranch_pipeline.name

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