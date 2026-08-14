## Outputs for Raw bucket
output "raw_bucket_name" {
  value = aws_s3_bucket.raw.bucket
}

output "raw_bucket_arn" {
  value = aws_s3_bucket.raw.arn
}

# Outputs for Cleansed bucket
output "cleansed_bucket_name" {
  value = aws_s3_bucket.cleansed.bucket
}

output "cleansed_bucket_arn" {
  value = aws_s3_bucket.cleansed.arn
}

# Outputs for Curated bucket
output "curated_bucket_name" {
  value = aws_s3_bucket.curated.bucket
}

output "curated_bucket_arn" {
  value = aws_s3_bucket.curated.arn
}

# Outputs for Operational bucket
output "operational_bucket_name" {
  value = aws_s3_bucket.operational.bucket
}

output "operational_bucket_arn" {
  value = aws_s3_bucket.operational.arn
}


# # Outputs for Operational bucket
# output "platform_data_bucket_name" {
#   value = aws_s3_bucket.platform-data.bucket
# }

# output "platform_data_bucket_arn" {
#   value = aws_s3_bucket.platform-data.arn
# }



# # Outputs for Temp bucket
# output "dossier_layer_bucket_name" {
#   value = aws_s3_bucket.dossier-layer.bucket
# }

# output "dossier_layer_bucket_arn" {
#   value = aws_s3_bucket.dossier-layer.arn
# }


# Outputs for Temp bucket
output "temp_bucket_name" {
  value = aws_s3_bucket.temp.bucket
}

output "temp_bucket_arn" {
  value = aws_s3_bucket.temp.arn
}

# # Outputs for AWS Glue bucket
# output "aws_glue_bucket_name" {
#   value = aws_s3_bucket.aws-glue.bucket
# }

# output "aws_glue_bucket_arn" {
#   value = aws_s3_bucket.aws-glue.arn
# }

# # Outputs for AWS Glue bucket
# output "pw_reporting_bucket_name" {
#   value = aws_s3_bucket.pw_reporting.bucket
# }

# output "pw_reporting_bucket_arn" {
#   value = aws_s3_bucket.pw_reporting.arn
# }







output "bucket_region" {
  description = "The region where the buckets are created"
  value       = aws_s3_bucket.raw.region
}