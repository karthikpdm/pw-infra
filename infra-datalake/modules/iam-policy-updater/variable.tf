variable "env" {
  description = "Environment name"
  type        = string
}

variable "lambda_role_id" {
  description = "The ID of the Lambda role"
  type        = string
}

variable "glue_role_name" {
  description = "The name of the Glue role"
  type        = string
}

variable "step_function_role_name" {
  description = "The name of the Step Function role"
  type        = string
}

variable "raw_bucket_name" {
  description = "The name of the raw bucket"
  type        = string
}

variable "cleansed_bucket_name" {
  description = "The name of the cleansed bucket"
  type        = string
}

# variable "aws_glue_bucket_name" {
#   description = "The name of the AWS Glue bucket"
#   type        = string
# }

variable "amcs_secret_name" {
  description = "The name of the AMCS secret in Secrets Manager"
  type        = string
}

variable "audit_lambda_name" {
  description = "The name of the audit Lambda function"
  type        = string
}

variable "all_datasources_lambda_arn" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

# variable "amcs_s3_success_topic_arn" {
#   description = "The ARN of the AMCS S3 success SNS topic"
#   type        = string
# }

# variable "amcs_s3_failure_topic_arn" {
#   description = "The ARN of the AMCS S3 failure SNS topic" 
#   type        = string
# }

# variable "amcs_schema_counts_lambda_name" {
#   description = "The name of the AMCS schema counts Lambda function"
#   type        = string
# }

variable "amcs-data-ingestion-glue_name" {
  description = "The name of the Glue AMCS incremental job"
  type        = string
}

# variable "dossier_audit_lambda_name" {
#   description = "The name of the dossier audit Lambda function"
#   type        = string
# }

# variable "cleansed_schema_counts_lambda_name" {
#   description = "The name of the cleansed schema counts Lambda function"
#   type        = string
# }

# variable "platform_data_failure_topic_arn" {
#   description = "The ARN of the platform data failure SNS topic"
#   type        = string
# }

# variable "platform_data_success_topic_arn" {
#   description = "The ARN of the platform data success SNS topic"
#   type        = string
# }

# variable "cleaning_data_success_topic_arn" {
#   description = "The ARN of the cleaning data success SNS topic"
#   type        = string
# }

# variable "cleaning_data_failure_topic_arn" {
#   description = "The ARN of the cleaning data failure SNS topic"
#   type        = string
# }

# variable "dossier_failure_topic_arn" {
#   description = "The ARN of the dossier failure SNS topic"
#   type        = string
# }

# variable "dossier_success_topic_arn" {
#   description = "The ARN of the dossier success SNS topic"
#   type        = string
# }



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
variable "curated_bucket_name" {
  description = "Common tags for all resources"
  type        = string
}
variable "operational_bucket_name" {
  description = "Common tags for all resources"
  type        = string
}