#variable "component_name" {
#  description = "The name of the Greengrass component"
#  type        = string
#  default     = "MyComponent"
#}

#variable "component_version" {
#  description = "The version of the Greengrass component"
#  type        = string
#  default     = "1.0.0"
#}

variable "target_arn" {
  description = "The target ARN for the Greengrass deployment (Thing Group or specific Thing)"
  type        = string
}

variable "failure_handling_policy" {
  description = "The policy for handling deployment failures"
  type        = string
  default     = "ROLLBACK"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}
