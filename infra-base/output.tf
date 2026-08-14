output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.pw_vpc.id
}

output "public_subnet_az1_id" {
  description = "The ID of the public subnet in the first availability zone"
  value       = aws_subnet.public_subnet_az1.id
}

output "public_subnet_az2_id" {
  description = "The ID of the public subnet in the second availability zone"
  value       = aws_subnet.public_subnet_az2.id
}

output "private_subnet_az1_id" {
  description = "The ID of the private subnet in the first availability zone"
  value       = aws_subnet.private_subnet_az1.id
}

output "private_subnet_az2_id" {
  description = "The ID of the private subnet in the second availability zone"
  value       = aws_subnet.private_subnet_az2.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id]
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
}


output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.pw_internet_gateway.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat_gateway.id
}

output "eip_id" {
  description = "The ID of the Elastic IP"
  value       = aws_eip.nat_eip.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public_route_table.id
}

output "private_route_table_az1_id" {
  description = "The ID of the private route table for AZ1"
  value       = aws_route_table.private_route_table_az1.id
}

output "private_route_table_az2_id" {
  description = "The ID of the private route table for AZ2"
  value       = aws_route_table.private_route_table_az2.id
}


# # Outputs
# output "ssm_vpc_endpoint_id" {
#   value       = aws_vpc_endpoint.ssm.id
#   description = "The ID of the SSM VPC endpoint"
# }

# output "ssmmessages_vpc_endpoint_id" {
#   value       = aws_vpc_endpoint.ssmmessages.id
#   description = "The ID of the SSM Messages VPC endpoint"
# }

# output "ec2messages_vpc_endpoint_id" {
#   value       = aws_vpc_endpoint.ec2messages.id
#   description = "The ID of the EC2 Messages VPC endpoint"
# }
