# Updated variables.tf
variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}



variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}



# variable "raw_bucket_name" {
#   description = "Common tags for all resources"
#   type        = string
# }

# variable "aws_glue_bucket_name" {
#   description = "Common tags for all resources"
#   type        = string
# }

variable "datalake_kms_key_arn" {
  description = "Common tags for all resources"
  type        = string
}

# variable "amcs_secret_name" {
#   description = "Common tags for all resources"
#   type        = string
# }


# # variable "glue_role_name" {
# #   description = "Common tags for all resources"
# #   type        = string
# # }


# variable "audit_lambda_name" {
#   description = "Common tags for all resources"
#   type        = string
# }

# variable "amcs_s3_lambda_sns_name" {
#   description = "Common tags for all resources"
#   type        = string
# }

# variable "glue_amcs_incremental_job_name" {
#   description = "Common tags for all resources"
#   type        = string
# }

# variable "amcs_schema_counts_lambda_name" {
#   description = "Common tags for all resources"
#   type        = string
# }

# variable "amcs_s3_failure_topic_arn" {
#   description = "ARN of the AMCS failure SNS topic"
#   type        = string
#   default     = ""
# }

# variable "amcs_s3_success_topic_arn" {
#   description = "ARN of the AMCS failure SNS topic"
#   type        = string
#   default     = ""
# }

# variable "cleansed_schema_counts_lambda_name" {
#   description = "Environment name (dev/staging/prod)"
#   type        = string
# }
# variable "dossier_audit_lambda_name" {
#   description = "Environment name (dev/staging/prod)"
#   type        = string
# }


# #sns



# variable "dossier_failure_topic_arn" {
#   description = "ARN of the Dossier failure SNS topic"
#   type        = string
#   default     = ""
# }

# variable "dossier_success_topic_arn" {
#   description = "ARN of the Dossier success SNS topic"
#   type        = string
#   default     = ""
# }

# variable "platform_data_failure_topic_arn" {
#   description = "ARN of the Platform data failure SNS topic"
#   type        = string
#   default     = ""
# }





# variable "platform_data_success_topic_arn" {
#   description = "ARN of the Platform data success SNS topic"
#   type        = string
#   default     = ""
# }

# variable "cleaning_data_failure_topic_arn" {
#   description = "ARN of the Platform data success SNS topic"
#   type        = string
#   default     = ""
# }

# variable "cleaning_data_success_topic_arn" {
#   description = "ARN of the Platform data success SNS topic"
#   type        = string
#   default     = ""
# }


# variable "cleansed_bucket_name" {
#   description = "Common tags for all resources"
#   type        = string
# }
