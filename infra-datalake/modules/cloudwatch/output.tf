output "incremental_log_group_name" {
  description = "The name of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.glue-amcs-incremental-log-group.name
}

output "incremental_log_group_arn" {
  description = "The ARN of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.glue-amcs-incremental-log-group.arn
}


######################################################################

output "data_ingestion_netsuite_log_group_name" {
  description = "The name of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.glue-data-ingestion-netsuite-log-group.name
}

output "data_ingestion_netsuite_log_group_arn" {
  description = "The ARN of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.glue-data-ingestion-netsuite-log-group.arn
}


############################################################################################################################################

output "platform_data_incremental_log_group_name" {
  description = "The name of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.platform_data_incremental-log-group.name
}

output "platform_data_incremental_log_group_arn" {
  description = "The ARN of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.platform_data_incremental-log-group.arn
}


##################################################################################################################################################################################################################

output "dossier_delta_load_log_group_name" {
  description = "The name of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.dossier_delta_load-log-group.name
}

output "dossier_delta_load_log_group_arn" {
  description = "The ARN of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.dossier_delta_load-log-group.arn
}


########################################################################################################################################################################################################################################################################################

output "data_cleansing_log_group_name" {
  description = "The name of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.data_cleansing-log-group.name
}

output "data_cleansing_log_group__arn" {
  description = "The ARN of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.data_cleansing-log-group.arn
}


##############################################################################################################################################################################################################################################################################################################################################################

output "connect_files_log_group_name" {
  description = "The name of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.connect_files-log-group.name
}

output "connect_files_log_group_arn" {
  description = "The ARN of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.connect_files-log-group.arn
}


####################################################################################################################################################################################################################################################################################################################################################################################################################################

output "heavy_haul_file_log_group_name" {
  description = "The name of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.heavy_haul_file-log-group.name
}

output "heavy_haul_file_log_group_arn" {
  description = "The ARN of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.heavy_haul_file-log-group.arn
}


##########################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################

output "residential_file_data_log_group_name" {
  description = "The name of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.residential_file_data-log-group.name
}

output "residential_file_data_log_group_arn" {
  description = "The ARN of the CloudWatch log group for the Glue job"
  value       = aws_cloudwatch_log_group.residential_file_data-log-group.arn
}


######################################################################