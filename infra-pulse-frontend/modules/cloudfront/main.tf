# Data sources
data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "cloudfront_logs" {
  bucket = "pw-access-logs-${var.env}"
}

# # WAF WebACL for CloudFront
# resource "aws_wafv2_web_acl" "cloudfront_acl" {
#   name        = "pw-cloudfront-pulse-waf-${var.env}"
#   description = "Minimal WAF rules for CloudFront distribution"
#   scope       = "CLOUDFRONT"

#   default_action {
#     allow {}
#   }

#   rule {
#     name     = "AWSManagedRulesCommonRuleSet"
#     priority = 1

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "AWSManagedRulesCommonRuleSet"
#       sampled_requests_enabled   = true
#     }
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "CloudFrontWebACL"
#     sampled_requests_enabled   = true
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-cloudfront-pulse-waf-${var.env}"
#     }
#   )
# }


###################################################################################################

# Create CloudWatch Log Group for WAF logs
resource "aws_cloudwatch_log_group" "waf_log_group" {
  name              = "aws-waf-logs-${var.env}"  # Simplified name format
  retention_in_days = 365
  kms_key_id        = var.kms_key_id 
  
  tags = merge(
    var.tags,
    {
      Name = "pw-waf-logs-${var.env}"
    }
  )
}

# IAM role for WAF to CloudWatch logging
resource "aws_iam_role" "waf_cloudwatch_role" {
  name = "pw-waf-cloudwatch-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "waf.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "waf-cloudwatch-role-${var.env}"
    }
  )
}

# IAM policy for WAF to write to CloudWatch
resource "aws_iam_role_policy" "waf_cloudwatch_policy" {
  name = "waf-cloudwatch-policy-${var.env}"
  role = aws_iam_role.waf_cloudwatch_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.waf_log_group.arn}:*"
      }
    ]
  })
  
}

#################################################
resource "aws_wafv2_web_acl" "cloudfront_acl" {
  name        = "pw-cloudfront-pulse-waf-${var.env}"
  description = "Comprehensive WAF rules for CloudFront distribution"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "pw-waf-rule-${var.env}-region-block"
    priority = 0

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "pw-waf-cloudwatch-metric-${var.env}-region-block"
      sampled_requests_enabled   = true
    }

    statement {
      not_statement {
        statement {
          geo_match_statement {
            country_codes = ["US", "IN"]
          }
        }
      }
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "rate-limit-rule"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit                 = 200
        aggregate_key_type    = "IP"
        evaluation_window_sec = 60
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "pw-waf-cloudwatch-metric-${var.env}-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesBotControlRuleSet"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesBotControlRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "CloudFrontWebACL"
    sampled_requests_enabled   = true
  }

  tags = merge(
    var.tags,
    {
      Name = "pw-cloudfront-pulse-waf-${var.env}"
    }
  )
}

##################################################

# # WAF WebACL with updated logging configuration
# resource "aws_wafv2_web_acl" "cloudfront_acl" {
#   name        = "pw-cloudfront-pulse-waf-${var.env}"
#   description = "Minimal WAF rules for CloudFront distribution"
#   scope       = "CLOUDFRONT"

#   default_action {
#     allow {}
#   }

#   rule {
#     name     = "AWSManagedRulesCommonRuleSet"
#     priority = 1

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name               = "AWSManagedRulesCommonRuleSet"
#       sampled_requests_enabled  = true
#     }
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name               = "CloudFrontWebACL"
#     sampled_requests_enabled  = true
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-cloudfront-pulse-waf-${var.env}"
#     }
#   )
# }

# Enable logging configuration for WAF
resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_log_group.arn]
  resource_arn           = aws_wafv2_web_acl.cloudfront_acl.arn

  logging_filter {
    default_behavior = "KEEP"

    filter {
      behavior = "DROP"
      condition {
        action_condition {
          action = "COUNT"
        }
      }
      requirement = "MEETS_ANY"
    }
  }
}








