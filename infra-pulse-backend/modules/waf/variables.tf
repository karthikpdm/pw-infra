variable "env" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}

# Make sure to add this variable to reference the KMS module
variable "kms_key_id" {
  description = "Name of the KMS module where the key is defined"
  type        = string
  default     = "kms"  # Adjust this to match your module name
}