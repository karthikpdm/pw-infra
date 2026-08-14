variable "identity_pool_name" {
  description = "The name of the Cognito Identity Pool"
  type        = string
}

variable "identity_pool_role_name_arn" {
  description = "The ARN of the pre-created IAM role for the Cognito Identity Pool"
  type        = string
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}
