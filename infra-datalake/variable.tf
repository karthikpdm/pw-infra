variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}
variable "region" {
  description = "Region used for deployment of AWS resources"
  type        = string
}
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
variable "assume_role_arn" {
  description = "Role assumed to deploy in specific account."
  type        = string
}


variable "server_name" {
  description = "server_name"
  type        = string
  default     = "placeholder"  # Will be updated in AWS Console
}

variable "database_name" {
  description = "database_name"
  type        = string
  default     = "placeholder"
}

variable "user_name" {
  description = "user_name"
  type        = string
  default     = "placeholder"
}

variable "password" {
  description = "password"
  type        = string
  default     = "placeholder"
}

variable "driver_path" {
  description = "driver_path"
  type        = string
  default     = "placeholder"
}

variable "driver_class" {
  description = "driver_path"
  type        = string
  default     = "placeholder"
}

variable "url" {
  description = "url"
  type        = string
  default     = "placeholder"
}

variable "subscription_email" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "placeholder"
}
