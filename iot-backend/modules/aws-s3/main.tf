# Source Bucket-----------------------------------------------
resource "aws_s3_bucket" "ml_source" {
  bucket = "tf-pw-fleet-ml-detection-${var.env}"
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "ml_source" {
  bucket = aws_s3_bucket.ml_source.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "fleet_ml_detection_policy" {
  bucket = aws_s3_bucket.ml_source.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowMediaConvertAccess",
        Effect = "Allow",
        Principal = {
          Service = "mediaconvert.amazonaws.com"
        },
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
            aws_s3_bucket.ml_source.arn,
            "${aws_s3_bucket.ml_source.arn}/*"
        ]
      }
    ]
  })
}

# Destination bucket-----------------------------------
resource "aws_s3_bucket" "ml_destination" {
  bucket = "tf-pw-fleet-ml-detection-output-${var.env}"
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "ml_destination" {
  bucket = aws_s3_bucket.ml_destination.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "fleet_ml_detection_des_policy" {
  bucket = aws_s3_bucket.ml_destination.id
  

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "PolicyForCloudFrontPrivateContent",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
            aws_s3_bucket.ml_destination.arn,
            "${aws_s3_bucket.ml_destination.arn}/*"
        ],
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}


resource "aws_s3_bucket_cors_configuration" "ml_destination" {
  bucket = aws_s3_bucket.ml_destination.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }
}

# Cloudfront resources----------------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "s3_distribution" {
  name                              = "${aws_s3_bucket.ml_destination.bucket}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
    s3_origin_id = "pw-fleet-ml"
}

resource "aws_cloudfront_cache_policy" "s3_distribution_policy" {
  name        = "pw-fleet-policy"
  default_ttl = 50 #---------Discussion req
  max_ttl     = 100
  min_ttl     = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.ml_destination.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_distribution.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    cache_policy_id = aws_cloudfront_cache_policy.s3_distribution_policy.id
    
    ##viewer_protocol_policy = "allow-all"
    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 3600
    }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  tags = var.tags

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# S3 Log bucket-----------------------------------------------------------
resource "aws_s3_bucket" "s3_fleet_logging" {
  bucket = "pw-fleet-s3-logging-${var.env}"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "versioning_s3_logging" {
  bucket = aws_s3_bucket.s3_fleet_logging.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "ml_source" {
  bucket = aws_s3_bucket.ml_source.id
  target_bucket = aws_s3_bucket.s3_fleet_logging.id
  target_prefix = "${aws_s3_bucket.ml_source.bucket}-log/"
}

resource "aws_s3_bucket_logging" "ml_destination" {
  bucket = aws_s3_bucket.ml_destination.id
  target_bucket = aws_s3_bucket.s3_fleet_logging.id
  target_prefix = "${aws_s3_bucket.ml_destination.bucket}-log/"
}