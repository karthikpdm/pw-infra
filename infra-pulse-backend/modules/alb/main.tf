data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
# Data sources for existing VPC components
data "aws_vpc" "pw_vpc" {
  filter {
    name   = "tag:Name"
    values = ["pw-vpc-${var.env}"]
  }
}

data "aws_subnet" "public_subnet_az1" {
  filter {
    name   = "tag:Name"
    values = ["pw-public-subnet-az1-${var.env}"]
  }
}

data "aws_subnet" "public_subnet_az2" {
  filter {
    name   = "tag:Name"
    values = ["pw-public-subnet-az2-${var.env}"]
  }
}

# Data source to fetch details of an existing S3 bucket
data "aws_s3_bucket" "pulse_alb_logs" {
  bucket = "pw-access-logs-${var.env}"
}


#############################################################################################################################


# Application Load Balancer
resource "aws_lb" "pulse" {
  name                       = "${var.project_name}-alb-pulse-${var.env}"
  internal                   = false
  load_balancer_type        = "application"
  security_groups           = [var.alb_security_group]
  subnets                   = [
    data.aws_subnet.public_subnet_az1.id,
    data.aws_subnet.public_subnet_az2.id
  ]
  drop_invalid_header_fields = true
  enable_deletion_protection = true
  idle_timeout              = 60
  enable_http2              = true
  
  access_logs {
    enabled = true
    bucket  = data.aws_s3_bucket.pulse_alb_logs.bucket
    prefix  = "pulse-alb-logs/access-logs-${var.env}"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-alb-pulse"
    }
  )
}

###############################################################################################

# ALB Listener for HTTPS (Port 443)
resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_lb.pulse.arn
  port              = "443"
  protocol          = "HTTPS"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pulse.arn
  }
  tags = var.tags
}

##################################################################################################

# ALB Target Group
resource "aws_lb_target_group" "pulse" {
  name        = "${var.project_name}-tg-pulse-${var.env}"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.pw_vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval           = "30"
    protocol           = "HTTP"
    matcher            = "200"
    timeout            = "3"
    path               = "/health"
    unhealthy_threshold = "2"
  }
 
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-tg-pulse"
    }
  )
}

##################################################################################################


resource "aws_lb_listener_rule" "pulse_https_rule" {
  listener_arn = aws_lb_listener.listener_https.arn
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pulse.arn
  }

  condition {
    path_pattern {
      values = ["/pulseapi"]
    }
  }

  tags = var.tags
}


# ###########################################################################################
# # Create CloudWatch Log Group for WAF logs
# resource "aws_cloudwatch_log_group" "alb_waf_log_group" {
#   name              = "aws-waf-logs-alb-${var.env}"
#   retention_in_days = 30
  
#   tags = merge(
#     var.tags,
#     {
#       Name = "aws-waf-logs-alb-${var.env}"
#     }
#   )
# }

# ##################################################################################################


# # IAM role for WAF to CloudWatch logging
# resource "aws_iam_role" "alb_waf_cloudwatch_role" {
#   name = "pw-waf-alb-cloudwatch-roles-${var.env}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "wafv2.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-waf-alb-cloudwatch-roles-${var.env}"
#     }
#   )
# }

# # IAM policy for WAF to write to CloudWatch
# resource "aws_iam_role_policy" "alb_waf_cloudwatch_policy" {
#   name = "pw-waf-cloudwatch-alb-${var.env}"
#   role = aws_iam_role.alb_waf_cloudwatch_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "logs:CreateLogGroup"
#         ]
#         Resource = "${aws_cloudwatch_log_group.alb_waf_log_group.arn}:*"
#       }
#     ]
#   })
# }




# resource "aws_wafv2_web_acl_logging_configuration" "alb_waf_logging" {
#   log_destination_configs = [
#     aws_cloudwatch_log_group.alb_waf_log_group.arn
#   ]
#   resource_arn = aws_wafv2_web_acl.pulse_alb.arn

#   logging_filter {
#     default_behavior = "KEEP"

#     filter {
#       behavior = "DROP"
#       condition {
#         action_condition {
#           action = "COUNT"
#         }
#       }
#       requirement = "MEETS_ANY"
#     }
#   }
# }



# ##############################################################################################


# resource "aws_wafv2_web_acl" "pulse_alb" {
#   name        = "${var.project_name}-alb-pulse-waf-${var.env}"
#   description = "WAF Web ACL for Pulse ALB"
#   scope       = "REGIONAL"

#   default_action {
#     allow {}
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "pw-waf-cloudwatch-metric-${var.env}"
#     sampled_requests_enabled   = true
#   }

#   rule {
#     name     = "pw-waf-rule-${var.env}-region-block"
#     priority = 0

