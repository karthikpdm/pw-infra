# Outputs





output "codebuild_project_arn" {
  description = "ARN of the CodeBuild project"
  value       = aws_codebuild_project.ecs_build_project.arn
}

output "codepipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.ecs_pipeline.name
}









# output "webhook_secret" {
#   description = "Secret token of the created webhook"
#   value       = aws_codepipeline_webhook.bitbucket_webhook.authentication_configuration[0].secret_token
#   sensitive   = true
# }