region                      = "us-east-1"
env                         = "dev"
assume_role_arn     = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
tags =  {
    project      = "pw"
    map-migrated = "mig3W94SJXDED"
    track        = "fleet"
    env          = "dev"
}
location_logs = "/aws/iot/telemetry"
create_iot_topic_rule = false
create_iot_policy = false
create_lambda_permission = false
identity_pool_role_name         = "genTelemetryPoolRole"
identity_pool_name              = "genTelemetryIdentityPool"
allow_unauthenticated_identities = true
log_retention_days              = 365
identity_pool_role_name_arn     = "arn:aws:iam::767397709508:role/genTelemetryPoolRole"

s3_bucket_name = "gentelemetry-components-artifacts"
##component_name       = "pw-dev-telemetry-loc-recipe"
##recipe_file          = "recipe-components/location_services/telemetry_location_recipe.json"

#artifacts = [
#  "recipe-components/location_services/telemetry_location.py",
#  "recipe-components/location_services/requirements.txt",
#  "recipe-components/location_services/telemetry_location_recipe.json"
#]


# Location Service Variables
location_recipe_file = "recipe-components/location_services/telemetry_location_recipe.json"
location_artifacts   = [
  "recipe-components/location_services/telemetry_location.py",
  "recipe-components/location_services/requirements.txt",
  "recipe-components/location_services/telemetry_location_recipe.json"
]
location_component_name = "com.example.telemetryComponent"

# Kinesis Video Variables
kinesis_recipe_file = "recipe-components/kinesis_video/recipe.json"
kinesis_artifacts   = [
  "recipe-components/kinesis_video/kvsShadowss.py",
  "recipe-components/kinesis_video/requirements.txt",
  "recipe-components/kinesis_video/recipe.json"
]
kinesis_component_name = "com.stream.kvsComponent"
