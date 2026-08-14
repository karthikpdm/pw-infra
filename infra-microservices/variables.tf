# variables.tf


variable "aws_region" {
  description = "region (e.g., dev, qa, prod)"
  type        = string
}

variable "assume_role_arn" {
  description = "roles for (e.g., dev, qa, prod)"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "eks_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "disk_size" {
  description = "Size of the EBS volume for each node in GB"
  type        = number
}

variable "max_unavailable" {
  description = "Size of the EBS volume for each node in GB"
  type        = number
}
variable "instance_type" {
  description = "EC2 instance type for the EKS nodes"
  type        = string
}

variable "ami_type" {
  description = "AMI Type for the EKS worker nodes"
  type        = string
}

variable "karpenter_version" {
  description = "Karpenter Version to be installed"
  type        = string
}

variable "karpenter_vcpu" {
  description = "Karpenter Maximum CPU Limit"
  type        = string
}

variable "karpenter_memory" {
  description = "Karpenter Maximum memory Limit"
  type        = string
}

variable "account_id" {
  description = "Source Account ID"
  type        = string
}

variable "master_ingress_rules" {
  description = "List of ingress rules for the EKS master security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}

variable "master_egress_rules" {
  description = "List of egress rules for the EKS master security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}

variable "map_tagging" {
  description = "Mandatory tags for all the resources"
  type        = map(string)
}

variable "workers_ingress_rules" {
  description = "List of ingress rules for the EKS workers security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}

variable "workers_egress_rules" {
  description = "List of egress rules for the EKS workers security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}

variable "certificate_arn" {
  description = "ARN of the TLS certificate for HTTPS (if used)"
  type        = string
  default     = "arn:aws:acm:us-east-1:767397709508:certificate/b6dca4cb-7e75-4ba8-8e2c-cec47b4f18e6"

}

variable "customer_domain" {
  description = "domain name for the customer portal"
  type        = string
  default     = "example.com"
}

variable "website_domain" {
  description = "domain name for the website portal"
  type        = string
  default     = "Websitebe.dev.prioritywaste.com"

}

variable "internal_domain" {
  description = "domain name for the internal"
  type        = string
  default     = "internalbe.dev.prioritywaste.com"
}

variable "eks_s3_bucket_arns" {
  description = "S3 ARN for eks access"
  type        = list(string)
}

variable "eks_kms_arns" {
  description = "KMS ARN for eks access"
  type        = list(string)
}

variable "eks_secret_manage_arns" {
  description = "Secret Manager ARN for eks access"
  type        = list(string)
}

variable "eks_dynamodb_arns" {
  description = "DynamoDB ARN for eks access"
  type        = list(string)
}

variable "email_subscribers" {
  type          = list(string)
  description   = "List of email subscribers for CloudWatch alerts"
}

variable "metrics_server_version" {
  type          = string
  description   = "Metrics Server Version"
}

variable "eks_workers_sg_id" {
  type        = string
  description = "worker sg id"
}

variable "fluent_bit_version" {
  type          = string
  description   = "Fluent Bit Version"
}
