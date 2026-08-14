aws_region      = "us-east-1"
assume_role_arn = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
env             = "dev"
bucket_name     = "pw-pulse-dev"
s3_bucket_id    = "pw-pulse-dev"  # Ensure this matches the bucket name
# acm_certificate_arn = "arn:aws:acm:us-east-1:767397709508:certificate/6f3ab0f1-404e-4448-a5e3-b4ff4963c6e9"
acm_certificate_arn = "arn:aws:acm:us-east-1:767397709508:certificate/b6dca4cb-7e75-4ba8-8e2c-cec47b4f18e6"

cloudfront_alias = "pulse.dev.prioritywaste.com"
# codebuild_role_name = "pw-role-codebuild-infra_role" # Ensure this matches your actual role name


tags = {
  map-migrated = "migSZUDBD3OY2"
  project      = "pw"
  track        = "pulse"
  env          = "dev"
}