#     action {
#       block {}
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "pw-waf-cloudwatch-metric-${var.env}-region-block"
#       sampled_requests_enabled   = true
#     }

#     statement {
#       not_statement {
#         statement {
#           geo_match_statement {
#             country_codes = ["US", "IN"]
#           }
#         }
#       }
#     }
#   }

#   rule {
#     name     = "enable-captcha"
#     priority = 1

#     action {
#       allow {}
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "pw-waf-cloudwatch-metric-${var.env}-enable-captcha"
#       sampled_requests_enabled   = true
#     }

#     statement {
#       geo_match_statement {
#         country_codes = ["US", "IN"]
#       }
#     }

  
#   }

  
#   rule {
#     name     = "AWSManagedRulesCommonRuleSet"
#     priority = 2

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

#   rule {
#     name     = "AWSManagedRulesAmazonIpReputationList"
#     priority = 3

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesAmazonIpReputationList"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "AWSManagedRulesAmazonIpReputationList"
#       sampled_requests_enabled   = true
#     }
#   }

#   rule {
#     name     = "AWSManagedRulesBotControlRuleSet"
#     priority = 4

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesBotControlRuleSet"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "AWSManagedRulesBotControlRuleSet"
#       sampled_requests_enabled   = true
#     }
#   }

#   rule {
#     name     = "rate-limit-rule"
#     priority = 5

#     action {
#       block {}
#     }

#     statement {
#       rate_based_statement {
#         limit                 = 200
#         aggregate_key_type    = "IP"
#         evaluation_window_sec = 60
#       }
#     }
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "pw-waf-cloudwatch-metric-${var.env}-rate-limit"
#       sampled_requests_enabled   = true
#     }
#   }

#   tags = var.tags
# }



# # Associate WAF Web ACL with the ALB
# resource "aws_wafv2_web_acl_association" "pulse_alb" {
#   resource_arn = aws_lb.pulse.arn
#   web_acl_arn  = aws_wafv2_web_acl.pulse_alb.arn
# }

# # Create IAM role for Firehose
# resource "aws_iam_role" "firehose_role" {
#   name = "pw-waf-logs-firehose-role-${var.env}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "firehose.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = var.tags
# }

# # S3 permissions for Firehose
# resource "aws_iam_role_policy" "firehose_s3" {
#   name = "pw-waf-logs-s3-policy-${var.env}"
#   role = aws_iam_role.firehose_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:PutObject",
#           "s3:GetObject",
#           "s3:ListBucket",
#           "s3:GetBucketLocation"
#         ]
#         Resource = [
#           data.aws_s3_bucket.pulse_alb_logs.arn,
#           "${data.aws_s3_bucket.pulse_alb_logs.arn}/*"
#         ]
#       }
#     ]
#   })
# }

# # Create Kinesis Firehose
# resource "aws_kinesis_firehose_delivery_stream" "waf_logs" {
#   name        = "aws-waf-logs-pw-${var.env}"
#   destination = "extended_s3"

#   extended_s3_configuration {
#     role_arn           = aws_iam_role.firehose_role.arn
#     bucket_arn         = data.aws_s3_bucket.pulse_alb_logs.arn
#     prefix             = "waf-logs/${var.env}/"
#     buffering_size     = 5
#     buffering_interval = 300
#     compression_format = "GZIP"
#   }

#   tags = var.tags
# }

# # WAF Logging Configuration
# resource "aws_wafv2_web_acl_logging_configuration" "pulse_waf" {
#   log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_logs.arn]
#   resource_arn           = aws_wafv2_web_acl.pulse_alb.arn

#   logging_filter {
#     default_behavior = "KEEP"

#     filter {
#       behavior = "KEEP"
#       condition {
#         action_condition {
#           action = "BLOCK"
#         }
#       }
#       requirement = "MEETS_ANY"
#     }
#   }
# }


######################################################################################################

# # Data sources for existing VPC components
# data "aws_vpc" "pw_vpc" {
#   filter {
#     name   = "tag:Name"
#     values = ["pw-vpc-${var.env}"]
#   }
# }

# data "aws_subnet" "public_subnet_az1" {
#   filter {
#     name   = "tag:Name"
#     values = ["pw-public-subnet-az1-${var.env}"]
#   }
# }

# data "aws_subnet" "public_subnet_az2" {
#   filter {
#     name   = "tag:Name"
#     values = ["pw-public-subnet-az2-${var.env}"]
#   }
# }

# # Data source to fetch details of an existing S3 bucket
# data "aws_s3_bucket" "pulse_alb_logs" {
#   bucket = "pw-access-logs-${var.env}"  # Replace with the name of your manually created bucket
# }


# ##################################################################################################

