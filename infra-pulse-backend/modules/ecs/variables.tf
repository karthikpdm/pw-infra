variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Deployment environment (e.g., dev, qa, prod)"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the ECS execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "ecs_security_group_ids" {
  description = "List of security group IDs for ECS service"
  type        = list(string)
}

variable "pulse_target_group_arn" {
  description = "ARN of the target group associated with the ECS service"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}


variable "desired_count" {
  description = "desired count for the service"
  type        = string
}

variable "min_task_count" {
  description = "Minimum number of tasks"
  default     = {
    dev  = 1
    uat  = 2
    prod = 3
  }
}

variable "max_task_count" {
  description = "Maximum number of tasks"
  default     = {
    dev  = 4
    uat  = 6
    prod = 10
  }
}


variable "cpu_target_value" {
  description = "desired count for the service"
  type        = string
}

variable "memory_target_value" {
  description = "desired count for the service"
  type        = string
}

