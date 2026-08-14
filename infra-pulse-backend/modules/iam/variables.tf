

variable "dynamodb_policy_name" {
  description = "Name of the DynamoDB policy"
  type        = string
  default     = "task-policy-dynamodb"
}

variable "cloudwatch_logs_policy_name" {
  description = "Name of the CloudWatch Logs policy"
  type        = string
  default     = "CloudWatchLogsFullAccessPolicy"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Environment (e.g., dev, qa, prod)"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}