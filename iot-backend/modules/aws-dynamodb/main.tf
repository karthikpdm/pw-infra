resource "aws_kms_key" "dynamodb_cmk" {
  description             = "KMS CMK for encrypting DynamoDB tables"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = var.tags
}

resource "aws_kms_alias" "dynamodb_cmk_alias" {
  name          = "alias/dynamodb-cmk"
  target_key_id = aws_kms_key.dynamodb_cmk.id
}
resource "aws_kms_key" "backup_vault_key" {
  description             = "KMS CMK for encrypting AWS Backup Vault"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = var.tags
}

resource "aws_kms_alias" "backup_vault_alias" {
  name          = "alias/backup-vault-key"
  target_key_id = aws_kms_key.backup_vault_key.id
}


##################################################

resource "aws_dynamodb_table" "liveVehicleStatus" {
  name           = "pwLiveVehicleStatus"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "VIN"

  attribute {
    name = "VIN"
    type = "S"
  }

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags          = var.tags
}

resource "aws_dynamodb_table" "telemetryData" {
  name           = "pwTelemetryData"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "VIN"

  attribute {
    name = "VIN"
    type = "S"
  }

  deletion_protection_enabled = true
  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags          = var.tags
}

resource "aws_dynamodb_table" "fleetML" {
  name           = "pwFleetML"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags          = var.tags
}

resource "aws_dynamodb_table" "mlAlerts" {
  name           = "pwMLAlerts"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }
  
  tags          = var.tags
}

#Back up plan for DynamoDB ------------------------------------------------------
resource "aws_backup_vault" "dynamodb_backup" {
  name        = "dynamodb_backup"
  kms_key_arn = aws_kms_key.backup_vault_key.arn
  tags        = var.tags
}

resource "aws_backup_plan" "dynamodb_backup" {
  name = "tf_dynamodb_backup_plan"

  rule {
    rule_name         = "tf_dynamodb_backup_rule"
    target_vault_name = aws_backup_vault.dynamodb_backup.name
    schedule          = "cron(0 12 * * ? *)"

    lifecycle {
      delete_after = 14
    }
  }
}

resource "aws_backup_selection" "dynamodb_backup" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "tf_dynamodb_backup_selection"
  plan_id      = aws_backup_plan.dynamodb_backup.id

  resources = [
    aws_dynamodb_table.liveVehicleStatus.arn ,
    aws_dynamodb_table.telemetryData.arn ,
    aws_dynamodb_table.fleetML.arn
  ]
}

resource "aws_iam_role" "backup_role" {
  name = "tf-backup-dynamodb"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "backup_role_policy" {
  name   = "tf-backup-role-policy"
  role   = aws_iam_role.backup_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "dynamodb:ListTables",
          "dynamodb:DescribeTable",
          "dynamodb:ListBackups",
          "dynamodb:ListTagsOfResource",
          "dynamodb:CreateBackup",
          "dynamodb:DeleteBackup",
          "dynamodb:RestoreTableFromBackup"
        ]
        Effect   = "Allow"
        Resource = [
          aws_backup_vault.dynamodb_backup.arn
        ]
      }
    ]
  })
}

# Auto scaling --------------------------------------------------------------
resource "aws_appautoscaling_target" "liveVehicleStatus_read_target" {
  max_capacity       = 10
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.liveVehicleStatus.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "liveVehicleStatus_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.liveVehicleStatus_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.liveVehicleStatus_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.liveVehicleStatus_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.liveVehicleStatus_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "liveVehicleStatus_write_target" {
  max_capacity       = 10
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.liveVehicleStatus.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "liveVehicleStatus_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization :${aws_appautoscaling_target.liveVehicleStatus_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.liveVehicleStatus_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.liveVehicleStatus_write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.liveVehicleStatus_write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "telemetryData_read_target" {
  max_capacity       = 10
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.telemetryData.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "telemetryData_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.telemetryData_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.telemetryData_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.telemetryData_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.telemetryData_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "telemetryData_write_target" {
  max_capacity       = 10
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.telemetryData.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "telemetryData_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization :${aws_appautoscaling_target.telemetryData_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.telemetryData_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.telemetryData_write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.telemetryData_write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "fleetML_read_target" {
  max_capacity       = 10
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.fleetML.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "fleetML_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.fleetML_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.fleetML_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.fleetML_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.fleetML_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "fleetML_write_target" {
  max_capacity       = 10
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.fleetML.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "fleetML_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization :${aws_appautoscaling_target.fleetML_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.fleetML_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.fleetML_write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.fleetML_write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    target_value = 70
  }
}