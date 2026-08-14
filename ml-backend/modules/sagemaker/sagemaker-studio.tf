data "aws_vpc" "pw_vpc" {
  filter {
    name   = "tag:Name"
    values = ["pw-vpc-${var.env}"]
  }
}

data "aws_subnet" "private_subnet_az1" {
  filter {
    name   = "tag:Name"
    values = ["pw-private-subnet-az1-${var.env}"]
  }
}

data "aws_subnet" "private_subnet_az2" {
  filter {
    name   = "tag:Name"
    values = ["pw-private-subnet-az2-${var.env}"]
  }
}


resource "aws_sagemaker_domain" "pwmy_studio_domain" {
  domain_name = "${var.project_name}-${var.env}-studio-domain"
  auth_mode   = "IAM"
  vpc_id      = data.aws_vpc.pw_vpc.id
  subnet_ids  = [data.aws_subnet.private_subnet_az1.id, data.aws_subnet.private_subnet_az2.id]

  default_user_settings {
    execution_role = aws_iam_role.pwmy_sagemaker_execution_role.arn
  }

  tags = var.tags
}

resource "aws_sagemaker_user_profile" "pwmy_studio_user" {
  domain_id = aws_sagemaker_domain.pwmy_studio_domain.id
  user_profile_name = "${var.project_name}-${var.env}-user-profile"
  tags = var.tags
}

resource "aws_iam_role" "pwmy_sagemaker_execution_role" {
  name = "${var.project_name}-${var.env}-sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "sagemaker.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      },
      {
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

 

# SageMaker Policy for accessing S3 (for input/output paths)
resource "aws_iam_policy" "pwmy_sagemaker_policy" {
  name = "${var.project_name}-${var.env}-sagemaker-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:*",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_input_training_path}/*",
          "arn:aws:s3:::${var.s3_bucket_output_models_path}/*",
          "arn:aws:s3:::${var.s3_bucket_ml}",
          "arn:aws:s3:::${var.s3_bucket_ml}/*"
        ]
      }
    ]
  })
}

# Attach the Policy to the Role
resource "aws_iam_role_policy_attachment" "pwmy_sagemaker_policy_attach" {
  role       = aws_iam_role.pwmy_sagemaker_execution_role.name
  policy_arn = aws_iam_policy.pwmy_sagemaker_policy.arn
}

resource "aws_iam_role_policy_attachment" "pwmy_canvas_aiservices_access" {
  role       = aws_iam_role.pwmy_sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerCanvasAIServicesAccess"
}

resource "aws_iam_role_policy_attachment" "pwmy_canvas_dataprep_access" {
  role       = aws_iam_role.pwmy_sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerCanvasDataPrepFullAccess"
}

resource "aws_iam_role_policy_attachment" "pwmy_canvas_sagemaker_access" {
  role       = aws_iam_role.pwmy_sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerCanvasFullAccess"
}

resource "aws_iam_role_policy_attachment" "pwmy_sagemaker_fullaccess" {
  role       = aws_iam_role.pwmy_sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy_attachment" "pwmy_sagemaker_servicecatalog_access" {
  role       = aws_iam_role.pwmy_sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerAdmin-ServiceCatalogProductsServiceRolePolicy"
}

resource "aws_iam_role_policy" "ecr_full_access_inline" {
  role = aws_iam_role.pwmy_sagemaker_execution_role.name
  name = "ECRFullAccessPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Statement1",
        Effect = "Allow",
        Action = [
          "ecr:*"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}

