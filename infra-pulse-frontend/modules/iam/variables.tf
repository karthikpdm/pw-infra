variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}


variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "env" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}