# Origin Access Control for S3 Bucket
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "pw-pulse-OAC-${var.env}"
  description                       = "Origin Access Control for CloudFront to S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"

  
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront Distribution for ${var.env} environment"
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  aliases             = [var.cloudfront_alias]
  web_acl_id          = aws_wafv2_web_acl.cloudfront_acl.arn
  http_version        = "http2and3"

  origin {
    domain_name              = "pw-pulse-${var.env}.s3.us-east-1.amazonaws.com"
    origin_id                = "pw-pulse-${var.env}.s3.us-east-1.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id

    origin_shield {
      enabled              = true
      origin_shield_region = "us-east-1"
    }

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "pw-pulse-${var.env}.s3.us-east-1.amazonaws.com"
    viewer_protocol_policy = "redirect-to-https"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
    compress    = true

    response_headers_policy_id = "60669652-455b-4ae9-85a4-c4c02393f86c"
  }

  logging_config {
    include_cookies = false
    bucket          = data.aws_s3_bucket.cloudfront_logs.bucket_domain_name
    prefix          = "cloudfront-logs/access-logs-${var.env}"
  }

  # restrictions {
  #   geo_restriction {
  #     restriction_type = "none"
  #   }
  # }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "IN"]  # Only allow United States and India
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  tags = merge(
    var.tags,
    {
      Name = "pw-cloudfront-${var.env}"
    }
  )

  lifecycle {
    ignore_changes = [
      origin,
      default_cache_behavior,
      http_version
    ]
  }
}
###############################################################################################

# resource "aws_wafv2_web_acl" "cloudfront_acl" {
#   name        = "pw-aws_wafv2_web_acl-${var.env}"
#   description = "Minimal WAF rules for CloudFront distribution"
#   scope       = "CLOUDFRONT"

#   default_action {
#     allow {}
#   }

#   rule {
#     name     = "AWSManagedRulesCommonRuleSet"
#     priority = 1

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "AWSManagedRulesCommonRuleSet"
#       sampled_requests_enabled   = true
#     }
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "CloudFrontWebACL"
#     sampled_requests_enabled   = true
#   }
# }

# # Origin Access Control for S3 Bucket
# resource "aws_cloudfront_origin_access_control" "s3_oac" {
#   name                              = "OAC-for-${var.env}-s3-bucket"
#   description                       = "Origin Access Control for CloudFront to S3 bucket"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }

# # CloudFront Distribution
# resource "aws_cloudfront_distribution" "frontend" {
#   enabled             = true
#   is_ipv6_enabled     = true
#   comment             = "CloudFront Distribution for ${var.env} environment"
#   default_root_object = "index.html"
#   price_class         = "PriceClass_All"
#   aliases             = [var.cloudfront_alias]
#   web_acl_id          = aws_wafv2_web_acl.cloudfront_acl.arn
  
#   origin {
#     domain_name              = var.s3_bucket_domain_name
#     origin_id                = var.s3_bucket_domain_name
#     origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
#   }

#   default_cache_behavior {
#     allowed_methods        = ["GET", "HEAD"]
#     cached_methods         = ["GET", "HEAD"]
#     target_origin_id       = var.s3_bucket_domain_name
#     viewer_protocol_policy = "redirect-to-https"
    
#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl     = 0
#     default_ttl = 3600
#     max_ttl     = 86400
#     compress    = true

#     response_headers_policy_id = "60669652-455b-4ae9-85a4-c4c02393f86c"
#   }

#   logging_config {
#     include_cookies = false
#     bucket          = data.aws_s3_bucket.cloudfront_logs.bucket_domain_name
#     prefix          = "cloudfront-logs/access-logs-${var.env}"
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     acm_certificate_arn      = var.acm_certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }

#   custom_error_response {
#     error_code            = 403
#     response_code         = 200
#     response_page_path    = "/index.html"
#     error_caching_min_ttl = 10
#   }

#   custom_error_response {
#     error_code            = 404
#     response_code         = 200
#     response_page_path    = "/index.html"
#     error_caching_min_ttl = 10
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-cloudfront-${var.env}"
#     }
#   )
# }

# data "aws_s3_bucket" "cloudfront_logs" {
#   bucket = "pw-access-logs-${var.env}"
# }

####################################################################################################

