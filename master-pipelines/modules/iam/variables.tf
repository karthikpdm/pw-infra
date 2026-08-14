variable "codebuild_infra_role_name" {
  description = "The name of the IAM role for CodeBuild."
  type        = string
}

variable "codepipeline_infra_role_name" {
  description = "The name of the IAM role for CodePipeline."
  type        = string
}

variable "codeguru_reviewer_role_name" {
  description = "The name of the IAM role for CodePipeline."
  type        = string
}

variable "artifact_bucket_arn" {
  description = "The ARN of the S3 bucket used for storing artifacts."
  type        = string
}

variable "build_logs_store_arn" {
  description = "The ARN of the S3 bucket used for storing build logs."
  type        = string
}

variable "dev_account_role_arn" {
  description = "The ARN of the IAM role in the development account that CodeBuild can assume."
  type        = string
}

variable "uat_account_role_arn" {
  description = "The ARN of the IAM role in the UAT account that CodeBuild can assume."
  type        = string
}

variable "prod_account_role_arn" {
  description = "The ARN of the IAM role in the production account that CodeBuild can assume."
  type        = string
  default     = ""  # Default value can be set as an empty string or a placeholder if not used.
}

variable "pw_codebuild_infra_terraform_plan_arn" {
  description = "The ARN of the CodeBuild project for Terraform plan."
  type        = string
}

variable "pw_codebuild_infra_terraform_apply_arn" {
  description = "The ARN of the CodeBuild project for Terraform apply."
  type        = string
}

variable "aws_sns_topic_manual_approval_arn" {
  description = "The ARN of the SNS topic used for manual approval."
  type        = string
}

variable "bitbucket_connection_arn" {
  description = "The ARN of the Bitbucket connection used in CodePipeline."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}

