# Variables for CodeBuild and CodePipeline

variable "project_name" {
  description = "Project name for CodeBuild and CodePipeline"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
}


variable "deployment_role_arn" {
  description = "ARN of the IAM role for ECS deployments"
  type        = string
}

variable "codebuild_infra_role_arn" {
  description = "ARN of the IAM role used by CodeBuild"
  type        = string
}

variable "codepipeline_infra_role_arn" {
  description = "ARN of the IAM role used by CodePipeline"
  type        = string
}

variable "artifact_bucket_name" {
  description = "S3 bucket name for storing pipeline artifacts"
  type        = string
}

variable "build-logs_bucket_name" {
  description = "S3 bucket name for storing build logs"
  type        = string
}


variable "branch" {
  description = "Branch name in the CodeCommit repository"
  type        = string
}

variable "bitbucket_connection_arn" {
  description = "ARN of the Bitbucket connection for CodePipeline"
  type        = string
}

variable "bitbucket_account" {
  description = "Bitbucket account ID"
  type        = string
}

variable "bitbucket_repo_name" {
  description = "Bitbucket repository name"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}