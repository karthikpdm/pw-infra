output "codebuild_role_arn" {
  description = "The ARN of the IAM role for CodeBuild."
  value       = aws_iam_role.codebuild_role.arn
}

output "codepipeline_role_arn" {
  description = "The ARN of the IAM role for CodePipeline."
  value       = aws_iam_role.codepipeline_role.arn
}

output "pw_codebuild_infra_terraform_plan_arn" {
  description = "The ARN of the CodeBuild project for Terraform plan."
  value       = var.pw_codebuild_infra_terraform_plan_arn
}

output "pw_codebuild_infra_terraform_apply_arn" {
  description = "The ARN of the CodeBuild project for Terraform apply."
  value       = var.pw_codebuild_infra_terraform_apply_arn
}

output "aws_sns_topic_manual_approval_arn" {
  description = "The ARN of the SNS topic used for manual approval."
  value       = var.aws_sns_topic_manual_approval_arn
}

output "bitbucket_connection_arn" {
  description = "The ARN of the Bitbucket connection used in CodePipeline."
  value       = var.bitbucket_connection_arn
}
