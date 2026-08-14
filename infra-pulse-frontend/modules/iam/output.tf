output "policy_arn" {
  description = "The ARN of the IAM policy created for S3 access"
  value       = aws_iam_policy.codebuild_s3_policy.arn
}
