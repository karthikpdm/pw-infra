#output "component_name" {
#  description = "The name of the Greengrass component"
#  value       = var.component_name
#}

#output "component_version" {
#  description = "The version of the Greengrass component"
#  value       = var.component_version
#}

output "target_arn" {
  description = "The target ARN for the Greengrass deployment"
  value       = var.target_arn
}
