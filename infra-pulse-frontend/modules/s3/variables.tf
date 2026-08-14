variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "env" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

# variable "cloudfront_distribution_arn" {
#   description = "The environment (e.g., dev, prod)"
#   type        = string
# }

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}

# variable "cloudfront_oai_iam_arn" {
#   description = "CloudFront distribution ARN"
#   type        = string
# }

# variable "cloudfront_distribution_arn" {
#   description = "ARN of the CloudFront distribution"
#   type        = string
# }

variable "cloudfront_full_arn" {
  type        = string
  description = "Full ARN of the CloudFront distribution"
}

# variable "cloudfront-oai-arn" {
#   description = "A map of tags to apply to the resources."
#   type        = string
# }