# # Data source to fetch existing S3 bucket
# data "aws_s3_bucket" "cloudfront_logs" {
#   bucket = "pw-access-logs-${var.env}"
# }

# # WAF WebACL for CloudFront
# resource "aws_wafv2_web_acl" "cloudfront_acl" {
#   name        = "pw-aws_wafv2_web_acl-${var.env}"
#   description = "Minimal WAF rules for CloudFront distribution"
#   scope       = "CLOUDFRONT"

#   default_action {
#     allow {}
#   }

#   rule {
#     name     = "AWSManagedRulesCommonRuleSet"
#     priority = 1

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "AWSManagedRulesCommonRuleSet"
#       sampled_requests_enabled   = true
#     }
#   }

#   # rule {
#   #   name     = "BlockCommonIPReputationRules"
#   #   priority = 2

#   #   action {
#   #     block {}
#   #   }

#   #   statement {
#   #     managed_rule_group_statement {
#   #       name        = "AWSManagedRulesAmazonIpReputationList"
#   #       vendor_name = "AWS"
#   #     }
#   #   }

#   #   visibility_config {
#   #     cloudwatch_metrics_enabled = true
#   #     metric_name                = "BlockCommonIPReputationRules"
#   #     sampled_requests_enabled   = true
#   #   }
#   # }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "CloudFrontWebACL"
#     sampled_requests_enabled   = true
#   }
# }

# # CloudFront distribution with WAF association
# resource "aws_cloudfront_distribution" "frontend" {
#   comment             = "CloudFront Distribution for ${var.env} environment"
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"
#   default_root_object = "index.html"
#   aliases             = [var.cloudfront_alias]
#   web_acl_id          = aws_wafv2_web_acl.cloudfront_acl.arn

#   origin {
#     domain_name = var.s3_bucket_domain_name
#     origin_id   = var.s3_bucket_domain_name

#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
#     }
#   }

#   default_cache_behavior {
#     allowed_methods        = ["GET", "HEAD"]
#     cached_methods         = ["GET", "HEAD"]
#     target_origin_id       = var.s3_bucket_domain_name
#     viewer_protocol_policy = "redirect-to-https"

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl     = 0
#     default_ttl = 0
#     max_ttl     = 0

#     compress = true
#     response_headers_policy_id = "60669652-455b-4ae9-85a4-c4c02393f86c"
#   }

#   http_version = "http2and3"

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     acm_certificate_arn      = var.acm_certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }

#   logging_config {
#     include_cookies = false
#     bucket          = data.aws_s3_bucket.cloudfront_logs.bucket_domain_name
#     prefix          = "cloudfront-logs/access-logs-${var.env}"
#   }

#   custom_error_response {
#     error_code         = 403
#     response_code      = 200
#     response_page_path = "/index.html"
#     error_caching_min_ttl = 10
#   }

#   custom_error_response {
#     error_code         = 404
#     response_code      = 200
#     response_page_path = "/index.html"
#     error_caching_min_ttl = 10
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-cloudfront-${var.env}"
#     }
#   )
# }

# # CloudFront Origin Access Identity
# resource "aws_cloudfront_origin_access_identity" "oai" {
#   comment = "OAI for ${var.env} CloudFront"
# }


########################################################################################
# # Data source to fetch details of an existing S3 bucket
# data "aws_s3_bucket" "cloudfront_logs" {
#   bucket = "pw-access-logs-${var.env}"  # Replace with the name of your manually created bucket
# }

# # CloudFront Origin Access Control (OAC) resource
# resource "aws_cloudfront_origin_access_control" "oac" {
#   name                      = "pw-cloudfront-oac-${var.env}"
#   description               = "OAC for ${var.env} CloudFront distribution"
#   origin_access_control_origin_type = "s3"
#   signing_behavior          = "always"
#   signing_protocol          = "sigv4"
# }

# # CloudFront distribution with logging enabled and OAC configured
# resource "aws_cloudfront_distribution" "frontend" {
#   comment             = "CloudFront Distribution for ${var.env} environment"
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"
#   default_root_object = "index.html"
#   aliases             = [var.cloudfront_alias]

