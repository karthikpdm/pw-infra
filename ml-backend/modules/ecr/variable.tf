variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}

variable "scan" {
    description = "Scan iamges after being pushed to the repository (true)"
    type        = bool
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}