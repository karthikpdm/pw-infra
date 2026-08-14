output "identity_pool_id" {
  description = "The ID of the Cognito Identity Pool"
  value       = aws_cognito_identity_pool.main.id
}

output "identity_pool_role_arn" {
  description = "The ARN of the IAM role attached to the Identity Pool"
  value       = var.identity_pool_role_name_arn
}
