# modules/kms/outputs.tf

output "key_arn" {
  value = aws_kms_key.pw-kms.arn
}

output "key_id" {
  value = aws_kms_key.pw-kms.key_id
}