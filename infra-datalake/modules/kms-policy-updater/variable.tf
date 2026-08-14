

variable "datalake_kms_key_arn" {
  description = "Common tags for all resources"
  type        = string
}

variable "log_group_arns" {
  description = "List of CloudWatch log group ARNs to grant access to"
  type        = list(string)
  default     = []
}

variable "bucket_arns" {
  description = "List of S3 bucket ARNs to grant access to"
  type        = list(string)
  default     = []
}

variable "glue_job_names" {
  description = "List of Glue job names to grant access to"
  type        = list(string)
  default     = []
}

variable "glue_role_arn" {
  description = "The ARN of the Glue role to grant access to"
  type        = string
}