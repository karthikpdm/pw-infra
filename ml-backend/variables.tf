variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "s3_bucket_input_training_path" {
  description = "S3 path where training data is stored"
  type        = string
}

variable "s3_bucket_output_models_path" {
  description = "S3 path where the output (trained models etc.) will be stored"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "scan" {
  description = "Scan Images after being pushed to the repository (true)"
  type        = bool
}

variable "assume_role_arn" {
  description = "roles for (e.g., dev, qa, prod)"
  type        = string
}

# variable "model_artifact_s3_path" {
#   description = "S3 path to store model artifacts"
#   type        = string
# }

variable "model_image_uri" {
  description = "URI of the Docker image for the model (from ECR or other repository)"
  type        = string
}

variable "model_name" {
  description = "Name for the SageMaker model"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the SageMaker endpoint"
  type        = string
  default     = "ml.t2.medium"
}

variable "initial_instance_count" {
  description = "Initial instance count for the SageMaker endpoint"
  type        = number
  default     = 1
}

variable "pipeline_name" {
  description = "Name for the SageMaker pipeline"
  type        = string
}

# variable "pipeline_definition" {
#   description = "Pipeline steps in JSON format"
#   type        = string
# }

variable "model_registry_name" {
  description = "Name for the SageMaker model registry"
  type        = string
}

variable "model_registry_description" {
  description = "Description for the SageMaker model registry"
  type        = string
  default     = "Model registry for storing and managing ML models"
}

variable "ec2_ami" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "ec2_instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
}

variable "ec2_security_group_name" {
  description = "The name of the EC2 security group"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "s3_bucket_ml" {}