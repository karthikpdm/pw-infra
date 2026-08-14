#module "aws-cloudwatch" {
#    source = "./modules/aws-cloudwatch"

#    tags  = var.tags
#}

module "aws-iot" {
    source = "./modules/aws-iot"
    greengrass_deployment_id = var.greengrass_deployment_id


#   location_logs = module.aws-cloudwatch.location_logs
    tags  = var.tags

}


#module "cognito_identity" {
#  source                           = "./modules/cognito_identity"
#  identity_pool_name               = var.identity_pool_name
# allow_unauthenticated_identities = var.allow_unauthenticated_identities
#  identity_pool_role_name          = var.identity_pool_role_name
#  tags                            = var.tags
#}

module "greengrass_deployment" {
  source                 = "./modules/greengrass_deployment"
 
  #component_name         = var.component_name
  #component_version      = var.component_version
  target_arn             = var.target_arn
  failure_handling_policy = var.failure_handling_policy
}
