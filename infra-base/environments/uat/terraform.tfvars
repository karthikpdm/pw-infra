aws_region           = "us-east-1"
assume_role_arn      = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
env                  = "uat"
vpc_cidr_block       = "10.11.32.0/19"
public_subnet_az1_cidr  = "10.11.32.0/22"
public_subnet_az2_cidr  = "10.11.36.0/22"
private_subnet_az1_cidr = "10.11.40.0/22"
private_subnet_az2_cidr = "10.11.44.0/22"

cloudwatch_log_retention_days = "365"



tags = {
  map-migrated = "migSZUDBD3OY2"
  project      = "pw"
  track        = "devops"
  env          = "uat"
}