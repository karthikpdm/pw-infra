aws_region           = "us-east-1"
assume_role_arn      = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
env                  = "dev"
vpc_cidr_block       = "10.11.0.0/19"
public_subnet_az1_cidr  = "10.11.0.0/22"
public_subnet_az2_cidr  = "10.11.4.0/22"
private_subnet_az1_cidr = "10.11.8.0/22"
private_subnet_az2_cidr = "10.11.12.0/22"

cloudwatch_log_retention_days = "365"

tags = {
  map-migrated = "migSZUDBD3OY2"
  project      = "pw"
  track        = "devops"
  env          = "dev"
}
