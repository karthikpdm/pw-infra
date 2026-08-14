aws_region           = "us-east-1"
assume_role_arn      = "arn:aws:iam::471112621064:role/pw-role-prod-crossaccount_infra_role"
env                  = "prod"
project_name         = "pw"
certificate_arn = "arn:aws:acm:us-east-1:471112621064:certificate/4a3676a2-fa63-43bf-8c7b-1af74644cdc7"

desired_count     = "2"
max_task_count       = "5"
min_task_count       = "2"
cpu_target_value     = "70"
memory_target_value  = "70"
tags = {
  map-migrated = "migSZUDBD3OY2"
  project      = "pw"
  track        = "pulse"
  env          = "prod"
}