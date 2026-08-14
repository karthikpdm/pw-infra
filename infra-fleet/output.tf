# outputs.tf

#output "identity_pool_id" {
#  description = "The ID of the Cognito Identity Pool"
#  value       = module.cognito_identity.identity_pool_id
#}

#output "identity_pool_arn" {
#  description = "The ARN of the Cognito Identity Pool"
#  value       = module.cognito_identity.identity_pool_arn
#}

#output "component_name" {
#  description = "The name of the Greengrass component"
#  value       = module.greengrass_deployment.component_name
#}

#output "component_version" {
#  description = "The version of the Greengrass component"
#  value       = module.greengrass_deployment.component_version
#}

output "target_arn" {
  description = "The ARN of the target Greengrass deployment"
  value       = module.greengrass_deployment.target_arn
}
