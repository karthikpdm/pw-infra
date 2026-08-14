
#####################################################################################################################
                                # DynamoDB Table - Cleansing Metadata
###################################################################################################################
resource "aws_dynamodb_table" "cleansing_metadata" {
  # name                        = "pw-cleansing-metadata"
  name                        = "pw-data-cleansing-metadata-${var.env}"
  billing_mode               = "PAY_PER_REQUEST"
  hash_key                   = "metadata_id"
  range_key                  = "metadata_name"

  attribute {
    name = "metadata_id"
    type = "S"
  }

  attribute {
    name = "metadata_name"
    type = "S"
  }

  # deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.datalake_kms_key_arn
  }

  tags = var.tags
}




#####################################################################################################################
                                      # DynamoDB Table - Data Cleansing Rules
#####################################################################################################################

resource "aws_dynamodb_table" "data_cleansing_rules" {
  # name                        = "data_cleansing_rules"
  name                        = "pw-data-cleansing-rules-${var.env}"
  billing_mode               = "PAY_PER_REQUEST"
  hash_key                   = "rule_id"
  range_key                  = "rule_name"

  attribute {
    name = "rule_id"
    type = "S"
  }

  attribute {
    name = "rule_name"
    type = "S"
  }

  # deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.datalake_kms_key_arn
  }

  tags = var.tags
}




#####################################################################################################################
                            # DynamoDB Table - AMCS Workflow Audit
#####################################################################################################################

resource "aws_dynamodb_table" "amcs_workflow_audit" {
  # name                        = "pw-amcs-workflow-audit"
  name                        = "pw-${var.env}-data-ingestion-wf-audit-ddb"
  billing_mode               = "PAY_PER_REQUEST"
  hash_key                   = "audit_id"
  range_key                  = "timestamp"

  attribute {
    name = "audit_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  # deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.datalake_kms_key_arn
  }

  tags = var.tags
}