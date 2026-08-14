variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "assume_role_arn" {
  description = "Environment (e.g., dev, qa, prod)"
  type        = string
}

variable "env" {
  description = "Environment (e.g., dev, qa, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}


variable "ecs_pulse_ingress_rules" {
  description = "List of ingress rules for the ECS Pulse security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "ecs_pulse_egress_rules" {
  description = "List of egress rules for the ECS Pulse security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "alb_pulse_ingress_rules" {
  description = "List of ingress rules for the ALB Pulse security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "alb_pulse_egress_rules" {
  description = "List of egress rules for the ALB Pulse security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}



variable "certificate_arn" {
  description = "ARN of the TLS certificate for HTTPS (if used)"
  type        = string
  default     = "arn:aws:acm:us-east-1:767397709508:certificate/b6dca4cb-7e75-4ba8-8e2c-cec47b4f18e6"

}



variable "tags" {
  type = map(string)
  default = {
    map-migrated = "migSZUDBD3OY2"
    project      = "pw"
    track        = "pulse"
    
  }
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





