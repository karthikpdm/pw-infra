data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


#######################################################################################################
# Creating VPC
#######################################################################################################
resource "aws_vpc" "pw_vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true



  tags = merge(
    var.tags,
    {
      Name = "pw-vpc-${var.env}"
    }
  )

}


#######################################################################################################


# VPC Flow Logs configuration
resource "aws_flow_log" "example" {
  iam_role_arn    = aws_iam_role.vpc_role.arn
  log_destination = aws_cloudwatch_log_group.vpc-cloudwatch.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.pw_vpc.id

  tags = merge(var.tags, {
    Name = "pw-vpc-flowlogs-${var.env}"
  })
}


# #######################################################################################################
# KMS Key for CloudWatch Logs encryption
resource "aws_kms_key" "cloudwatch_encryption_key" {
  description             = "KMS key for VPC Flow Logs CloudWatch encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs to use the key"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "pw-kms-key-vpc-flowlogs-${var.env}"
  })
}

# KMS Alias
resource "aws_kms_alias" "cloudwatch_encryption_key_alias" {
  name          = "alias/pw-kms-vpc-flowlogs-${var.env}"
  target_key_id = aws_kms_key.cloudwatch_encryption_key.key_id

  # tags = var.tags
}



# CloudWatch Log Group to store Flow Logs
resource "aws_cloudwatch_log_group" "vpc-cloudwatch" {
  name              = "/aws/vpc/flow-logs/pw-vpc-${var.env}"
  retention_in_days = var.cloudwatch_log_retention_days
  kms_key_id        = aws_kms_key.cloudwatch_encryption_key.arn

  tags = merge(var.tags, {
    Name = "pw-cloudwatch-vpc-flowlogs-${var.env}"
  })
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "vpc_role" {
  name               = "pw-vpc-flow-logs-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(var.tags, {
    Name = "pw-iam-role-vpc-flowlogs-${var.env}"
  })
}

# IAM policy document for assuming the role by VPC Flow Logs
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM policy document for CloudWatch Logs permissions
data "aws_iam_policy_document" "vpc-policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = [
      aws_cloudwatch_log_group.vpc-cloudwatch.arn,
      "${aws_cloudwatch_log_group.vpc-cloudwatch.arn}:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      aws_kms_key.cloudwatch_encryption_key.arn
    ]
  }
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy" "policy" {
  name   = "pw-iam-policy-vpc-flowlogs-${var.env}"
  role   = aws_iam_role.vpc_role.id
  policy = data.aws_iam_policy_document.vpc-policy.json
}


#######################################################################################################
# # CloudWatch Log Group to store Flow Logs
# resource "aws_cloudwatch_log_group" "vpc-cloudwatch" {
#   name = "/aws/vpc/flow-logs/pw-vpc-${var.env}"

#   retention_in_days = var.cloudwatch_log_retention_days

#   # Tags for CloudWatch Log Group
 

#   tags = merge(
#     var.tags
#   )
# }

# #######################################################################################################

# # IAM policy document for assuming the role by VPC Flow Logs
# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["vpc-flow-logs.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# # IAM Role for VPC Flow Logs
# resource "aws_iam_role" "vpc_role" {
#   name               = "pw-vpc-flow-logs-role-${var.env}"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json

#   # Tags for IAM Role
 

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-vpc-flow-logs-role-${var.env}"
#     }
#   )
# }

# # IAM policy document for CloudWatch Logs permissions
# data "aws_iam_policy_document" "vpc-policy" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams",
#     ]

#     # Restrict permissions to specific CloudWatch Log Group
#     resources = [
#       aws_cloudwatch_log_group.vpc-cloudwatch.arn
#     ]
#   }
# }

# # Attach the policy to the IAM role
# resource "aws_iam_role_policy" "policy" {
#   name   = "pw-vpc-flow-logs-policy-${var.env}"
#   role   = aws_iam_role.vpc_role.id
#   policy = data.aws_iam_policy_document.vpc-policy.json

  
# }



#######################################################################################################

# Creating Internet Gateway and attach it to VPC


resource "aws_internet_gateway" "pw_internet_gateway" {
  vpc_id = aws_vpc.pw_vpc.id

 

  tags = merge(
    var.tags,
    {
      Name = "pw-igw-${var.env}"
    }
  )
}

#######################################################################################################

# Using data source to get all Availability Zones in region
data "aws_availability_zones" "available_zones" {}

# Creating Public Subnet AZ1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.pw_vpc.id
  cidr_block              = var.public_subnet_az1_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false

  

  tags = merge(
    var.tags,
    {
      Name = "pw-public-subnet-az1-${var.env}"
    }
  )
}

#######################################################################################################

# Creating Public Subnet AZ2
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.pw_vpc.id
  cidr_block              = var.public_subnet_az2_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false

  

  tags = merge(
    var.tags,
    {
      Name = "pw-public-subnet-az2-${var.env}"
    }
  )
}

