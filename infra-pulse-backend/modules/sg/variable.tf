variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Deployment environment (e.g., dev, qa, prod)"
  type        = string
}


variable "ecs_pulse_ingress_rules" {
  description = "List of ingress rules for the ECS Pulse security group"
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    description      = string
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP traffic from anywhere"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS traffic from anywhere"
    }
  ]
}

variable "ecs_pulse_egress_rules" {
  description = "List of egress rules for the ECS Pulse security group"
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    description      = string
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}

variable "alb_pulse_ingress_rules" {
  description = "List of ingress rules for the ALB Pulse security group"
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    security_groups  = list(string)
    description      = string
  }))
  default = [
    {
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      security_groups  = []
      description      = "Allow HTTP traffic from anywhere"
    },
    {
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      security_groups  = []
      description      = "Allow HTTPS traffic from anywhere"
    }
  ]
}

variable "alb_pulse_egress_rules" {
  description = "List of egress rules for the ALB Pulse security group"
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    description      = string
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}


variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}