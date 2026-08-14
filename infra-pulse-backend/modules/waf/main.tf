###########################################################################################
# Create CloudWatch Log Group for WAF logs
resource "aws_cloudwatch_log_group" "alb_waf_log_group" {
  name              = "aws-waf-logs-alb-${var.env}"
  retention_in_days = 365
  kms_key_id        = var.kms_key_id 
  
  tags = merge(
    var.tags,
    {
      Name = "aws-waf-logs-alb-${var.env}"
    }
  )
}

##################################################################################################


# IAM role for WAF to CloudWatch logging
resource "aws_iam_role" "alb_waf_cloudwatch_role" {
  name = "pw-waf-alb-cloudwatch-roles-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "wafv2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "pw-waf-alb-cloudwatch-roles-${var.env}"
    }
  )
}

# IAM policy for WAF to write to CloudWatch
resource "aws_iam_role_policy" "alb_waf_cloudwatch_policy" {
  name = "pw-waf-cloudwatch-alb-${var.env}"
  role = aws_iam_role.alb_waf_cloudwatch_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Resource = "${aws_cloudwatch_log_group.alb_waf_log_group.arn}:*"
      }
    ]
  })
}




resource "aws_wafv2_web_acl_logging_configuration" "alb_waf_logging" {
  log_destination_configs = [
    aws_cloudwatch_log_group.alb_waf_log_group.arn
  ]
  resource_arn = aws_wafv2_web_acl.pulse_alb.arn

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



##############################################################################################


resource "aws_wafv2_web_acl" "pulse_alb" {
  name        = "${var.project_name}-alb-pulse-waf-${var.env}"
  description = "WAF Web ACL for Pulse ALB"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "pw-waf-cloudwatch-metric-${var.env}"
    sampled_requests_enabled   = true
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
    name     = "enable-captcha"
    priority = 1

    action {
      allow {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "pw-waf-cloudwatch-metric-${var.env}-enable-captcha"
      sampled_requests_enabled   = true
    }

    statement {
      geo_match_statement {
        country_codes = ["US", "IN"]
      }
    }

  
  }

  
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

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

  rule {
    name     = "rate-limit-rule"
    priority = 5

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

  tags = var.tags
}



# Associate WAF Web ACL with the ALB
resource "aws_wafv2_web_acl_association" "pulse_alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.pulse_alb.arn
}
