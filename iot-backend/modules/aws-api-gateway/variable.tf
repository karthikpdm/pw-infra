variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "env" {
  description = "Environment"
  type = string
}

# variable "lambda_arn_telemetryDisconnect" {
#   description = "Lambda ARN"
#   type = string
# }

# variable "invoke_arn_telemetryConnect" {
#   description = "Lambda Invoke ARN"
#   type = string
# }

# variable "invoke_arn_telemetryDisconnect"{
#   description = "Lambda Invoke ARN"
#   type = string
# }