variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "env" {
  description = "Environment"
  type = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "location_logs" {
  description = "CloudWatch logs name for location service"
  type        = string
}

variable "create_iot_policy" {
  description = "Set to true to create the IoT policy, or false to skip creation if it already exists."
  type        = bool
  default     = true
}

variable "create_iot_topic_rule" {
  description = "Set to true to create the IoT topic rule, or false to skip creation if it already exists."
  type        = bool
  default     = true
}

variable "create_lambda_permission" {
  description = "Whether to create the Lambda permission"
  type        = bool
  default     = true
}


###############################

variable "identity_pool_name" {
  description = "The name of the Cognito Identity Pool."
  type        = string
  default     = "GenTelemetryIdentityPool"
}

variable "allow_unauthenticated_identities" {
  description = "Allow unauthenticated identities in the identity pool."
  type        = bool
  default     = false
}

variable "identity_pool_role_name" {
  description = "The IAM role name for the Cognito Identity Pool."
  type        = string
}

variable "create_identity_pool_role" {
  description = "Flag to create a new IAM role for Cognito if not exists."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Retention period for CloudWatch logs."
  type        = number
  default     = 30
}

###########################

variable "s3_bucket_name" {
  description = "The name of the existing S3 bucket to store recipes and artifacts"
  type        = string
}

variable "assume_role_arn" {
  description = "The ARN of the cross-account role to assume"
  type        = string
}

variable "identity_pool_role_name_arn" {
  description = "The ARN of the precreated IAM role for the Cognito Identity Pool"
  type        = string
}

# Location Service Variables
variable "location_recipe_file" {
  description = "Path to the recipe file for location service"
  type        = string
}

variable "location_artifacts" {
  description = "List of artifacts for location service"
  type        = list(string)
}

variable "location_component_name" {
  description = "Name of the location service component"
  type        = string
}

# Kinesis Video Variables
variable "kinesis_recipe_file" {
  description = "Path to the recipe file for kinesis video"
  type        = string
}

variable "kinesis_artifacts" {
  description = "List of artifacts for kinesis video"
  type        = list(string)
}

variable "kinesis_component_name" {
  description = "Name of the kinesis video component"
  type        = string
}
