aws_region           = "us-east-1"
assume_role_arn      = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
env                  = "uat"
project_name         = "pw"

certificate_arn = "arn:aws:acm:us-east-1:891377117055:certificate/c69f0a7d-436c-4d77-b783-e19f47079a9e"

desired_count     = "1"
max_task_count       = "3"
min_task_count       = "1"
cpu_target_value     = "70"
memory_target_value  = "70"
tags = {
  map-migrated = "migSZUDBD3OY2"
  project      = "pw"
  track        = "pulse"
  env          = "uat"
}