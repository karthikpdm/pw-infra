# output "cloudwatch_log_group_name" {
#   description = "Name of the CloudWatch Log Group for ECS"
#   value       = aws_cloudwatch_log_group.ecs_logss.name
# }

output "kms_key_id" {
  description = "ID of the KMS Key used for ECS logs encryption"
  value       = aws_kms_key.ecs.id
}

output "ecs_cluster_id" {
  description = "ID of the ECS Cluster"
  value       = aws_ecs_cluster.ecs_cluster.id
}
# Add this output to expose the KMS key ARN
output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = aws_kms_key.ecs.arn
}

# output "ecs_task_definition_arn" {
#   description = "ARN of the ECS Task Definition"
#   value       = aws_ecs_task_definition.pulse_Task_Definitions.arn
# }

# output "ecs_service_name" {
#   description = "Name of the ECS Service"
#   value       = aws_ecs_service.pulse_ecs_service.name
# }

# output "cloudwatch_log_group_pulse_name" {
#   description = "Name of the CloudWatch Log Group for ECS Pulse"
#   value       = aws_cloudwatch_log_group.ecs_pulse_log_groups.name
# }