#   origin {
#     domain_name             = var.s3_bucket_domain_name
#     origin_id               = var.s3_bucket_domain_name
#     origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
#   }

#   default_cache_behavior {
#     allowed_methods        = ["GET", "HEAD"]
#     cached_methods         = ["GET", "HEAD"]
#     target_origin_id       = var.s3_bucket_domain_name
#     viewer_protocol_policy = "redirect-to-https"

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl     = 0
#     default_ttl = 0
#     max_ttl     = 0

#     compress = true

#     response_headers_policy_id = "60669652-455b-4ae9-85a4-c4c02393f86c"
#   }

#   http_version = "http2and3"

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     acm_certificate_arn      = var.acm_certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }

#   # Enable CloudFront logging
#   logging_config {
#     include_cookies = false
#     bucket          = data.aws_s3_bucket.cloudfront_logs.bucket_domain_name
#     prefix          = "cloudfront-logs/access-logs-${var.env}"
#   }

#   # Custom error responses
#   custom_error_response {
#     error_code         = 403
#     response_code      = 200
#     response_page_path = "/index.html"
#     error_caching_min_ttl = 10
#   }

#   custom_error_response {
#     error_code         = 404
#     response_code      = 200
#     response_page_path = "/index.html"
#     error_caching_min_ttl = 10
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-cloudfront-${var.env}"
#     }
#   )
# }


###################################################################################################


# # Data source to fetch details of an existing S3 bucket
# data "aws_s3_bucket" "cloudfront_logs" {
#   bucket = "pw-access-logs-${var.env}"  # Replace with the name of your manually created bucket
# }

# # CloudFront distribution with logging enabled
# resource "aws_cloudfront_distribution" "frontend" {
#   comment             = "CloudFront Distribution for ${var.env} environment"
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"
#   default_root_object = "index.html"
#   aliases             = [var.cloudfront_alias]

#   origin {
#     domain_name = var.s3_bucket_domain_name
#     origin_id   = var.s3_bucket_domain_name

#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
#     }
#   }

#   default_cache_behavior {
#     allowed_methods        = ["GET", "HEAD"]
#     cached_methods         = ["GET", "HEAD"]
#     target_origin_id       = var.s3_bucket_domain_name
#     viewer_protocol_policy = "redirect-to-https"

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl     = 0
#     default_ttl = 0
#     max_ttl     = 0

#     compress = true

#     response_headers_policy_id = "60669652-455b-4ae9-85a4-c4c02393f86c"
#   }

#   http_version = "http2and3"

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     acm_certificate_arn      = var.acm_certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }

#   # Enable CloudFront logging
#   logging_config {
#   include_cookies = false
#   bucket          = data.aws_s3_bucket.cloudfront_logs.bucket_domain_name
#   prefix          = "cloudfront-logs/access-logs-${var.env}"
# }

#   # Custom error responses
#   custom_error_response {
#     error_code         = 403
#     response_code      = 200
#     response_page_path = "/index.html"
#     error_caching_min_ttl = 10
#   }

#   custom_error_response {
#     error_code         = 404
#     response_code      = 200
#     response_page_path = "/index.html"
#     error_caching_min_ttl = 10
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-cloudfront-${var.env}"
#     }
#   )
# }

# # CloudFront Origin Access Identity
# resource "aws_cloudfront_origin_access_identity" "oai" {
#   comment = "OAI for ${var.env} CloudFront"
# }





# # # CloudFront Origin Access Control (OAC)
# # resource "aws_cloudfront_origin_access_control" "oac" {
# #   name                     = "OAC for ${var.env} CloudFront"
# #   description              = "OAC for CloudFront to access S3 bucket"
# #   origin_access_control_type = "s3"
# #   signing_behavior         = "always"
# #   signing_region           = "us-east-1"  # Adjust the region as needed
# # }


##########################################################################################################

# resource "aws_cloudfront_distribution" "frontend" {
#   comment             = "CloudFront Distribution for ${var.env} environment"
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"  # Use only North America and Europe
#   default_root_object = "index.html"
#   aliases             = [var.cloudfront_alias]

