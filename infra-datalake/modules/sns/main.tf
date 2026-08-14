data "aws_caller_identity" "current" {}




# Create SNS Topic for S3 delete notifications
resource "aws_sns_topic" "s3_notification" {

  name = "pw-sns-${var.env}-datalake-s3-notifications"
  
  
  tags = merge(
    var.tags,
    {
      Name = "pw-sns-${var.env}-datalake-s3-notifications"
    }
  )
}


# SNS Topic Policy to allow S3 to publish
resource "aws_sns_topic_policy" "s3_datalake" {
  arn = aws_sns_topic.s3_notification.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.s3_notification.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          
          ArnLike = {
            "aws:SourceArn" = [
              "arn:aws:s3:::pw-${var.env}-datalake-raw-s3",
              "arn:aws:s3:::pw-${var.env}-datalake-cleansed-s3",
              "arn:aws:s3:::pw-${var.env}-datalake-curated-s3",
              "arn:aws:s3:::pw-${var.env}-datalake-operational-s3",
              "arn:aws:s3:::pw-${var.env}-datalake-temp-s3"
              

            ]
          }
        }
      }
    ]
  })
}




###########################################################################################

# Create the SNS topic
resource "aws_sns_topic" "failure-notification" {
  name         = "pw-${var.env}-failure-notification-sns"
  display_name = "pw-failure-notification"
  
  tags = var.tags
}

# Create an SNS topic subscription for email
resource "aws_sns_topic_subscription" "failure-notification-email" {
  topic_arn = aws_sns_topic.failure-notification.arn
  protocol  = "email"
  # endpoint  = "shaik.jabi@trianz.com"
  endpoint  = var.subscription_email
}

###########################################################################################

# Create the SNS topic for success notifications
resource "aws_sns_topic" "success-notification" {
  name         = "pw-${var.env}-success-notification-sns"
  display_name = "pw-success-notification"
  
  tags = var.tags
}

# Create an SNS topic subscription for email
resource "aws_sns_topic_subscription" "success-notification-email" {
  topic_arn = aws_sns_topic.success-notification.arn
  protocol  = "email"
  # endpoint  = "shaik.jabi@trianz.com"
  endpoint  = var.subscription_email
}

###########################################################################################


# # Create Dossier failure SNS topic
# resource "aws_sns_topic" "dossier_failure" {
#   name         = "pw-dossier-failure"
#   display_name = "pw-dossier-failure-notification"
#   tags         = var.tags
# }

# # Create Dossier failure email subscription
# resource "aws_sns_topic_subscription" "dossier_failure_email" {
#   topic_arn = aws_sns_topic.dossier_failure.arn
#   protocol  = "email"
#   endpoint  = "shaik.jabi@trianz.com"
# }


# ###########################################################################################

# # Create Dossier success SNS topic
# resource "aws_sns_topic" "dossier_success" {
#   name         = "pw-dossier-success"
#   display_name = "pw-dossier-success-notification"
#   tags         = var.tags
# }

# # Create Dossier success email subscription
# resource "aws_sns_topic_subscription" "dossier_success_email" {
#   topic_arn = aws_sns_topic.dossier_success.arn
#   protocol  = "email"
#   endpoint  = "shaik.jabi@trianz.com"
# }

# ###########################################################################################


# # Create Platform data failure SNS topic
# resource "aws_sns_topic" "platform_data_failure" {
#   name         = "pw-platformdata-failure"
#   display_name = "pw-platformdata-failure-notification"
#   tags         = var.tags
# }




# # Create Platform data failure email subscription
# resource "aws_sns_topic_subscription" "platform_data_failure_email" {
#   topic_arn = aws_sns_topic.platform_data_failure.arn
#   protocol  = "email"
#   endpoint  = "shaik.jabi@trianz.com"
# }

# ###########################################################################################

# # Create Platform data success SNS topic
# resource "aws_sns_topic" "platform_data_success" {
#   name         = "pw-platformdata-success"
#   display_name = "pw-platformdata-success-notification"
#   tags         = var.tags
# }




# # Create Platform data success email subscription
# resource "aws_sns_topic_subscription" "platform_data_success_email" {
#   topic_arn = aws_sns_topic.platform_data_success.arn
#   protocol  = "email"
#   endpoint  = "shaik.jabi@trianz.com"
# }

# ###########################################################################################

# # Create the Platform Data Success SNS topic
# resource "aws_sns_topic" "platformdata_success" {
#   name         = "pw-platformdata-success"
#   display_name = "pw-platformdata-success"
  
#   tags = var.tags
# }

# # Create an SNS topic subscription for email
# resource "aws_sns_topic_subscription" "platformdata_success_email" {
#   topic_arn = aws_sns_topic.platformdata_success.arn
#   protocol  = "email"
#   endpoint  = "shaik.jabi@trianz.com"
# }


# ###########################################################################################

# # Create the Platform Data Failure SNS topic
# resource "aws_sns_topic" "platformdata_failure" {
#   name         = "pw-platformdata-failure"
#   display_name = "pw-platformdata-failure"
  
#   tags = var.tags
# }

# # Create an SNS topic subscription for email
# resource "aws_sns_topic_subscription" "platformdata_failure_email" {
#   topic_arn = aws_sns_topic.platformdata_failure.arn
#   protocol  = "email"
#   endpoint  = "shaik.jabi@trianz.com"
# }

# ###########################################################################################


# ###########################################################################################

# # Create the Platform Data Success SNS topic
# resource "aws_sns_topic" "cleaning_data_success" {
#   name         = "pw-cleaning_data-success"
#   display_name = "pw-cleaning_data-success"
  
#   tags = var.tags
# }

# # Create an SNS topic subscription for email
# resource "aws_sns_topic_subscription" "cleaning_data_success_email" {
#   topic_arn = aws_sns_topic.cleaning_data_success.arn
#   protocol  = "email"
#   endpoint  = "shaik.jabi@trianz.com"
# }


# ###########################################################################################

# # Create the Platform Data Failure SNS topic
# resource "aws_sns_topic" "cleaning_data_failure" {
#   name         = "pw-pcleaning_data-failure"
#   display_name = "pw-cleaning_data-failure"
  
#   tags = var.tags
# }

# # Create an SNS topic subscription for email
# resource "aws_sns_topic_subscription" "cleaning_data_failure_email" {
#   topic_arn = aws_sns_topic.cleaning_data_failure.arn
#   protocol  = "email"
#   endpoint  = "shaik.jabi@trianz.com"
# }

# ###########################################################################################



