variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "lambda_security_group_id" {
  description = "Security group ID for Lambda functions"
  type        = string
}

variable "lambda_role_arn" {
  description = "lambda role name"
  type        = string
}

################################################################################################

variable "failure-notification-topic-arn" {
  description = "ARN of the AMCS failure SNS topic"
  type        = string
  default     = ""
}

variable "success-notification-topic-arn" {
  description = "ARN of the Dossier failure SNS topic"
  type        = string
  default     = ""
}

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

# variable "amcs_s3_success_topic_arn" {
#   description = "ARN of the AMCS success SNS topic"
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


variable "amcs_secret_name" {
  description = "Common tags for all resources"
  type        = string
}

# variable "dossier_layer_bucket_name" {
#   description = "Common tags for all resources"
#   type        = string
# }



variable "raw_bucket_name" {
  description = "Common tags for all resources"
  type        = string
}

variable "cleansed_bucket_name" {
  description = "Common tags for all resources"
  type        = string
}

