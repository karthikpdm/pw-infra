

output "s3_topic_name" {
  description = "Name of the SNS Topic for S3 event notifications"
  value       = aws_sns_topic.s3_notification.name
}

output "s3_topic_policy_id" {
  description = "ID of the SNS Topic Policy"
  value       = aws_sns_topic_policy.s3_datalake.id
}

output "s3_topic_arn" {
  description = "ARN of the SNS Topic for S3 event notifications"
  value = aws_sns_topic.s3_notification.arn
}

#####################################################################################

# Define outputs for the SNS topic
output "failure-notification-topic-arn" {
  description = "The ARN of the AMCS S3 failure notification SNS topic"
  value       = aws_sns_topic.failure-notification.arn
}

output "failure-notification-topic-name" {
  description = "The name of the AMCS S3 failure notification SNS topic"
  value       = aws_sns_topic.failure-notification.name
}

#####################################################################################


# Define outputs for the SNS topic
output "success-notification-topic-arn" {
  description = "The ARN of the AMCS S3 success notification SNS topic"
  value       = aws_sns_topic.success-notification.arn
}

output "success-notification-topic-name" {
  description = "The name of the AMCS S3 success notification SNS topic"
  value       = aws_sns_topic.success-notification.name
}


# ######################################################################################


# output "dossier_failure_topic_arn" {
#   description = "ARN of the Dossier failure SNS topic"
#   value       = aws_sns_topic.dossier_failure.arn
# }

# output "dossier_success_topic_arn" {
#   description = "ARN of the Dossier success SNS topic"
#   value       = aws_sns_topic.dossier_success.arn
# }


# ######################################################################################

# output "platform_data_failure_topic_arn" {
#   description = "ARN of the Platform data failure SNS topic"
#   value       = aws_sns_topic.platform_data_failure.arn
# }

# output "platform_data_success_topic_arn" {
#   description = "ARN of the Platform data success SNS topic"
#   value       = aws_sns_topic.platform_data_success.arn
# }

# ######################################################################################

# # Define outputs for the SNS topic
# output "platformdata_failure_topic_arn" {
#   description = "The ARN of the Platform Data failure notification SNS topic"
#   value       = aws_sns_topic.platformdata_failure.arn
# }

# output "platformdata_failure_topic_name" {
#   description = "The name of the Platform Data failure notification SNS topic"
#   value       = aws_sns_topic.platformdata_failure.name
# }

# ######################################################################################

# # Define outputs for the SNS topic
# output "platformdata_success_topic_arn" {
#   description = "The ARN of the Platform Data success notification SNS topic"
#   value       = aws_sns_topic.platformdata_success.arn
# }

# output "platformdata_success_topic_name" {
#   description = "The name of the Platform Data success notification SNS topic"
#   value       = aws_sns_topic.platformdata_success.name
# }

# ######################################################################################

# # # Define outputs for the SNS topic
# # output "platformdata_success_topic_arn" {
# #   description = "The ARN of the Platform Data success notification SNS topic"
# #   value       = aws_sns_topic.platformdata_success.arn
# # }

# # output "platformdata_failure_topic_name" {
# #   description = "The name of the Platform Data success notification SNS topic"
# #   value       = aws_sns_topic.platformdata_failure.name
# # }

# ######################################################################################

# # Define outputs for the SNS topic
# output "cleaning_data_success_topic_arn" {
#   description = "The ARN of the Platform Data success notification SNS topic"
#   value       = aws_sns_topic.cleaning_data_success.arn
# }

# output "cleaning_data_success_topic_name" {
#   description = "The name of the Platform Data success notification SNS topic"
#   value       = aws_sns_topic.cleaning_data_success.name
# }

# ######################################################################################

# # Define outputs for the SNS topic
# output "cleaning_data_failure_topic_arn" {
#   description = "The ARN of the Platform Data failure notification SNS topic"
#   value       = aws_sns_topic.cleaning_data_failure.arn
# }

# output "cleaning_data_failure_topic_name" {
#   description = "The name of the Platform Data failure notification SNS topic"
#   value       = aws_sns_topic.cleaning_data_failure.name
# }

# ######################################################################################