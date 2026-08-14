data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["pw-vpc-${var.env}"]  
  }
}


# Create a security group for Lambda functions
resource "aws_security_group" "lambda_sg" {
  name        = "pw-sg-${var.env}-datalake"
  description = "Security group for Lambda functions"
  vpc_id      = data.aws_vpc.selected.id

  # Outbound rules - allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # No inbound rules by default since Lambda functions don't need incoming traffic
  # Add specific inbound rules only if other services need to communicate with Lambda

  tags = merge(
    var.tags,
    {
      Name = "pw-sg-${var.env}-datalake"
    }
  )
}



##################################################################################################



resource "aws_security_group" "glue_sg" {
  name        = "pw-${var.env}-amcs-sg"
  description = "pw amcs"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "pw-amcs-sg"
  }
}

# Inbound rule 1: Allow TCP on all ports from sgr-00f2e8163f8720030
# resource "aws_security_group_rule" "inbound_tcp_all" {
#   security_group_id = aws_security_group.glue_sg.id
#   type              = "ingress"
#   from_port         = 0
#   to_port           = 65535
#   protocol          = "tcp"
#   source_security_group_id = "sgr-00f2e8163f8720030"
#   description       = ""
# }

# Inbound rule 2: Allow all traffic from VPC CIDR
resource "aws_security_group_rule" "inbound_all_traffic" {
  security_group_id = aws_security_group.glue_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  # All protocols
  cidr_blocks       = ["0.0.0.0/0"]
  # cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  description       = ""
}

# Since the screenshot shows 3 outbound permission entries, but doesn't show details,
# I'll add a standard outbound rule that allows all traffic
resource "aws_security_group_rule" "outbound_all" {
  security_group_id = aws_security_group.glue_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  # All protocols
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}
