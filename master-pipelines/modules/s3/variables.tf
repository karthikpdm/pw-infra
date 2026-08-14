
variable "artifact_bucket_name" {
  description = "Name of the S3 bucket to store pipeline artifacts"
  type        = string
}


variable "build-logs_bucket_name" {
  description = "Name of the S3 bucket to store pipeline artifacts"
  type        = string
}

variable "codepipeline_infra_role_arn" {}

# variable "artifact_bucket_name" {
#   description = "Name of the S3 bucket to store pipeline artifacts"
#   type        = string
# }


# variable "build-logs_bucket_name" {
#   description = "Name of the S3 bucket to store pipeline artifacts"
#   type        = string
# }

variable "access_logs_bucket_name" {
  description = "Name of the S3 bucket to store pipeline artifacts"
  type        = string
}

# variable "codepipeline_infra_role_arn" {}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}