#######################################################################################################

# Creating Private Subnet AZ1
resource "aws_subnet" "private_subnet_az1" {
  vpc_id          = aws_vpc.pw_vpc.id
  cidr_block      = var.private_subnet_az1_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false  # Disable automatic public IP assignment


  

  tags = merge(
    var.tags,
    {
      Name = "pw-private-subnet-az1-${var.env}"
    }
  )
}

#######################################################################################################

# Creating Private Subnet AZ2
resource "aws_subnet" "private_subnet_az2" {
  vpc_id          = aws_vpc.pw_vpc.id
  cidr_block      = var.private_subnet_az2_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false  # Disable automatic public IP assignment


  

  tags = merge(
    var.tags,
    {
      Name = "pw-private-subnet-az2-${var.env}"
    }
  )
}

#######################################################################################################

# Creating Route Table and add Public Route
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.pw_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pw_internet_gateway.id
  }

 

  tags = merge(
    var.tags,
    {
      Name = "pw-public-route-table-${var.env}"
    }
  )
}

#######################################################################################################

# Creating Route Table and add Private Route for AZ1
resource "aws_route_table" "private_route_table_az1" {
  vpc_id = aws_vpc.pw_vpc.id

  tags = merge(
    var.tags,
    {
    Name    = "pw-private-route-table-az1-${var.env}"
    }
  )
}

data "aws_vpc_peering_connection" "pw-vpc-peering-connection" {
  filter {
    name   = "tag:Name"
    values = ["pw-vpc-peering-${var.env}"]
  }
  
  filter {
    name   = "status-code"
    values = ["active"]
  }
}

resource "aws_route" "pw-private-route-table-entries-az1" {
  for_each = { for idx, route in local.routes : idx => route }

  route_table_id          = aws_route_table.private_route_table_az1.id
  destination_cidr_block  = each.value.cidr_block
  nat_gateway_id          = lookup(each.value, "nat_gateway_id", null)
  vpc_peering_connection_id = lookup(each.value, "vpc_peering_connection_id", null)
  
}

#######################################################################################################

# Creating Route Table and add Private Route for AZ2
resource "aws_route_table" "private_route_table_az2" {
  vpc_id = aws_vpc.pw_vpc.id

  tags = merge(
    var.tags,
    {
    Name    = "pw-private-route-table-az2-${var.env}"
    }
  )
}

resource "aws_route" "pw-private-route-table-entries-az2" {
  for_each = { for idx, route in local.routes : idx => route }

  route_table_id          = aws_route_table.private_route_table_az2.id
  destination_cidr_block  = each.value.cidr_block
  nat_gateway_id          = lookup(each.value, "nat_gateway_id", null)
  vpc_peering_connection_id = lookup(each.value, "vpc_peering_connection_id", null)
}

#######################################################################################################

# Creating NAT Gateway for Private Subnet AZ1
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_az1.id

  
  tags = merge(
    var.tags,
    {
     Name    = "pw-nat-gateway-${var.env}"
    }
  )
}

#######################################################################################################

# Creating EIP for NAT Gateway
resource "aws_eip" "nat_eip" {

 

  tags = merge(
    var.tags,
    {
    Name    = "pw-nat-eip-${var.env}"
    }
  )
}

#######################################################################################################

# Associating Public Subnet in AZ1 to route table
resource "aws_route_table_association" "public_subnet_az1_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_route_table.id

}

# Associating Public Subnet in AZ2 to route table
resource "aws_route_table_association" "public_subnet_az2_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_route_table.id


}

# Associating Private Subnet in AZ1 to private route table AZ1
resource "aws_route_table_association" "private_subnet_az1_route_table_association_az1" {
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.private_route_table_az1.id

  
}

# Associating Private Subnet in AZ2 to private route table AZ2
resource "aws_route_table_association" "private_subnet_az2_route_table_association_az2" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.private_route_table_az2.id

  
}


# ####################################################################################################

# # EC2 VPC Endpoint
# resource "aws_vpc_endpoint" "ec2" {
#   vpc_id             = aws_vpc.pw_vpc.id
#   service_name       = "com.amazonaws.${var.aws_region}.ec2"
#   vpc_endpoint_type  = "Interface"
#   private_dns_enabled = true

#   subnet_ids = [
#     aws_subnet.private_subnet_az1.id,
#     aws_subnet.private_subnet_az2.id
#   ]

#   security_group_ids = [aws_security_group.ec2_endpoint.id]

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-ec2-vpc-endpoint-${var.env}"
#     }
#   )
# }

# # Security Group for EC2 VPC Endpoint
# resource "aws_security_group" "ec2_endpoint" {
#   name        = "pw-ec2-endpoint-sg-${var.env}"
#   description = "Security group for EC2 VPC endpoint"
#   vpc_id      = aws_vpc.pw_vpc.id

