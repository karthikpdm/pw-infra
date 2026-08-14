aws_region           = "us-east-1"
assume_role_arn      = "arn:aws:iam::471112621064:role/pw-role-prod-crossaccount_infra_role"
env                  = "prod"
vpc_cidr_block       = "10.11.64.0/19"
public_subnet_az1_cidr  = "10.11.64.0/22"
public_subnet_az2_cidr  = "10.11.68.0/22"
private_subnet_az1_cidr = "10.11.72.0/22"
private_subnet_az2_cidr = "10.11.76.0/22"

cloudwatch_log_retention_days = "365"



tags = {
  map-migrated = "migSZUDBD3OY2"
  project      = "pw"
  track        = "devops"
  env          = "prod"
}