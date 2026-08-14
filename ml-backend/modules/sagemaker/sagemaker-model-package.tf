# Role for Model Registration
resource "aws_iam_role" "pwmy_sagemaker_model_registry_role" {
  name = "${var.project_name}-${var.env}-sagemaker-model-registry-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "sagemaker.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "pwmy_sagemaker_model_registry_policy" {
  name = "${var.project_name}-${var.env}-sagemaker-model-registry-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sagemaker:DescribeModelPackage",
          "sagemaker:CreateModelPackage",
          "sagemaker:ListModelPackages",
          "sagemaker:DeleteModelPackage"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "model_registry_policy_attach" {
  role       = aws_iam_role.pwmy_sagemaker_model_registry_role.name
  policy_arn = aws_iam_policy.pwmy_sagemaker_model_registry_policy.arn
}

resource "aws_sagemaker_model_package_group" "pwmy_model_registry" {
  model_package_group_name  = var.model_registry_name
  model_package_group_description = var.model_registry_description
  tags = var.tags
}

# resource "aws_sagemaker_model_package" "model_package" {
#   name                     = var.model_name
#   model_package_group_name  = aws_sagemaker_model_package_group.pwmy_model_registry.name
#   model_data_url            = var.model_artifact_s3_path
#   image_uri                 = var.model_image_uri
#   model_package_description = "ML model package for training and deployment"
# }