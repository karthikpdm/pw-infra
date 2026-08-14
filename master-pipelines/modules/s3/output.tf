output "artifact_bucket_arn" {
  description = "ARN of the S3 bucket for artifacts"
  value       = aws_s3_bucket.artifact_store.arn
}

output "artifact_bucket_name" {
  description = "Name of the S3 bucket for artifacts"
  value       = aws_s3_bucket.artifact_store.id
}


##########################################################################


output "build_logs_bucket_arn" {
  description = "ARN of the S3 bucket for artifacts"
  value       = aws_s3_bucket.build-logs_store.arn
}

output "build-logs_bucket_name" {
  description = "Name of the S3 bucket for artifacts"
  value       = aws_s3_bucket.build-logs_store.id
}



# output "artifact_bucket_arn" {
#   description = "ARN of the S3 bucket for artifacts"
#   value       = aws_s3_bucket.artifact_store.arn
# }

# output "artifact_bucket_name" {
#   description = "Name of the S3 bucket for artifacts"
#   value       = aws_s3_bucket.artifact_store.id
# }


# ##########################################################################



# output "build_logs_bucket_arn" {
#   value       = aws_s3_bucket.build_logs_store.arn
#   description = "The ARN of the build logs bucket"
# }

# output "build-logs_bucket_name" {
#   description = "Name of the S3 bucket for artifacts"
#   value       = aws_s3_bucket.build_logs_store.id
# }



# ##########################################################################


output "access_logs_bucket_arn" {
  description = "ARN of the S3 bucket for artifacts"
  value       = aws_s3_bucket.access_logs_store.arn
}
output "access_logs_bucket_name" {
  description = "Name of the S3 bucket for artifacts"
  value       = aws_s3_bucket.access_logs_store.id
}

