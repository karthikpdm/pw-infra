# CloudWatch Log Group for pw-amcs-incremental-job
resource "aws_cloudwatch_log_group" "glue-amcs-incremental-log-group" {
  name              = "/aws-glue/jobs/pw-amcs-incremental-job"
  retention_in_days = 14
  kms_key_id        = var.datalake_kms_key_arn

   tags = var.tags
}



# CloudWatch Log Group for pw-amcs-incremental-job
resource "aws_cloudwatch_log_group" "glue-data-ingestion-netsuite-log-group" {
  name              = "/aws-glue/jobs/pw-data-ingestion-netsuite-job"
  retention_in_days = 14
  kms_key_id        = var.datalake_kms_key_arn

   tags = var.tags
}

# CloudWatch Log Group for pw-amcs-incremental-job
resource "aws_cloudwatch_log_group" "platform_data_incremental-log-group" {
  name              = "/aws-glue/jobs/pw-platform-data-incremental-load-job"
  retention_in_days = 14
  kms_key_id        = var.datalake_kms_key_arn

   tags = var.tags
}


# CloudWatch Log Group for pw-amcs-incremental-job
resource "aws_cloudwatch_log_group" "dossier_delta_load-log-group" {
  name              = "/aws-glue/jobs/pw-dossier-delta-load-job"
  retention_in_days = 14
  kms_key_id        = var.datalake_kms_key_arn

   tags = var.tags
}


# CloudWatch Log Group for pw-amcs-incremental-job
resource "aws_cloudwatch_log_group" "data_cleansing-log-group" {
  name              = "/aws-glue/jobs/pw-data-cleansing-job"
  retention_in_days = 14
  kms_key_id        = var.datalake_kms_key_arn

   tags = var.tags
}

# CloudWatch Log Group for pw-amcs-incremental-job
resource "aws_cloudwatch_log_group" "connect_files-log-group" {
  name              = "/aws-glue/jobs/Connect_Files"
  retention_in_days = 14
  kms_key_id        = var.datalake_kms_key_arn

   tags = var.tags
}
# CloudWatch Log Group for pw-amcs-incremental-job
resource "aws_cloudwatch_log_group" "heavy_haul_file-log-group" {
  name              = "/aws-glue/jobs/Heavy_Haul_File"
  retention_in_days = 14
  kms_key_id        = var.datalake_kms_key_arn

   tags = var.tags
}
# CloudWatch Log Group for pw-amcs-incremental-job
resource "aws_cloudwatch_log_group" "residential_file_data-log-group" {
  name              = "/aws-glue/jobs/Residential_File_Data"
  retention_in_days = 14
  kms_key_id        = var.datalake_kms_key_arn

   tags = var.tags
}




