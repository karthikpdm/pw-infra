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


variable "audit_lambda_name" {
  description = "Common tags for all resources"
  type        = string
}

variable "audit_lambda_arn" {
  description = "Common tags for all resources"
  type        = string
}

# variable "amcs_s3_lambda_sns_name" {
#   description = "Common tags for all resources"
#   type        = string
# }

variable "amcs-data-ingestion-glue_name" {
  description = "Common tags for all resources"
  type        = string
}

# variable "amcs_schema_counts_lambda_arn" {
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

# variable "failure-notification-topic-arn" {
#   description = "Common tags for all resources"
#   type        = string
# }




# variable "cleaning_data_success_topic_arn" {
#   description = "Common tags for all resources"
#   type        = string
# }

# variable "cleaning_data_failure_topic_arn" {
#   description = "Common tags for all resources"
#   type        = string
# }





# variable "platform_data_success_topic_arn" {
#   description = "Common tags for all resources"
#   type        = string
# }

# variable "dynamoDB_tables_count_lambda_arn" {
#   description = "Common tags for all resources"
#   type        = string
# }

# variable "failure-notification-topic-arn" {
#   description = "ARN of the AMCS failure SNS topic"
#   type        = string
#   default     = ""
# }

# variable "success-notification-topic-arn" {
#   description = "ARN of the Dossier failure SNS topic"
#   type        = string
#   default     = ""
# }




variable "tags" {
  description = "Common tags to be applied to resources"
  type        = map(string)
  default     = {}
}

variable "env" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}


variable "step_function_role_arn" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}



# variable "dossier_audit_lambda_name" {
#   description = "Environment name (dev/staging/prod)"
#   type        = string
# }


# variable "dossier_schemas_lambda_name" {
#   description = "Name of the Lambda function for retrieving Dossier schemas"
#   type        = string
#   # If you want to provide a default value:
#   # default     = "dossier-schemas"
# }
variable "all_datasources_lambda_arn" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}


# variable "cleansed_schema_counts_lambda_name" {
#   description = "Environment name (dev/staging/prod)"
#   type        = string
# }

# variable "dossier_schemas_lambda_name" {
#   description = "Environment name (dev/staging/prod)"
#   type        = string
# }

variable "dossier_failure_topic_arn" {
  description = "ARN of the Dossier failure SNS topic"
  type        = string
  default     = ""
}

variable "dossier_success_topic_arn" {
  description = "ARN of the Dossier success SNS topic"
  type        = string
  default     = ""
}


variable "glue_dossier_delta_load_job_name" {
  description = "ARN of the Dossier success SNS topic"
  type        = string
  default     = ""
}

variable "glue_data_cleansing_job_name" {
  description = "ARN of the Dossier success SNS topic"
  type        = string
  default     = ""
}


variable "all_datasources_lambda_name" {
  description = "ARN of the Dossier success SNS topic"
  type        = string
  default     = ""
}



variable "data_curator_lambda_name" {
  description = "ARN of the Dossier success SNS topic"
  type        = string
  default     = ""
}



variable "glue_platform_data_incremental_load_job_name" {
  description = "ARN of the Dossier success SNS topic"
  type        = string
  default     = ""
}