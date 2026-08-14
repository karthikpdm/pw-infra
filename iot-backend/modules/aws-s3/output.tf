output "s3_ml_domain_name"{
    value = aws_cloudfront_distribution.s3_distribution.id
}