variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "env" {
  description = "Environment"
  type = string
}