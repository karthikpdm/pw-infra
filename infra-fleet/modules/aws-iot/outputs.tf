output "thing_arn" {
  value = aws_iot_thing.thing.arn
}

output "greengrass_deployment_id" {
  description = "The ARN of the Greengrass deployment used in the module"
  value       = var.greengrass_deployment_id
}