#   ingress {
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     cidr_blocks     = [var.vpc_cidr_block]
#     description     = "Allow HTTPS from VPC CIDR"
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-ec2-endpoint-sg-${var.env}"
#     }
#   )
# }

# # ####################################################################################################


# ECR API VPC Endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.pw_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private_subnet_az1.id,
    aws_subnet.private_subnet_az2.id
  ]

  security_group_ids = [aws_security_group.ecr_api_endpoint.id]

  private_dns_enabled = true

  # policy = jsonencode({
  #   Version = "2012-10-17"
  #   Statement = [
  #     {
  #       Effect = "Allow"
  #       Principal = "*"
  #       Action = [
  #         "ecr:BatchCheckLayerAvailability",
  #         "ecr:BatchGetImage",
  #         "ecr:DescribeImages",
  #         "ecr:DescribeRepositories",
  #         "ecr:GetDownloadUrlForLayer",
  #         "ecr:GetLifecyclePolicy",
  #         "ecr:ListImages",
  #         "ecr:ListTagsForResource"
  #       ]
  #       Resource = "*"
  #       Condition = {
  #         StringEquals = {
  #           "aws:PrincipalAccount": [
  #             data.aws_caller_identity.current.account_id,
  #             "339713024244"  # ECR account
  #           ]
  #         }
  #       }
  #     }
  #   ]
  # })

  tags = merge(
    var.tags,
    {
      Name = "pw-ecr-api-vpc-endpoint-${var.env}"
    }
  )
}

# Security Group for ECR API VPC Endpoint
resource "aws_security_group" "ecr_api_endpoint" {
  name        = "pw-ecr-api-endpoint-sg-${var.env}"
  description = "Security group for ECR API VPC endpoint"
  vpc_id      = aws_vpc.pw_vpc.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr_block]
    description     = "Allow HTTPS from VPC CIDR"
  }

  tags = merge(
    var.tags,
    {
      Name = "pw-ecr-api-endpoint-sg-${var.env}"
    }
  )
}

# # ####################################################################################################


# VPC Endpoint for Docker Registry
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.pw_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private_subnet_az1.id,
    aws_subnet.private_subnet_az2.id
  ]

  security_group_ids = [aws_security_group.ecr_dkr_endpoint.id]

  private_dns_enabled = true

  #  policy = jsonencode({
  #   Version = "2012-10-17"
  #   Statement = [
  #     {
  #       Effect = "Allow"
  #       Principal = "*"
  #       Action = [
  #         "ecr:BatchCheckLayerAvailability",
  #         "ecr:BatchGetImage",
  #         "ecr:GetDownloadUrlForLayer",
  #         "ecr:GetRepositoryPolicy",
  #         "ecr:DescribeRepositories",
  #         "ecr:ListImages"
  #       ]
  #       Resource = "*"
  #       Condition = {
  #         StringEquals = {
  #           "aws:PrincipalAccount": [
  #             data.aws_caller_identity.current.account_id,
  #             "339713024244"  # ECR account
  #           ]
  #         }
  #       }
  #     }
  #   ]
  # })


  tags = merge(
    var.tags,
    {
      Name = "pw-ecr-dkr-vpc-endpoint-${var.env}"
    }
  )
}

# Security Group for ECR Docker Registry VPC Endpoint
resource "aws_security_group" "ecr_dkr_endpoint" {
  name        = "pw-ecr-dkr-endpoint-sg-${var.env}"
  description = "Security group for ECR Docker Registry VPC endpoint"
  vpc_id      = aws_vpc.pw_vpc.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr_block]
    description     = "Allow HTTPS from VPC CIDR"
  }

  tags = merge(
    var.tags,
    {
      Name = "pw-ecr-dkr-endpoint-sg-${var.env}"
    }
  )
}











# ####################################################################################################



# # SSM VPC Endpoints
# resource "aws_vpc_endpoint" "ssm" {
#   vpc_id             = aws_vpc.pw_vpc.id
#   service_name       = "com.amazonaws.${var.aws_region}.ssm"
#   vpc_endpoint_type  = "Interface"
#   private_dns_enabled = true
#   subnet_ids         = [
#     aws_subnet.private_subnet_az1.id,
#     aws_subnet.private_subnet_az2.id
#   ]
#   security_group_ids = [aws_security_group.ssm_endpoint.id]

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-ssm-endpoint-${var.env}"
#     }
#   )
# }

