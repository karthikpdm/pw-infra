variable "raw_bucket_name" {
  description = "Common tags for all resources"
  type        = string
}


variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
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

# variable "driver_path" {
#   description = "driver_path"
#   type        = string
#   default     = "placeholder"
# }

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

variable "datalake_kms_key_arn" {
  description = "NetSuite Realm"
  type        = string
  default     = "placeholder"
}


variable "client_id" {
  description = "server_name"
  type        = string
  default     = "placeholder"  # Will be updated in AWS Console
}

variable "client_secret" {
  description = "database_name"
  type        = string
  default     = "placeholder"
}

variable "grant_type" {
  description = "user_name"
  type        = string
  default     = "placeholder"
}

variable "scope" {
  description = "password"
  type        = string
  default     = "placeholder"
}

variable "username" {
  description = "driver_path"
  type        = string
  default     = "placeholder"
}

variable "passwords" {
  description = "driver_path"
  type        = string
  default     = "placeholder"
}

