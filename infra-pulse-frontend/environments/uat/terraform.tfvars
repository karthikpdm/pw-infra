aws_region           = "us-east-1"
assume_role_arn      = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
env                  = "uat"
bucket_name          = "pw-pulse-uat"
s3_bucket_id         = "pw-pulse-uat"  # Ensure this matches the bucket name
acm_certificate_arn = "arn:aws:acm:us-east-1:891377117055:certificate/c69f0a7d-436c-4d77-b783-e19f47079a9e"
cloudfront_alias = "pulse.uat.prioritywaste.com"


tags = {
  map-migrated = "migSZUDBD3OY2"
  project      = "pw"
  track        = "pulse"
  env          = "uat"
}