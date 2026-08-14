output "training_bucket_id" {
  value = aws_s3_bucket.bucket_training_data.id
}

output "model_bucket_id" {
  value = aws_s3_bucket.bucket_output_models.id
}

output "ml_bucket_id" {
  value = aws_s3_bucket.ml.id
}