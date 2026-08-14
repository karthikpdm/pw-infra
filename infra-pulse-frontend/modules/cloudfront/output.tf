output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront Distribution"
  value       = aws_cloudfront_distribution.frontend.arn
}

output "distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.id
}

output "distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.arn
}

output "distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "origin_access_control_id" {
  description = "The ID of the Origin Access Control"
  value       = aws_cloudfront_origin_access_control.s3_oac.id
}

output "cloudfront_full_arn" {
  value = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.frontend.id}"
}

# output "cloudfront_oai_iam_arn" {
#   description = "The IAM ARN of the CloudFront Origin Access Identity"
#   value       = aws_cloudfront_origin_access_identity.oai.iam_arn
# }

# output "cloudfront_oai_iam_arn" {
#   description = "The IAM ARN of the CloudFront Origin Access Identity"
#   value       = aws_cloudfront_origin_access_control.oac.iam_arn
# }

# # Output the ARN of the OAC
# output "cloudfront_oac_arn" {
#   value       = aws_cloudfront_origin_access_control.oac.arn
#   description = "ARN of the CloudFront Origin Access Control for ${var.env} environment"
# }


# Output the ARN of the OAC
# output "cloudfront_oac_arn" {
#   value       = aws_cloudfront_origin_access_control.oac.arn
#   description = "ARN of the CloudFront Origin Access Control for ${var.env} environment"
# }

