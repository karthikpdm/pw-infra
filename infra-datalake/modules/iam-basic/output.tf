# modules/iam-basic/outputs.tf
# Only output what's necessary for breaking the dependency cycle

output "lambda_role_arn" {
  description = "The ARN of the Lambda role"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_role_id" {
  description = "The ID of the Lambda role"
  value       = aws_iam_role.lambda_role.id
}

output "glue_role_arn" {
  description = "The ARN of the Glue role"
  value       = aws_iam_role.glue_role.arn
}

output "glue_role_name" {
  description = "The name of the Glue role"
  value       = aws_iam_role.glue_role.name
}

output "step_function_role_arn" {
  description = "The ARN of the Step Function role"
  value       = aws_iam_role.step_function_role.arn
}

output "step_function_role_name" {
  description = "The name of the Step Function role"
  value       = aws_iam_role.step_function_role.name
}