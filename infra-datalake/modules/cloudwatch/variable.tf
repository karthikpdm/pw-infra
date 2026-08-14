variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "datalake_kms_key_arn" {
  description = "Common tags for all resources"
  type        = string
}

# variable "kms_key_arn" {
#   description = "Environment name (e.g., dev, uat, prod)"
#   type        = string
# }