output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

# output "cloudwatch_logs_policy_arn" {
#   description = "ARN of the CloudWatch Logs policy"
#   value       = aws_iam_policy.cloudwatch_logs_full_access_policy.arn
# }

output "dynamodb_policy_arn" {
  description = "ARN of the DynamoDB policy"
  value       = aws_iam_policy.dynamodb.arn
}
