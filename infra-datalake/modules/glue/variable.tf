variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}



variable "glue_security_group_id" {
  description = "Common tags for all resources"
  type        = string
}



variable "glue_role_arn" {
  description = "Common tags for all resources"
  type        = string
}

variable "datalake_kms_key_arn" {
  description = "Common tags for all resources"
  type        = string
}

variable "amcs_secret_name" {
  description = "Common tags for all resources"
  type        = string
}



variable "dossier_secret_name" {
  description = "Common tags for all resources"
  type        = string
}

# variable "dossier_failure_topic_arn" {
#   description = "ARN of the Dossier failure SNS topic"
#   type        = string
#   default     = ""
# }

# variable "dossier_success_topic_arn" {
#   description = "ARN of the Dossier failure SNS topic"
#   type        = string
#   default     = ""
# }




variable "cleansed_bucket_name" {
  description = "Common tags for all resources"
  type        = string
}

variable "raw_bucket_name" {
  description = "Common tags for all resources"
  type        = string
}



variable "curated_bucket_name" {
  description = "Common tags for all resources"
  type        = string
}

# variable "pw_amcs_historical_bucket_name" {
#   description = "Common tags for all resources"
#   type        = string
# }


# variable "dossier_layer_bucket_name" {
#   description = "Common tags for all resources"
#   type        = string
# }



variable "operational_bucket_name" {
  description = "Common tags for all resources"
  type        = string
}

# variable "platform_data_bucket_name" {
#   description = "Common tags for all resources"
#   type        = string
# }



variable "incremental_log_group_name" {
  description = "Common tags for all resources"
  type        = string
}



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




# variable "glue_security_group_id" {
#   description = "Common tags for all resources"
#   type        = string
# }





variable "data_ingestion_netsuite_log_group_name" {
  description = "Common tags for all resources"
  type        = string
}

variable "platform_data_incremental_log_group_name" {
  description = "Common tags for all resources"
  type        = string
}

variable "dossier_delta_load_log_group_name" {
  description = "Common tags for all resources"
  type        = string
}

variable "data_cleansing_log_group_name" {
  description = "Common tags for all resources"
  type        = string
}

variable "connect_files_log_group_name" {
  description = "Common tags for all resources"
  type        = string
}

variable "heavy_haul_file_log_group_name" {
  description = "Common tags for all resources"
  type        = string
}

variable "residential_file_data_log_group_name" {
  description = "Common tags for all resources"
  type        = string
}


