variable "s3_bucket_name" {
  description = "S3 bucket to store recipe and artifact files"
  type        = string
}

variable "recipe_file" {
  description = "Path to the recipe file"
  type        = string
}

variable "artifacts" {
  description = "List of artifact files"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "assume_role_arn" {
  description = "ARN of the IAM role to assume for AWS CLI commands"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "component_name" {
  description = "Name of the Greengrass component"
  type        = string
}
