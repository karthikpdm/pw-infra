variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "env" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

# variable "codebuild_role_name" {
#   description = "The name of the CodeBuild IAM role"
#   type        = string
# }

# Add these only if needed in your Terraform code
variable "assume_role_arn" {
  description = "The ARN of the IAM role to assume"
  type        = string
  default     = ""
}

variable "s3_bucket_id" {
  description = "The ID of the S3 bucket"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}


variable "cloudfront_alias" {
  description = "Alternate domain name (CNAME) for CloudFront distribution"
  type        = string
  default     = "static.dev.puritysaite.com"  # Set your default domain name
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}
