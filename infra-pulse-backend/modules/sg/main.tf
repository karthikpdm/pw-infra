


# Data sources for existing VPC components
data "aws_vpc" "pw_vpc" {
  filter {
    name   = "tag:Name"
    values = ["pw-vpc-${var.env}"]
  }
}

# Security Group for ECS
resource "aws_security_group" "ecs_pulse" {
  name        = "${var.project_name}-ecs-pulse-sg-${var.env}"
  description = "Security group for ECS tasks"
  vpc_id      = data.aws_vpc.pw_vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 4000
    to_port         = 4000
    security_groups = [aws_security_group.alb-pulse.id]
    description     = "Allow inbound traffic from ALB on port 4000"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.alb-pulse.id]
    description     = "Allow inbound HTTP traffic from ALB"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

 

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ecs-pulse-sg-${var.env}"
    }
  )
}

# Security Group for ALB
resource "aws_security_group" "alb-pulse" {
  name        = "${var.project_name}-alb-pulse-sg-${var.env}"
  description = "Security group for ALB pulse"
  vpc_id      = data.aws_vpc.pw_vpc.id

 

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-alb-pulse-sg-${var.env}"
    }
  )

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound HTTP traffic"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound HTTPS traffic"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# Additional egress rule for ALB to ECS communication
resource "aws_security_group_rule" "alb_to_ecs" {
  type                     = "egress"
  from_port                = 4000
  to_port                  = 4000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb-pulse.id
  source_security_group_id = aws_security_group.ecs_pulse.id
  description              = "Allow outbound traffic from ALB to ECS tasks on port 4000"
}

resource "aws_security_group_rule" "alb_to_ecs_http" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb-pulse.id
  source_security_group_id = aws_security_group.ecs_pulse.id
  description              = "Allow outbound HTTP traffic from ALB to ECS tasks"
}
