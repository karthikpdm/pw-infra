variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "env" {
  description = "Environment"
  type = string
}

variable "table_liveVehicleStatus" {
  description = "Dynamodb table ARN"
  type        = string
}

variable "table_telemetryData" {
  description = "Dynamodb table ARN"
  type        = string
}

variable "tableName_liveVehicleStatus" {
  description = "Dynamodb table Name"
  type        = string
}

variable "tableName_telemetryData" {
  description = "Dynamodb table Name"
  type        = string
}

variable "arn_kvs_telemetry"{
  description = "Kinesis Stream Resource arn"
  type        = string
}

variable "telemetry_tracker_name"{
  description = "Telemetry tracker name"
  type        = string
}

variable "s3_ml_domain_name" {
  description = "Cloudfront domain id"
  type        = string
}
