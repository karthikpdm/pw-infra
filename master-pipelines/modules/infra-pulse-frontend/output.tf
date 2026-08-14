# outputs.tf

output "pw_codebuild_infra_terraform_plan_name" {
  description = "The name of the CodeBuild project for Terraform plan."
  value       = aws_codebuild_project.terraform_plan.name
}

output "pw_codebuild_infra_terraform_apply_name" {
  description = "The name of the CodeBuild project for Terraform apply."
  value       = aws_codebuild_project.terraform_apply.name
}

output "pw_codebuild_infra_terraform_plan_arn" {
  description = "The name of the CodeBuild project for Terraform plan."
  value       = aws_codebuild_project.terraform_plan.arn
}

output "pw_codebuild_infra_terraform_apply_arn" {
  description = "The name of the CodeBuild project for Terraform apply."
  value       = aws_codebuild_project.terraform_apply.arn
}


output "sns_topic_infra_arn" {
  description = "The ARN of the SNS topic for manual approval."
  value       = aws_sns_topic.manual_approval.arn
}

output "codepipeline_name" {
  description = "The name of the CodePipeline."
  value       = aws_codepipeline.multibranch_pipeline.name
}

# output "codepipeline_webhook_name" {
#   description = "The name of the CodePipeline webhook, if enabled."
#   value       = aws_codepipeline_webhook.bitbucket_webhook.name
#   depends_on  = [aws_codepipeline_webhook.bitbucket_webhook]
# }
