variable "env" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "tags" {
  description = "Common tags to be applied to resources"
  type        = map(string)
  default     = {}
}
# subscription_email

variable "subscription_email" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}


