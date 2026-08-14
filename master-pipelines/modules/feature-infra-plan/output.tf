# Outputs

output "codepipeline_arn" {
  description = "ARN of the created CodePipeline"
  value       = aws_codepipeline.plan_pipeline.arn
}

output "codepipeline_name" {
  description = "Name of the created CodePipeline"
  value       = aws_codepipeline.plan_pipeline.name
}

output "codebuild_project_name" {
  description = "Name of the CodeBuild project for Terraform plan"
  value       = aws_codebuild_project.terraform_plan.name
}

output "codebuild_project_arn" {
  description = "ARN of the CodeBuild project for Terraform plan"
  value       = aws_codebuild_project.terraform_plan.arn
}

output "webhook_url" {
  description = "URL of the webhook created for the pipeline"
  value       = aws_codepipeline_webhook.bitbucket_webhook.url
}