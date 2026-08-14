variable "s3_bucket_domain_name" {
  description = "The domain name of the S3 bucket"
  type        = string
}

variable "s3_bucket_id" {
  description = "The ID of the S3 bucket"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  type        = string
}

variable "env" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "cloudfront_alias" {
  description = "Alternate domain name (CNAME) for CloudFront distribution"
  type        = string
  # default     = "static.dev.puritysaite.com"  # Set your default domain name
}
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}

variable "kms_key_id" {
  description = "Name of the KMS module where the key is defined"
  type        = string
  default     = "kms"  # Adjust this to match your module name
}