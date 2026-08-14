# outputs.tf
output "lambda_security_group_id" {
  description = "ID of the Lambda security group"
  value       = aws_security_group.lambda_sg.id
}

output "lambda_security_group_name" {
  description = "Name of the Lambda security group"
  value       = aws_security_group.lambda_sg.name
}

output "lambda_security_group_arn" {
  description = "ARN of the Lambda security group"
  value       = aws_security_group.lambda_sg.arn
}

# outputs.tf
output "glue_security_group_id" {
  description = "ID of the Lambda security group"
  value       = aws_security_group.glue_sg.id
}

output "glue_security_group_name" {
  description = "Name of the Lambda security group"
  value       = aws_security_group.glue_sg.name
}

output "glue_security_group_arn" {
  description = "ARN of the Lambda security group"
  value       = aws_security_group.glue_sg.arn
}


