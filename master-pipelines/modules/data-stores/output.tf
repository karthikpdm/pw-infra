# Outputs

output "codebuild_project_name" {
  description = "Name of the created CodeBuild project"
  value       = aws_codebuild_project.pw-contact.name
}

output "codebuild_project_arn" {
  description = "ARN of the created CodeBuild project"
  value       = aws_codebuild_project.pw-contact.arn
}

output "codepipeline_name" {
  description = "Name of the created CodePipeline"
  value       = aws_codepipeline.pw-contact.name
}

output "codepipeline_arn" {
  description = "ARN of the created CodePipeline"
  value       = aws_codepipeline.pw-contact.arn
}

output "webhook_url" {
  description = "URL of the created webhook"
  value       = aws_codepipeline_webhook.bitbucket_webhook.url
  sensitive   = true
}

output "webhook_secret" {
  description = "Secret token of the created webhook"
  value       = aws_codepipeline_webhook.bitbucket_webhook.authentication_configuration[0].secret_token
  sensitive   = true
}