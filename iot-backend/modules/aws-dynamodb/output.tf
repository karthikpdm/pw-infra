output "table_liveVehicleStatus"{
    value = aws_dynamodb_table.liveVehicleStatus.arn
}

output "tableName_liveVehicleStatus"{
    value = aws_dynamodb_table.liveVehicleStatus.name
}

output "table_telemetryData"{
    value = aws_dynamodb_table.telemetryData.arn
}

output "tableName_telemetryData"{
    value = aws_dynamodb_table.telemetryData.name
}

output "table_fleetML"{
    value = aws_dynamodb_table.fleetML.arn
}

output "tableName_fleetML"{
    value = aws_dynamodb_table.fleetML.name
}

output "table_mlAlerts"{
    value = aws_dynamodb_table.mlAlerts.arn
}

output "tableName_mlAlerts"{
    value = aws_dynamodb_table.mlAlerts.name
}