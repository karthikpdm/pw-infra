output "studio_domain_id" {
  value = aws_sagemaker_domain.pwmy_studio_domain.id
}

output "studio_user_profile_name" {
  value = aws_sagemaker_user_profile.pwmy_studio_user.user_profile_name
}
