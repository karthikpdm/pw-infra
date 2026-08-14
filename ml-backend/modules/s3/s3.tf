resource "aws_s3_bucket" "bucket_training_data" {
  bucket = var.s3_bucket_input_training_path
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "bucket_training_data" {
  bucket = aws_s3_bucket.bucket_training_data.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket" "bucket_output_models" {
  bucket = var.s3_bucket_output_models_path
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "bucket_output_models" {
  bucket = aws_s3_bucket.bucket_output_models.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket" "ml" {
  bucket = var.s3_bucket_ml
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "ml" {
  bucket = aws_s3_bucket.ml.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "ml_bucket_policy" {
  bucket = aws_s3_bucket.ml.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Allow SageMaker Execution Role
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::767397709508:role/pwmy-trianz-dev-sagemaker-execution-role"
        },
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.ml.id}",  # Root level
          "arn:aws:s3:::${aws_s3_bucket.ml.id}/*" # Objects in bucket
        ]
      },
      # Allow Cross-Account Infrastructure Role
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
        },
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.ml.id}",  # Root level
          "arn:aws:s3:::${aws_s3_bucket.ml.id}/*" # Objects in bucket
        ]
      }
    ]
  })
}







