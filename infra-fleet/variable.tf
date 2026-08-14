variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

#variable "target_arn" {
#  default = "arn:aws:iot:us-east-1:767397709508:thing/pw-fleet-iot-thing-test"
#}

variable "greengrass_deployment_id" {
  description = "The ARN of the existing Greengrass deployment to be used in the IoT module"
  type        = string
}

#variable "identity_pool_name" {
#  description = "The name of the Cognito Identity Pool"
#  type        = string
#  default     = "GenTelemetryIdentityPool"
#}

#variable "allow_unauthenticated_identities" {
#  description = "Allow unauthenticated identities in the Cognito Identity Pool"
#  type        = bool
#  default     = true
#}

#variable "identity_pool_role_name" {
#  description = "Name of the IAM role to use with the Cognito Identity Pool"
#  type        = string
#  default     = "GenTelemetryIdentityPool"
#}

#variable "component_name" {
#  description = "The name of the Greengrass component"
#  type        = string
#}

#variable "component_version" {
#  description = "The version of the Greengrass component"
#  type        = string
#}

variable "target_arn" {
  description = "The ARN of the target Greengrass deployment"
  type        = string
}

variable "failure_handling_policy" {
  description = "The policy for handling deployment failures"
  type        = string
}

