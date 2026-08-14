variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "s3_bucket_input_training_path" {
  type = string
  description = "S3 path where training data is stored"
}

variable "s3_bucket_output_models_path" {
  type = string
  description = "S3 path were the output (trained models etc.) will be stored"
}

variable "s3_bucket_ml" {
  type = string
  description = "S3 path were the output (trained models etc.) will be stored"
}
