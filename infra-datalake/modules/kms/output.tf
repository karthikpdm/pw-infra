

# Output the key ID and ARN
output "datalake_kms_key_id" {
  value = aws_kms_key.datalake_kms_encryption.id
  description = "The ID of the KMS key"
}

output "datalake_kms_key_arn" {
  value = aws_kms_key.datalake_kms_encryption.arn
  description = "The ARN of the KMS key"
}