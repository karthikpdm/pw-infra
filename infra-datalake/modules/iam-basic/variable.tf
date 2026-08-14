# modules/iam-basic/variables.tf
# Minimal variables needed for the basic IAM module

variable "env" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
}