#   origin {
#     domain_name = var.s3_bucket_domain_name
#     origin_id   = var.s3_bucket_domain_name

#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
#     }
#   }

#   default_cache_behavior {
#     allowed_methods        = ["GET", "HEAD"]
#     cached_methods         = ["GET", "HEAD"]
#     target_origin_id       = var.s3_bucket_domain_name
#     viewer_protocol_policy = "redirect-to-https"

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl     = 0
#     default_ttl = 0
#     max_ttl     = 0

#     # Re-enable compression
#     compress = true

#     # Restore response headers policy
#     response_headers_policy_id = "60669652-455b-4ae9-85a4-c4c02393f86c"
#   }

#   http_version        = "http2and3"

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     acm_certificate_arn      = var.acm_certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }

#   # Re-add custom error responses for 403 and 404
#   custom_error_response {
#     error_code         = 403
#     response_code      = 200
#     response_page_path = "/index.html"
#     error_caching_min_ttl = 10
#   }

#   custom_error_response {
#     error_code         = 404
#     response_code      = 200
#     response_page_path = "/index.html"
#     error_caching_min_ttl = 10
#   }

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-cloudfront-${var.env}"
#     }
#   )
# }

# resource "aws_cloudfront_origin_access_identity" "oai" {
#   comment = "OAI for ${var.env} CloudFront"
# }


###################################################################################################


# resource "aws_cloudfront_distribution" "frontend" {
#   comment             = "CloudFront Distribution for ${var.env} environment"
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"  # Use only North America and Europe
#   default_root_object = "index.html"
#   aliases             = [var.cloudfront_alias]

#   origin {
#     domain_name = var.s3_bucket_domain_name
#     origin_id   = var.s3_bucket_domain_name

#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
#     }
#   }

#   default_cache_behavior {
#     allowed_methods        = ["GET", "HEAD"]
#     cached_methods         = ["GET", "HEAD"]
#     target_origin_id       = var.s3_bucket_domain_name
#     viewer_protocol_policy = "redirect-to-https"

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl     = 0
#     default_ttl = 0
#     max_ttl     = 0
#   }

#   # Allow both HTTP/2 and HTTP/3
#   http_version        = "http2and3"

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     acm_certificate_arn      = var.acm_certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }


#   # Enable WAFv2 association
#   # web_acl_id = aws_wafv2_web_acl.cloudfront_waf.arn  # Add the WAFv2 Web ACL ARN



# #  # Enable logging
# #   logging_config {
# #     include_cookies = false
# #     bucket          = var.logging_bucket  # Specify your logging bucket variable
# #     prefix          = "${var.env}/cloudfront-logs/"  # Specify a prefix for your logs
# #   }


  

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-cloudfront-${var.env}"
#     }
#   )
# }

# resource "aws_cloudfront_origin_access_identity" "oai" {
#   comment = "OAI for ${var.env} CloudFront"
# }


# ####################################################################################################

# # WAFv2 Web ACL
# # resource "aws_wafv2_web_acl" "cloudfront_waf" {
# #   name        = "${var.env}-cloudfront-waf"
# #   scope       = "CLOUDFRONT"  # Specify CloudFront as the scope
# #   description = "WAF for CloudFront distribution in ${var.env}"

# #   default_action {
# #     allow {}
# #   }

# #   rule {
# #     name     = "block-bad-requests"
# #     priority = 1

# #     statement {
# #       byte_match_statement {
# #         search_string = "bad-request"
# #         field_to_match {
# #           method {}
# #         }

# #         text_transformation {
# #           priority = 0
# #           type     = "NONE"
# #         }
# #         positional_constraint = "EXACTLY"
# #       }
# #     }

# #     action {
# #       block {}
# #     }

# #      visibility_config {
# #       sampled_requests_enabled    = true
# #       cloudwatch_metrics_enabled  = true
# #       metric_name                 = "block-bad-requests"
# #     }
# #   }

# #   visibility_config {
# #     cloudwatch_metrics_enabled  = true
# #     metric_name                 = "${var.env}-waf-metrics"
# #     sampled_requests_enabled    = true
# #   }
# # }