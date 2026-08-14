##resource "aws_iam_role" "pwmy_sagemaker_endpoint_execution_role" {
##  name = "${var.project_name}-${var.env}-sagemaker-endpoint-execution-role"

##  assume_role_policy = jsonencode({
##    Version = "2012-10-17"
##    Statement = [
##      {
##        Effect = "Allow"
##        Principal = {
##          Service = "sagemaker.amazonaws.com"
##        }
##        Action = "sts:AssumeRole"
##      }
##    ]
##  })
##}

##resource "aws_iam_policy" "pwmy_sagemaker_endpoint_policy" {
##  name = "${var.project_name}-${var.env}-sagemaker-endpoint-policy"

##  policy = jsonencode({
##    Version = "2012-10-17"
##    Statement = [
##      {
##        Effect = "Allow",
##        Action = [
##          "s3:GetObject",
##         "s3:PutObject",
##          "cloudwatch:*",
##          "ecr:BatchGetImage",
##          "ecr:GetDownloadUrlForLayer",
##          "ecr:DescribeImages"
##        ],
##        Resource = [
##         "arn:aws:s3:::${var.s3_bucket_input_training_path}/*",
##          "arn:aws:s3:::${var.s3_bucket_output_models_path}/*",
##          "arn:aws:ecr:us-east-1:763104351884:repository/pwmy-trianz-dev-ml-ecr-repository"
##        ]
##      }
##    ]
##  })
##}

##resource "aws_iam_role_policy_attachment" "pwmy_endpoint_policy_attach" {
##  role       = aws_iam_role.pwmy_sagemaker_endpoint_execution_role.name
##  policy_arn = aws_iam_policy.pwmy_sagemaker_endpoint_policy.arn
##}


# SageMaker Endpoint Configuration
#resource "aws_sagemaker_endpoint_configuration" "pwmy_sagemaker_endpoint_config" {
#  name = "${var.model_name}-endpoint-config"

#  production_variants {
#    variant_name           = "AllTraffic"
#    model_name             = aws_sagemaker_model.pwmy_model.name
#    initial_instance_count = var.initial_instance_count
#    instance_type          = var.instance_type
#  }
#}

# SageMaker Endpoint
#resource "aws_sagemaker_endpoint" "endpoint" {
#  name                  = "${var.model_name}-endpoint"
#  endpoint_config_name  = aws_sagemaker_endpoint_configuration.pwmy_sagemaker_endpoint_config.name
#}

# SageMaker Endpoint Configuration
##resource "aws_sagemaker_endpoint_configuration" "pwmy_sagemaker_endpoint_config" {
##  name = "${var.model_name}-endpoint-config"

##  production_variants {
##    variant_name           = "AllTraffic"
##    model_name             = aws_sagemaker_model.pwmy_model.name
##    initial_instance_count = var.initial_instance_count
##    instance_type          = var.instance_type
##  }
##}

# SageMaker Endpoint
##resource "aws_sagemaker_endpoint" "endpoint" {
##  name                 = "${var.model_name}-endpoint"
##  endpoint_config_name = aws_sagemaker_endpoint_configuration.pwmy_sagemaker_endpoint_config.name

##  # Lifecycle management to prevent accidental destruction or recreation
##  lifecycle {
##    prevent_destroy = true
##    ignore_changes  = [
##      endpoint_config_name
##    ]
##  }
##}