# resource "aws_vpc_endpoint" "ssmmessages" {
#   vpc_id             = aws_vpc.pw_vpc.id
#   service_name       = "com.amazonaws.${var.aws_region}.ssmmessages"
#   vpc_endpoint_type  = "Interface"
#   private_dns_enabled = true
#   subnet_ids         = [
#     aws_subnet.private_subnet_az1.id,
#     aws_subnet.private_subnet_az2.id
#   ]
#   security_group_ids = [aws_security_group.ssm_endpoint.id]

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-ssmmessages-endpoint-${var.env}"
#     }
#   )
# }

# resource "aws_vpc_endpoint" "ec2messages" {
#   vpc_id             = aws_vpc.pw_vpc.id
#   service_name       = "com.amazonaws.${var.aws_region}.ec2messages"
#   vpc_endpoint_type  = "Interface"
#   private_dns_enabled = true
#   subnet_ids         = [
#     aws_subnet.private_subnet_az1.id,
#     aws_subnet.private_subnet_az2.id
#   ]
#   security_group_ids = [aws_security_group.ssm_endpoint.id]

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-ec2messages-endpoint-${var.env}"
#     }
#   )
# }

# # Security Group for SSM VPC Endpoints
# resource "aws_security_group" "ssm_endpoint" {
#   name        = "pw-ssm-endpoint-sg-${var.env}"
#   description = "Security group for SSM VPC endpoints"
#   vpc_id      = aws_vpc.pw_vpc.id

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [var.vpc_cidr_block]
#     description = "Allow HTTPS from VPC CIDR"
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-ssm-endpoint-sg-${var.env}"
#     }
#   )
# }

####################################################################################################





##################################################################################################

# # ECR API VPC Endpoint
# resource "aws_vpc_endpoint" "ecr_api" {
#   vpc_id              = aws_vpc.pw_vpc.id
#   service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
#   vpc_endpoint_type   = "Interface"
#   private_dns_enabled = true

#   subnet_ids = [
#     aws_subnet.private_subnet_az1.id,
#     aws_subnet.private_subnet_az2.id
#   ]

#   security_group_ids = [
#     aws_security_group.ecr_endpoint_sg.id
#   ]

 
#   tags = merge(
#     var.tags,
#     {
#     Name    = "pw-ecr-api-endpoint-${var.env}"
#     }
#   )
# }

# # ECR DKR VPC Endpoint
# resource "aws_vpc_endpoint" "ecr_dkr" {
#   vpc_id              = aws_vpc.pw_vpc.id
#   service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
#   vpc_endpoint_type   = "Interface"
#   private_dns_enabled = true

#   subnet_ids = [
#     aws_subnet.private_subnet_az1.id,
#     aws_subnet.private_subnet_az2.id
#   ]

#   security_group_ids = [
#     aws_security_group.ecr_endpoint_sg.id
#   ]

 
#   tags = merge(
#     var.tags,
#     {
#     Name    = "pw-ecr-dkr-endpoint-${var.env}"
#     }
#   )
# }

# # S3 VPC Endpoint (Gateway type)
# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = aws_vpc.pw_vpc.id
#   service_name      = "com.amazonaws.${var.aws_region}.s3"
#   vpc_endpoint_type = "Gateway"

#   route_table_ids = [
#     aws_route_table.private_route_table_az1.id,
#     aws_route_table.private_route_table_az2.id
#   ]

  
#   tags = merge(
#     var.tags,
#     {
#     Name    = "pw-s3-endpoint-${var.env}"
#     }
#   )
# }

# # CloudWatch Logs VPC Endpoint
# resource "aws_vpc_endpoint" "logs" {
#   vpc_id              = aws_vpc.pw_vpc.id
#   service_name        = "com.amazonaws.${var.aws_region}.logs"
#   vpc_endpoint_type   = "Interface"
#   private_dns_enabled = true

#   subnet_ids = [
#     aws_subnet.private_subnet_az1.id,
#     aws_subnet.private_subnet_az2.id
#   ]

#   security_group_ids = [
#     aws_security_group.ecr_endpoint_sg.id
#   ]

  
#   tags = merge(
#     var.tags,
#     {
#     Name    = "pw-logs-endpoint-${var.env}"
#     }
#   )
# }


# # Data source for ECS tasks security group
# data "aws_security_group" "ecs_tasks_sg" {
#   filter {
#     name   = "tag:Name"
#     values = ["pw-ecs-pulse-sg-${var.env}"]
#   }
# }

# # Security group for VPC endpoints
# resource "aws_security_group" "ecr_endpoint_sg" {
#   name        = "pw-vpc-endpoint-sg-${var.env}"
#   description = "Security group for VPC endpoints"
#   vpc_id      = aws_vpc.pw_vpc.id

#   ingress {
#     description     = "HTTPS from ECS tasks"
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     security_groups = [data.aws_security_group.ecs_tasks_sg.id]  
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }


#   tags = merge(
#     var.tags,
#     {
#     Name    = "pw-ecr-endpoint-sg-${var.env}"
#     }
#   )
# }
