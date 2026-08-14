variable "location_logs"{
    description = "CloudWatch logs name for location service"
    type = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "lambda_arn_telemetry" {
  description = "Lambda ARN"
  type = string
}

variable "table_liveVehicleStatus" {
  description = "Dynamodb table Name"
  type        = string
}

variable "name_kvs_telemetry"{
  description = "Kineses stream name"
  type        = string
}

variable "table_telemetryData" {
  description = "Dynamodb table ARN"
  type        = string
}

variable "tableName_mlAlerts" {
  description = "Dynamodb table Name"
  type        = string
}

variable "table_mlAlerts" {
  description = "Dynamodb table ARN"
  type        = string
}