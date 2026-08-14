output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_role_name" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.name
}

output "lambda_role_id" {
  description = "The ID of the Lambda role"
  value       = aws_iam_role.lambda_role.id
}

output "glue_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.glue_role.arn
}

output "glue_role_name" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.glue_role.name
}

output "step_function_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.step_function_role.arn
}

output "step_function_role_name" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.step_function_role.name
}