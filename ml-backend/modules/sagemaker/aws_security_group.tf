resource "aws_security_group" "sagemaker_model_sg" {
  name        = "${var.project_name}-${var.env}-sagemaker-model-sg"
  description = "Security group for SageMaker model"
  vpc_id      = data.aws_vpc.pw_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [] # Define allowed CIDR blocks if necessary
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound traffic
  }

  tags = var.tags
}
