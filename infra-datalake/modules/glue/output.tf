# Outputs
output "amcs-data-ingestion-glue_name" {
  value = aws_glue_job.amcs-data-ingestion-glue.name
}

output "amcs-data-ingestion-glue_arn" {
  value = aws_glue_job.amcs-data-ingestion-glue.arn
}


# Outputs
output "glue_dossier_delta_load_job_name" {
  value = aws_glue_job.dossier_delta_load.name
}

output "glue_dossier_delta_load_job_arn" {
  value = aws_glue_job.dossier_delta_load.arn
}

# Outputs
output "glue_platform_data_incremental_load_job_name" {
  value = aws_glue_job.platform_data_ingestion.name
  # value = aws_glue_job.platform_data_incremental.nameingestion
}

output "glue_platform_data_incremental_load_job_arn" {
  value = aws_glue_job.platform_data_ingestion.arn
}

# Outputs
output "glue_data_cleansing_job_name" {
  value = aws_glue_job.data_cleansing.name
}

output "glue_data_cleansing_job_arn" {
  value = aws_glue_job.data_cleansing.arn
}


# Outputs
output "glue_connect_files_job_name" {
  value = aws_glue_job.connect_files.name
}

output "glue_connect_files_job_arn" {
  value = aws_glue_job.connect_files.arn
}

# Outputs
output "glue_heavy_haul_file_job_name" {
  value = aws_glue_job.heavy_haul_file.name
}

output "glue_heavy_haul_file_job_arn" {
  value = aws_glue_job.heavy_haul_file.arn
}


# Outputs
output "glue_residential_file_data_job_name" {
  value = aws_glue_job.residential_file_data.name
}

output "glue_residential_file_data_job_arn" {
  value = aws_glue_job.residential_file_data.arn
}

# Outputs
output "glue_data_ingestion_netsuite_job_name" {
  value = aws_glue_job.data_ingestion_netsuite.name
}

output "glue_data_ingestion_netsuite_job_arn" {
  value = aws_glue_job.data_ingestion_netsuite.arn
}

