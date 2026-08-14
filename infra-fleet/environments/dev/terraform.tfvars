region                      = "us-east-1"
tags =  {
    project      = "pw"
    track        = "fleet"
    env          = "dev"
    map-migrated = "mig3W94SJXDED"
}
greengrass_deployment_id   = "pw-fleet-device-deployment-dev"
identity_pool_name               = "GenTelemetryIdentityPool"
allow_unauthenticated_identities = true
identity_pool_role_name = "genTelemetryPoolRole"

#repo_url              = "https://bitbucket.org/prioritywaste/iot-backend/src/dev/ota_solution"
#recipe_file_name      = "ota_recipe.json"
#component_name        = "MyComponent"
#component_version     = "1.0.0"
target_arn            = "arn:aws:iot:us-east-1:767397709508:thinggroup/pw-fleet-group"
failure_handling_policy = "ROLLBACK"

