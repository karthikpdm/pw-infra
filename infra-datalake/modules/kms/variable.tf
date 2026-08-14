


# Required Variables
variable "env" {
  description = "Environment (dev, uat, prod)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}



# # Full CloudWatch Log Group ARNs
# variable "incremental_log_group_arn" {
#   description = "Full ARN of the incremental job log group"
#   type        = string
# }

# variable "data_ingestion_netsuite_log_group_arn" {
#   description = "Full ARN of the data ingestion netsuite job log group"
#   type        = string
# }

# variable "platform_data_incremental_log_group_arn" {
#   description = "Full ARN of the platform data incremental job log group"
#   type        = string
# }

# variable "dossier_delta_load_log_group_arn" {
#   description = "Full ARN of the dossier delta load job log group"
#   type        = string
# }

# variable "data_cleansing_log_group_arn" {
#   description = "Full ARN of the data cleansing job log group"
#   type        = string
# }

# variable "connect_files_log_group_arn" {
#   description = "Full ARN of the connect files job log group"
#   type        = string
# }

# variable "heavy_haul_file_log_group_arn" {
#   description = "Full ARN of the heavy haul file job log group"
#   type        = string
# }

# variable "residential_file_data_log_group_arn" {
#   description = "Full ARN of the residential file data job log group"
#   type        = string
# }

# # S3 bucket ARN patterns
# variable "raw_bucket_arn" {
#   description = "ARN pattern for the raw data bucket"
#   type        = string
# }

# variable "cleansed_bucket_arn" {
#   description = "ARN pattern for the cleansed data bucket"
#   type        = string
# }

# variable "curated_bucket_arn" {
#   description = "ARN pattern for the curated data bucket"
#   type        = string
# }

# variable "operational_bucket_arn" {
#   description = "ARN pattern for the operational data bucket"
#   type        = string
# }

# variable "platform_data_bucket_arn" {
#   description = "ARN pattern for the platform data bucket"
#   type        = string
# }

# variable "temp_bucket_arn" {
#   description = "ARN pattern for the temp data bucket"
#   type        = string
# }

# variable "aws_glue_bucket_arn" {
#   description = "ARN pattern for the AWS Glue assets bucket"
#   type        = string
# }

# variable "dossier_layer_bucket_arn" {
#   description = "ARN pattern for the dossier layer bucket"
#   type        = string
# }

# variable "pw_reporting_bucket_arn" {
#   description = "ARN pattern for the reporting bucket"
#   type        = string
# }

# variable "pw_amcs_historical_bucket_arn" {
#   description = "ARN pattern for the AMCS historical data bucket"
#   type        = string
# }




# # Glue job name patterns - individual variables
# variable "glue_amcs_incremental_job_name" {
#   description = "Pattern for AMCS incremental job name"
#   type        = string
# }

# variable "glue_platform_data_incremental_load_job_name" {
#   description = "Pattern for data ingestion netsuite job name"
#   type        = string
# }

# variable "glue_dossier_delta_load_job_name" {
#   description = "Pattern for platform data incremental job name"
#   type        = string
# }

# variable "glue_data_cleansing_job_name" {
#   description = "Pattern for dossier delta load job name"
#   type        = string
# }

# variable "glue_data_ingestion_netsuite_job_name" {
#   description = "Pattern for data cleansing job name"
#   type        = string
# }

# variable "glue_connect_files_job_name" {
#   description = "Pattern for connect files job name"
#   type        = string
# }

# variable "glue_heavy_haul_file_job_name" {
#   description = "Pattern for heavy haul file job name"
#   type        = string
# }

# variable "glue_residential_file_data_job_name" {
#   description = "Pattern for residential file data job name"
#   type        = string
# }



# # # Glue security config pattern
# # variable "glue_security_config_pattern" {
# #   description = "Pattern for Glue security configuration"
# #   type        = string
# # }

# variable "glue_role_arn" {
#   description = "ARN of the specific IAM role for Glue"
#   type        = string
# }
