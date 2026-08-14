output "telemetry_map_name" {
  description = "Name of the telemetry map"
  value       = aws_location_map.telemetry_map.map_name
}

output "telemetry_satellite_map_name" {
  description = "Name of the telemetry satellite map"
  value       = aws_location_map.telemetry_satellite.map_name
}

output "telemetry_tracker_name" {
  description = "Name of the telemetry tracker"
  value       = aws_location_tracker.telemetry_tracker.tracker_name
}

output "telemetry_route_calculator_name" {
  description = "Name of the telemetry route calculator"
  value       = aws_location_route_calculator.telemetry_route.calculator_name
}
