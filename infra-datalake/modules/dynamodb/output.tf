

# Outputs
output "cleansing_metadata_table_arn" {
  value = aws_dynamodb_table.cleansing_metadata.arn
}

output "data_cleansing_rules_table_arn" {
  value = aws_dynamodb_table.data_cleansing_rules.arn
}

output "amcs_workflow_audit_table_arn" {
  value = aws_dynamodb_table.amcs_workflow_audit.arn
}