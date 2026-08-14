output "codebuild_project_name" {
  description = "Name of the created CodeBuild project"
  value       = aws_codebuild_project.pulse.name
}

output "codebuild_project_arn" {
  description = "ARN of the created CodeBuild project"
  value       = aws_codebuild_project.pulse.arn
}

output "codepipeline_name" {
  description = "Name of the created CodePipeline"
  value       = aws_codepipeline.pulse.name
}

output "codepipeline_arn" {
  description = "ARN of the created CodePipeline"
  value       = aws_codepipeline.pulse.arn
}

output "webhook_url" {
  description = "URL of the created webhook"
  value       = aws_codepipeline_webhook.bitbucket_webhook.url
}

