output "telemetry_lambda_role_arn" {
  description = "The ARN of the telemetry Lambda role"
  value       = aws_iam_role.telemetry_lambda_role.arn #length(aws_iam_role.telemetry_lambda_role) > 0 ? aws_iam_role.telemetry_lambda_role[0].arn : data.aws_iam_role.existing_telemetry_lambda_role.arn
}

output "telemetry_lambda_arn" {
  description = "The ARN of the telemetry Lambda function"
  value       = aws_lambda_function.telemetry_lambda.arn
}


output "telemetry_lambda_name" {
  description = "The name of the telemetry Lambda function"
  value       = aws_lambda_function.telemetry_lambda.function_name
}

output "lambda_arn_telemetry" {
  description = "The ARN of the telemetry Lambda function"
  value       = aws_lambda_function.telemetry_lambda.arn #length(aws_lambda_function.telemetry) > 0 ? aws_lambda_function.telemetry[0].arn : data.aws_lambda_function.existing_telemetry.arn
}

output "telemetry_lambda_policy_arn" {
  description = "ARN of the telemetry Lambda policy"
  value       = aws_iam_policy.telemetry_lambda_policy.arn
}

# output "enableEventbridge_role_arn" {
#   description = "The ARN of the enableEventbridge IAM role"
#   value       = aws_iam_role.enableEventbridge_role.arn
# }

# output "enableEventbridge_policy_arn" {
#   description = "The ARN of the enableEventbridge IAM policy"
#   value       = aws_iam_policy.enableEventbridge_policy.arn
# }

# output "enableEventbridge_lambda_arn" {
#   description = "The ARN of the enableEventbridge Lambda function"
#   value       = aws_lambda_function.enableEventbridge.arn
# }

# output "enableEventbridge_lambda_invoke_arn" {
#   description = "The Invoke ARN of the enableEventbridge Lambda function"
#   value       = aws_lambda_function.enableEventbridge.invoke_arn
# }

# output "enableEventbridge_lambda_name" {
#   description = "The name of the enableEventbridge Lambda function"
#   value       = aws_lambda_function.enableEventbridge.function_name
# }

