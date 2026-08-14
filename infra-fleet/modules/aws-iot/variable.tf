variable "location_logs"{
    description = "CloudWatch logs name for location service"
    type = string
    default     = "/aws/iot/logs/default-location" 
}
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "greengrass_deployment_id" {
  description = "The ARN of the existing Greengrass deployment"
  type        = string
}