# modules/kms/variables.tf

variable "key_description" {
  type    = string
  default = "KMS key for CodePipeline encryption"
}

variable "deletion_window_in_days" {
  type    = number
  default = 10
}

variable "enable_key_rotation" {
  type    = bool
  default = true
}

variable "key_alias" {
  type = string
}

variable "codepipeline_role_arn" {
  type = string
}