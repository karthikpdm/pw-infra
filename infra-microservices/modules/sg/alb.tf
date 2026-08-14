# Security Group for EKS alb
resource "aws_security_group" "alb-ingress_sg" {
  name        = "${var.project_name}-eks-alb-sg-${var.env}"
  description = "Security group for EKS worker nodes"
  vpc_id      = data.aws_vpc.pw_vpc.id

  tags = merge(
    { "Name"    = "${var.project_name}-eks-alb-sg-${var.env}" },
    var.map_tagging
  )

  dynamic "ingress" {
    for_each = var.eks_alb_ingress_rules
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      security_groups  = ingress.value.security_groups
      description      = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = var.eks_alb_egress_rules
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      description      = egress.value.description
    }
  }
}


###################################################################################################

# Security Group for internal-websocket alb

# Data source to reference existing Lambda security group
data "aws_security_group" "lambda_sg" {
    name = "pw-sg-${var.env}-lambda"
}


#  Security Group for Internal-websocket ALB
resource "aws_security_group" "internal_websocket_alb_sg" {
  name        = "${var.project_name}-internal-websocket-alb-sg-${var.env}"
  description = "Security group for internal ALB accessed by Lambda"
  vpc_id      = data.aws_vpc.pw_vpc.id
  
  tags = merge(
    { "Name" = "${var.project_name}-internal-websocket-alb-sg-${var.env}" },
    var.map_tagging
  )
  
  # Allow HTTP/HTTPS from Lambda security group
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [data.aws_security_group.lambda_sg.id]  
    description     = "Allow HTTP traffic from Lambda"
  }
  
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [data.aws_security_group.lambda_sg.id]  
    description     = "Allow HTTPS traffic from Lambda"
  }
  
  # Allow all outbound traffic to EKS worker nodes
  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [var.eks_workers_sg_id]
    description     = "Allow traffic to EKS workers"
  }
}