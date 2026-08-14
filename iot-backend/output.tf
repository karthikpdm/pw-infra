output "location_service_recipe_s3_key" {
  description = "S3 key for location-service recipe"
  value       = module.location_service.recipe_s3_key
}

output "location_service_artifacts_s3_keys" {
  description = "S3 keys for location-service artifacts"
  value       = module.location_service.artifacts_s3_keys
}

output "location_service_component_version" {
  description = "Version of the location-service component"
  value       = module.location_service.component_version
}

output "kinesis_video_recipe_s3_key" {
  description = "S3 key for kinesis video recipe"
  value       = module.kinesis_video.recipe_s3_key
}

output "kinesis_video_artifacts_s3_keys" {
  description = "S3 keys for kinesis video artifacts"
  value       = module.kinesis_video.artifacts_s3_keys
}

output "kinesis_video_component_version" {
  description = "Version of the kinesis video component"
  value       = module.kinesis_video.component_version
}


#######################

output "telemetry_map_name" {
  description = "Name of the telemetry map"
  value       = module.aws-location-service.telemetry_map_name
}

output "telemetry_satellite_map_name" {
  description = "Name of the telemetry satellite map"
  value       = module.aws-location-service.telemetry_satellite_map_name
}

output "telemetry_tracker_name" {
  description = "Name of the telemetry tracker"
  value       = module.aws-location-service.telemetry_tracker_name
}

output "telemetry_route_calculator_name" {
  description = "Name of the telemetry route calculator"
  value       = module.aws-location-service.telemetry_route_calculator_name
}
