# Outputs for all Lambda functions

# All Datasources Lambda
output "all_datasources_lambda_name" {
  description = "Name of the all datasources Lambda function"
  value       = aws_lambda_function.all_datasources_lambda.function_name
}

output "all_datasources_lambda_arn" {
  description = "ARN of the all datasources Lambda function"
  value       = aws_lambda_function.all_datasources_lambda.arn
}

# Audit Lambda
output "audit_lambda_name" {
  description = "Name of the audit Lambda function"
  value       = aws_lambda_function.audit-lambda.function_name
}

output "audit_lambda_arn" {
  description = "ARN of the audit Lambda function"
  value       = aws_lambda_function.audit-lambda.arn
}

# # AMCS Schema Lambda
# output "amcs_schema_counts_lambda_name" {
#   description = "Name of the AMCS schema counts Lambda function"
#   value       = aws_lambda_function.amcs-schema.function_name
# }

# output "amcs_schema_counts_lambda_arn" {
#   description = "ARN of the AMCS schema counts Lambda function"
#   value       = aws_lambda_function.amcs-schema.arn
# }

# AMCS S3 Lambda SNS
# output "amcs_s3_lambda_sns_name" {
#   description = "Name of the AMCS S3 Lambda SNS function"
#   value       = aws_lambda_function.amcs_s3_lambda_sns.function_name
# }

# output "amcs_s3_lambda_sns_arn" {
#   description = "ARN of the AMCS S3 Lambda SNS function"
#   value       = aws_lambda_function.amcs_s3_lambda_sns.arn
# }

# output "dossier_audit_lambda_name" {
#   description = "ARN of the dossier_audit SNS function"
#   value       = aws_lambda_function.dossier_audit.function_name
# }

# output "dossier_audit_lambda_arn" {
#   description = "ARN of the dossier_audit function"
#   value       = aws_lambda_function.dossier_audit.arn
# }




# output "dossier_schemas_lambda_name" {
#   description = "ARN of the dossier_audit SNS function"
#   value       = aws_lambda_function.dossier_schemas.function_name
# }

# output "dossier_schemas_lambda_arn" {
#   description = "ARN of the dossier_audit function"
#   value       = aws_lambda_function.dossier_schemas.arn
# }



# output "dynamoDB_tables_count_lambda_name" {
#   description = "ARN of the dossier_audit SNS function"
#   value       = aws_lambda_function.dynamoDB-tables-count.function_name
# }

# output "dynamoDB_tables_count_lambda_arn" {
#   description = "ARN of the dossier_audit function"
#   value       = aws_lambda_function.dynamoDB-tables-count.arn
# }


output "data_curator_lambda_name" {
  description = "ARN of the dossier_audit SNS function"
  value       = aws_lambda_function.data_curator.function_name
}

output "data_curator_lambda_arn" {
  description = "ARN of the dossier_audit function"
  value       = aws_lambda_function.data_curator.arn
}

# output "cleansed_schema_counts_lambda_name" {
#   description = "ARN of the dossier_audit SNS function"
#   value       = aws_lambda_function.cleansed_schema_counts.function_name
# }

# output "cleansed_schema_counts_lambda_arn" {
#   description = "ARN of the dossier_audit function"
#   value       = aws_lambda_function.cleansed_schema_counts.arn
# }