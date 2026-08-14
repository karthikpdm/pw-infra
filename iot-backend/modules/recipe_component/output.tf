output "recipe_s3_key" {
  description = "S3 key of the recipe file"
  value       = aws_s3_object.recipe.key
}

output "artifacts_s3_keys" {
  description = "S3 keys of the artifact files"
  value       = [for artifact in aws_s3_object.artifacts : artifact.key]
}

output "component_name" {
  description = "Name of the deployed component"
  value       = var.component_name
}

output "component_version" {
  description = "Version of the deployed component"
  value       = data.external.component_check.result.component_version
}
