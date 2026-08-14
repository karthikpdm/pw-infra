aws_region      = "us-east-1"
assume_role_arn = "arn:aws:iam::471112621064:role/pw-role-prod-crossaccount_infra_role"
env             = "prod"
bucket_name     = "pw-pulse-prod"
s3_bucket_id    = "pw-pulse-prod"  # Ensure this matches the bucket name
acm_certificate_arn = "arn:aws:acm:us-east-1:471112621064:certificate/f51e2e6e-ec13-4c03-86c0-e0f34d873e7e"

cloudfront_alias = "pulse.prioritywaste.com"


tags = {
  map-migrated = "migSZUDBD3OY2"
  project      = "pw"
  track        = "pulse"
  env          = "prod"
}