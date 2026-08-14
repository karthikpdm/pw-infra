resource "aws_iam_role" "pwmy_sagemaker_model_execution_role" {
  name = "${var.project_name}-${var.env}-sagemaker-model-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "pwmy_sagemaker_model_policy" {
  name = "${var.project_name}-${var.env}-sagemaker-model-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "cloudwatch:*",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeImages"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_input_training_path}/*",
          "arn:aws:s3:::${var.s3_bucket_output_models_path}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pwmy_model_policy_attach" {
  role       = aws_iam_role.pwmy_sagemaker_model_execution_role.name
  policy_arn = aws_iam_policy.pwmy_sagemaker_model_policy.arn
}

# SageMaker Model
resource "aws_sagemaker_model" "pwmy_model" {
  name                 = var.model_name
  execution_role_arn   = aws_iam_role.pwmy_sagemaker_model_execution_role.arn

  primary_container {
    image           = var.model_image_uri
    # model_data_url  = var.model_artifact_s3_path
  }
   
   vpc_config {
    subnets         = [data.aws_subnet.private_subnet_az1.id, data.aws_subnet.private_subnet_az2.id]
    security_group_ids = [aws_security_group.sagemaker_model_sg.id]
  }


  tags = var.tags
}