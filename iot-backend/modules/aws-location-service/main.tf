# AWS Location Map - Telemetry Map
resource "aws_location_map" "telemetry_map" {
  configuration {
    style = "VectorEsriStreets"
  }

  map_name = "pw-telemetry-map"
  tags     = var.tags
}

# AWS Location Map - Telemetry Satellite
resource "aws_location_map" "telemetry_satellite" {
  configuration {
    style = "HybridHereExploreSatellite"
  }

  map_name = "pw-telemetry-satellite"
  tags     = var.tags
}

# AWS Location Tracker
resource "aws_location_tracker" "telemetry_tracker" {
  tracker_name       = "pw-telemetry-tracker"
  position_filtering = "AccuracyBased"
  tags               = var.tags
}

# AWS Location Route Calculator
resource "aws_location_route_calculator" "telemetry_route" {
  calculator_name = "pw-telemetry-route-calculator"
  data_source     = "Esri"
  tags            = var.tags
}
