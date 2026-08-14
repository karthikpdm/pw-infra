# variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, uat, prod)"
  type        = string
}

variable "codebuild_infra_role_arn" {
  description = "ARN of the IAM role for CodeBuild"
  type        = string
}

variable "build-logs_bucket_name" {
  description = "Name of the S3 bucket for build logs"
  type        = string
}

variable "codepipeline_infra_role_arn" {
  description = "ARN of the IAM role for CodePipeline"
  type        = string
}

variable "artifact_bucket_name" {
  description = "Name of the S3 bucket for storing pipeline artifacts"
  type        = string
}

variable "bitbucket_connection_arn" {
  description = "ARN of the CodeStar connection to Bitbucket"
  type        = string
}

variable "bitbucket_account" {
  description = "Bitbucket account name"
  type        = string
}

variable "bitbucket_repo_name" {
  description = "Name of the Bitbucket repository"
  type        = string
}

variable "branch" {
  description = "Branch name to use for the source stage"
  type        = string
}

variable "TFVARS_FILE" {
  description = "Name of the Terraform variables file to use"
  type        = string
  default     = "terraform.tfvars"
}
variable "aws_region" {
  description = "Name of the Terraform variables file to use"
  type        = string
  default     = "terraform.tfvars"
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}