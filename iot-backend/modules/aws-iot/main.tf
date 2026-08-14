resource "aws_iam_role" "cloudwatch_role" {
  name               = "tf-telemetry-topic-rule"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { 
          Service = "iot.amazonaws.com" 
          },
        Action   = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name   = "cloudwatch_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:us-east-1:*:log-group:*"
      },
      {
        Effect = "Allow",
        Action = [
          "geo:BatchUpdateDevicePosition",
          "geo:BatchPutGeofence",
          "geo:UpdateTracker",
          "geo:BatchEvaluateGeofences",
          "geo:SearchPlaceIndexForPosition",
          "geo:PutGeofence",
          "geo:ListTrackers",
          "geo:DescribeTracker",
          "geo:AssociateTrackerConsumer",
          "geo:CreateTracker",
          "geo:DeleteTracker",
          "geo:DisassociateTrackerConsumer",
          "geo:ListTrackerConsumers"
        ],
        Resource = "*"
      }
    ]
  })

}


resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.cloudwatch_role.name 
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

# Topic rule ------------------------------------------------------
resource "aws_iot_topic_rule" "telemetry_rule" {
  name        = "pwTelemetryRule"
  enabled     = true
  sql         = "SELECT * FROM 'greengrass/generateTelemetry'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = var.lambda_arn_telemetry
  }

  cloudwatch_logs {
    log_group_name = var.location_logs
    role_arn = aws_iam_role.cloudwatch_role.arn 
    batch_mode = "true"
  }
}
# ------------------------------------------------------------------
resource "aws_iot_policy" "thing_policy" {
  name   = "thing_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "iot:Connect",
          "iot:Publish",
          "iot:Receive",
          "iot:Subscribe",
          "greengrass:*",
          "s3:*"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_lambda_permission" "telemetry_lambda" {
  statement_id  = "AllowExecutionFromOtherServices"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn_telemetry
  principal     = "iot.amazonaws.com"
  source_arn    = aws_iot_topic_rule.telemetry_rule.arn 
}

resource "aws_iam_role" "kinesis_role" {
 name = "tf-kinesis-topic-rule"
 assume_role_policy = jsonencode({
   Version = "2012-10-17"
   Statement = [
     {
       Action = "sts:AssumeRole"
       Effect = "Allow"
       Principal = {
         Service = "iot.amazonaws.com"
       }
     },
   ]
 })
}

resource "aws_iam_policy" "kinesis_policy" {
  name = "kinesis_policy"
  description = "Policy for Kinesis topic rule"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:us-east-1:*:log-group:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:UpdateItem"
        ],
        Resource = var.table_telemetryData
      },
      {
        Effect   = "Allow"
        Action   = [
          "kinesis:PutRecord",
                "kinesis:PutRecords",
                "kinesis:DescribeStream",
                "kinesis:ListStreams"
        ]
        Resource = [
          "arn:aws:kinesis:*:*:stream/*"
        ]
      },
      {
        Effect   = "Allow"
        Action = [
          "iot:Connect",
                "iot:Publish",
                "iot:Subscribe",
                "iot:Receive",
                "iot:GetThingShadow",
                "iot:UpdateThingShadow"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "kinesis_policy_attachment" {
  role       = aws_iam_role.kinesis_role.name 
  policy_arn = aws_iam_policy.kinesis_policy.arn
}
# Topic rule ------------------------------------------------------
resource "aws_iot_topic_rule" "kinesis_rule" {
  name        = "pwKinesisRule"
  enabled     = true
  sql         = "SELECT * FROM 'greengrass/generateTelemetry'"
  sql_version = "2016-03-23"

  kinesis {
    partition_key = "newuuid()"
    role_arn = aws_iam_role.kinesis_role.arn
    stream_name = var.name_kvs_telemetry
  }
}
# ----------------------------------------------------------------
resource "aws_iam_role" "mlAlerts_role" {
 name = "tf-ml-alerts-topic-rule"
 assume_role_policy = jsonencode({
   Version = "2012-10-17"
   Statement = [
     {
       Action = "sts:AssumeRole"
       Effect = "Allow"
       Principal = {
         Service = "iot.amazonaws.com"
       }
     },
   ]
 })
}

resource "aws_iam_policy" "mlAlerts_policy" {
  name = "tf-ml-alerts-topic-rule-policy"
  description = "Policy for ML alerts Topic rule"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:us-east-1:*:log-group:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        Resource = var.table_mlAlerts
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "mlAlerts_policy_attachment" {
  role       = aws_iam_role.mlAlerts_role.name 
  policy_arn = aws_iam_policy.mlAlerts_policy.arn
}

# Topic rule ------------------------------------------------------
resource "aws_iot_topic_rule" "ml_rule" {
  name        = "pwMLRule"
  enabled     = true
  sql         = "SELECT * FROM 'ml/alerts'"
  sql_version = "2016-03-23"

  dynamodbv2 {
    put_item {
      table_name = var.tableName_mlAlerts
    }
    role_arn = aws_iam_role.mlAlerts_role.arn
  }
}
# -----------------------------------------------------------------