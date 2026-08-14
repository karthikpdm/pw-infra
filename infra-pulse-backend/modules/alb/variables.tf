variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Deployment environment (e.g., dev, qa, prod)"
  type        = string
}

variable "alb_security_group" {
  description = "Security group for the Application Load Balancer"
  type        = string
}



variable "certificate_arn" {
  description = "ARN of the TLS certificate for HTTPS (if used)"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}