# # Define AWS WAFv2 Web ACL
# # resource "aws_wafv2_web_acl" "pw_web_acl" {
# #   name        = "${var.project_name}-waf-web-acl-${var.env}"
# #   scope       = "REGIONAL" # Required for ALBs (use CLOUDFRONT for CloudFront distributions)
# #   description = "Web ACL for ALB to meet compliance requirements"
# #   default_action {
# #     allow {}
# #   }

# #   rule {
# #     name     = "AWS-AWSManagedRulesCommonRuleSet"
# #     priority = 1

# #     override_action {
# #       none {}
# #     }

# #     statement {
# #       managed_rule_group_statement {
# #         name        = "AWSManagedRulesCommonRuleSet"
# #         vendor_name = "AWS"
# #       }
# #     }

# #     visibility_config {
# #       sampled_requests_enabled = true
# #       cloudwatch_metrics_enabled = true
# #       metric_name                = "awsCommonRules"
# #     }
# #   }

# #   visibility_config {
# #     sampled_requests_enabled = true
# #     cloudwatch_metrics_enabled = true
# #     metric_name                = "${var.project_name}-web-acl-metrics"
# #   }

# #   tags = merge(
# #     var.tags,
# #     {
# #       Name = "${var.project_name}-waf-web-acl"
# #     }
# #   )
# # }


# # Application Load Balancer
# resource "aws_lb" "pulse" {
#   name               = "${var.project_name}-alb-pulse-${var.env}"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [var.alb_security_group]
#   subnets            = [
#     data.aws_subnet.public_subnet_az1.id,
#     data.aws_subnet.public_subnet_az2.id
#   ]

#   drop_invalid_header_fields = true  # Directly set this attribute
#   enable_deletion_protection = true
#   idle_timeout               = 60

#   enable_http2 = true

#   # Drop invalid HTTP headers
#   # dynamic "drop_invalid_header_fields" {
#   #   for_each = [true]
#   #   content {
#   #     enabled = true
#   #   }
#   # }

#   # Enable access logging
#   access_logs {
#     enabled = true
#     bucket  = data.aws_s3_bucket.pulse_alb_logs.bucket # Replace with your logging bucket variable
#     prefix  = "pulse-alb-logs/access-logs-${var.env}"  # Optional: Specify a prefix for your logs
#   }



#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.project_name}-alb-pulse"
#     }
#   )
# }

# # Associate WAF Web ACL with the ALB
# # resource "aws_wafv2_web_acl_association" "alb_waf_association" {
# #   resource_arn = aws_lb.pulse.arn
# #   web_acl_arn  = aws_wafv2_web_acl.pw_web_acl.arn
# # }

# # ALB Listener for HTTP (Port 80)
# # resource "aws_lb_listener" "listener_http" {
# #   load_balancer_arn = aws_lb.pulse.arn
# #   port              = "80"
# #   protocol          = "HTTP"

# #   default_action {
# #     type             = "forward"
# #     target_group_arn = aws_lb_target_group.pulse.arn
# #   }
# # }

# # ALB Listener for HTTPS (Port 443)
# resource "aws_lb_listener" "listener_https"{

#   load_balancer_arn = aws_lb.pulse.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.certificate_arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.pulse.arn

#   }

#   #   # Drop invalid headers within the default action block
#   #   forward {
#   #     routing_http_drop_invalid_header_fields {
#   #       enabled = true
#   #     }
#   #   }

#   # }
# }

# # ALB Target Group (Shared by Both HTTP and HTTPS Listeners)
# resource "aws_lb_target_group" "pulse" {
#   name        = "${var.project_name}-tg-pulse-${var.env}"
#   port        = 4000
#   protocol    = "HTTP"
#   vpc_id      = data.aws_vpc.pw_vpc.id
#   target_type = "ip"

#   health_check {
#     healthy_threshold   = "3"
#     interval            = "30"
#     protocol            = "HTTP"
#     matcher             = "200"
#     timeout             = "3"
#     path                = "/health"
#     unhealthy_threshold = "2"
#   }

 

#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.project_name}-tg-pulse"
#     }
#   )
# }

# # ALB Listener Rule for HTTP and HTTPS traffic
# # resource "aws_lb_listener_rule" "pulse_rule" {
# #   listener_arn = aws_lb_listener.listener_http.arn

# #   action {
# #     type             = "forward"
# #     target_group_arn = aws_lb_target_group.pulse.arn
# #   }

# #   condition {
# #     path_pattern {
# #       values = ["/pulseapi"]
# #     }
# #   }
# # }

# resource "aws_lb_listener_rule" "pulse_https_rule" {
#   listener_arn = aws_lb_listener.listener_https.arn

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.pulse.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/pulseapi"]
#     }
#   }
# }

