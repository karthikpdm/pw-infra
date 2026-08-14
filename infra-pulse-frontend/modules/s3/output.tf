output "bucket_id" {
  value = aws_s3_bucket.frontend.id
}

output "bucket_arn" {
  value = aws_s3_bucket.frontend.arn
}

output "bucket_domain_name" {
  value = aws_s3_bucket.frontend.bucket_regional_domain_name
}

output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = aws_kms_key.s3_encryption_key.arn
}