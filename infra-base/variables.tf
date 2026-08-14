variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_az1_cidr" {
  description = "CIDR block for the public subnet in the first availability zone"
  type        = string
}

variable "public_subnet_az2_cidr" {
  description = "CIDR block for the public subnet in the second availability zone"
  type        = string
}

variable "private_subnet_az1_cidr" {
  description = "CIDR block for the private subnet in the first availability zone"
  type        = string
}

variable "private_subnet_az2_cidr" {
  description = "CIDR block for the private subnet in the second availability zone"
  type        = string
}

variable "env" {
  description = "Environment (e.g., dev, qa, prod)"
  type        = string
}

variable "aws_region" {
  description = "region (e.g., dev, qa, prod)"
  type        = string
}

variable "cloudwatch_log_retention_days" {
  description = "region (e.g., dev, qa, prod)"
  type        = string
}

variable "assume_role_arn" {
  description = "roles for (e.g., dev, qa, prod)"
  type        = string
}



variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}


locals {
  routes = [
    {
      cidr_block               = "0.0.0.0/0"
      nat_gateway_id           = aws_nat_gateway.nat_gateway.id
    },
    {
      cidr_block               = "10.12.0.0/19"
      vpc_peering_connection_id = data.aws_vpc_peering_connection.pw-vpc-peering-connection.id
    }
  ]
}