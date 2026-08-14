# Lambda resourses for telemetry lambda
resource "aws_iam_role" "telemetry_lambda_role" {
 name = "tf-telemetry-lambda"
 assume_role_policy = jsonencode({
   Version = "2012-10-17"
   Statement = [
     {
       Action = "sts:AssumeRole"
       Effect = "Allow"
       Sid    = ""
       Principal = {
         Service = "lambda.amazonaws.com"
       }
     },
   ]
 })
}


resource "aws_iam_policy" "telemetry_lambda_policy" {
  name = "telemetry_policy"
  description = "Policy for telemetry Lambda function"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:us-east-1:*:log-group:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:DeleteItem",
          "dynamodb:PutItem"
        ],
        Resource = var.table_liveVehicleStatus
      },
      {
        Effect   = "Allow",
        Action   = [
          "geo:BatchGetDevicePosition",
          "geo:GetDevicePosition",
          "geo:BatchUpdateDevicePosition"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "telemetry_lambda_policy_attachment" {
 role       = aws_iam_role.telemetry_lambda_role.name
 policy_arn = aws_iam_policy.telemetry_lambda_policy.arn
}

resource "aws_lambda_function" "telemetry_lambda" {
  filename      = "modules/python-files/genTelemetry.zip"
  function_name = "pw-genTelemetry"
  source_code_hash  = filebase64sha256("modules/python-files/genTelemetry.zip")
  role          = aws_iam_role.telemetry_lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.tableName_liveVehicleStatus
      TRACKER = var.telemetry_tracker_name
    }
  }

  tags          = var.tags
}

# Lambda esources for EnableEventbridge lambda
# resource "aws_iam_role" "enableEventbridge_role" {
#   name = "enableEventbridge_role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = var.tags
# }

# resource "aws_iam_policy" "enableEventbridge_policy" {
#   name = "enableEventbridge_policy"
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ],
#         Resource = [
#           "arn:aws:logs:us-east-1:*:log-group:*"
#         ]
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "geo:*"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "enableEventbridge_policy_attachment" {
#   role       = aws_iam_role.enableEventbridge_role.name
#   policy_arn = aws_iam_policy.enableEventbridge_policy.arn
# }

# resource "aws_lambda_function" "enableEventbridge" {
#   function_name     = "EnableEventBridge"
#   handler           = "com.pw.lambda.EnableEventBridge::handleRequest"
#   runtime           = "java17"
#   filename          = "modules/target/priority-1.0-SNAPSHOT.jar"
#   source_code_hash  = filebase64sha256("modules/target/priority-1.0-SNAPSHOT.jar")
#   layers            = [aws_lambda_layer_version.fleet_layer.arn]
#   timeout           = 100
#   role              = aws_iam_role.enableEventbridge_role.arn

#   tags = var.tags
# }

# resource "aws_lambda_invocation" "invoke_enableEventbridge" {
#   function_name = aws_lambda_function.enableEventbridge.function_name

#   input = jsonencode({
#     trackerName = var.telemetry_tracker_name
#   })

#   lifecycle {
#     ignore_changes = [
#       input
#     ]
#   }
# }


# Layer for java function
resource "aws_lambda_layer_version" "fleet_layer" {
  layer_name          = "pwFleetLayer"
  compatible_runtimes = ["java17"]      
  filename            = "modules/layer_content.zip"
  source_code_hash    = filebase64sha256("modules/layer_content.zip")

  description = "layers for fleet lambda"
}


resource "aws_iam_role" "kvs_lambda_role" {
 name = "tf-kvs-lambda"
 assume_role_policy = jsonencode({
   Version = "2012-10-17"
   Statement = [
     {
       Action = "sts:AssumeRole"
       Effect = "Allow"
       Sid    = ""
       Principal = {
         Service = "lambda.amazonaws.com"
       }
     },
   ]
 })
}

resource "aws_iam_role_policy_attachment" "kvs_lambda_policy_attachment" {
  role       = aws_iam_role.kvs_lambda_role.name
  policy_arn = aws_iam_policy.kvs_lambda_policy.arn 
}

resource "aws_iam_policy" "kvs_lambda_policy" {
  name        = "kvs_lambda_policy"
  description = "Updated policy for KVS telemetry Lambda function"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:us-east-1:767397709508:*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:us-east-1:767397709508:log-group:/aws/lambda/kinesisDataStream:*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:PutItem"
        ]
        Resource = var.table_telemetryData
      },
      {
        Effect   = "Allow"
        Action   = [
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:DescribeStream",
          "kinesis:DescribeStreamSummary",
          "kinesis:ListShards",
          "kinesis:ListStreams"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_lambda_function" "kvs_telemetry" {
  filename      = "modules/python-files/kvsLambda.zip"
  function_name = "pw-kinesisDataStream"
  role          = aws_iam_role.kvs_lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.tableName_telemetryData
    }
  }

  tags          = var.tags
}

resource "aws_lambda_event_source_mapping" "kvs_telemetry" {
  event_source_arn  = var.arn_kvs_telemetry
  function_name     = aws_lambda_function.kvs_telemetry.arn
  starting_position = "LATEST"
}

#-----------------Remote commands--------------------------------------------
resource "aws_iam_role" "rc_role" {
 name = "tf-shadow-lambda"
 assume_role_policy = jsonencode({
   Version = "2012-10-17"
   Statement = [
     {
       Action = "sts:AssumeRole"
       Effect = "Allow"
       Principal = {
         Service = "lambda.amazonaws.com"
       }
     },
   ]
 })
}


resource "aws_iam_policy" "rc_policy" {
  name = "tf-shadow-lambda-policy"
  description = "Policy for iot shadow Lambda function"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = [
          "arn:aws:logs:us-east-1:*:log-group:*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
              "iot:Publish",
              "iot:Subscribe",
              "iot:Receive",
              "iot:Connect",
              "iot:GetThingShadow",
              "iot:UpdateThingShadow",
              "iot:DeleteThingShadow",
              "iot:DescribeJobExecution",
              "iot:ListJobExecutionsForJob",
              "iot:ListJobExecutionsForThing",
              "iot:ListJobs",
              "iot:ListJobTemplates",
              "iot:ListManagedJobTemplates",
              "iot:CreateJob"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
                "s3:GetObject",
                "s3:ListBucket"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rc_policy_attachment" {
  role       = aws_iam_role.rc_role.name
  policy_arn = aws_iam_policy.rc_policy.arn 
}

resource "aws_lambda_function" "iot_shadow" {
  filename      = "modules/python-files/iotShadow.zip"
  function_name = "pw-iotShadow"
  role          = aws_iam_role.rc_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  tags          = var.tags
}
# -----------------------------------------------------------------------
data "aws_s3_bucket" "ml_source" {
  bucket = "tf-pw-fleet-ml-detection-${var.env}"
}

data "aws_s3_bucket" "ml_destination" {
  bucket = "tf-pw-fleet-ml-detection-output-${var.env}"
}

data "aws_cloudfront_distribution" "cloudfront_domain" {
  id = var.s3_ml_domain_name
}

data "aws_dynamodb_table" "ml_table" {
  name = "pwFleetML"
}

resource "aws_iam_role" "video_convertor_role" {
 name = "tf-video-convertor-lambda"
 assume_role_policy = jsonencode({
   Version = "2012-10-17"
   Statement = [
     {
       Action = "sts:AssumeRole"
       Effect = "Allow"
       Principal = {
         Service = "lambda.amazonaws.com"
       }
     },
   ]
 })
}


resource "aws_iam_policy" "video_convertor_policy" {
  name = "tf-video-convertor-lambda-policy"
  description = "Policy for video convertor Lambda function"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = [
          "arn:aws:logs:us-east-1:*:log-group:*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
              "dynamodb:GetItem",
              "dynamodb:UpdateItem"
        ],
        Resource = [
          data.aws_dynamodb_table.ml_table.arn
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${data.aws_s3_bucket.ml_source.bucket}",
          "arn:aws:s3:::${data.aws_s3_bucket.ml_source.bucket}/*",
          "arn:aws:s3:::${data.aws_s3_bucket.ml_destination.bucket}",
          "arn:aws:s3:::${data.aws_s3_bucket.ml_destination.bucket}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action = [
          "mediaconvert:*"
        ]
         Resource = [
          "*"
        ]
      },
      {
        Effect   = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
         Resource = [
          data.aws_cloudfront_distribution.cloudfront_domain.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "video_convertor_policy_attachment" {
  role       = aws_iam_role.video_convertor_role.name
  policy_arn = aws_iam_policy.video_convertor_policy.arn 
}

resource "aws_lambda_function" "iot_video_convertor" {
  filename      = "modules/python-files/videoConvertor.zip"
  function_name = "pw-video-convertor"
  role          = aws_iam_role.video_convertor_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  tags          = var.tags

  environment {
    variables = {
      DestinationBucket = data.aws_s3_bucket.ml_destination.bucket
      MediaConvertRole  = aws_iam_role.media_convertor_role.arn
      CloudFrontDomain  = data.aws_cloudfront_distribution.cloudfront_domain.domain_name
      MLDataTableName   = data.aws_dynamodb_table.ml_table.name
      # AWS_DEFAULT_REGION = var.region
    }
  }

  depends_on = [
    aws_iam_role.media_convertor_role,
    data.aws_s3_bucket.ml_destination,
    data.aws_cloudfront_distribution.cloudfront_domain,
    data.aws_dynamodb_table.ml_table
  ]
}

resource "aws_lambda_permission" "iot_video_convertor" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.iot_video_convertor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.ml_source.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.ml_source.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.iot_video_convertor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.iot_video_convertor]
}

resource "aws_iam_role" "media_convertor_role" {
 name = "tf-media-convertor"
 assume_role_policy = jsonencode({
   Version = "2012-10-17"
   Statement = [
     {
       Action = "sts:AssumeRole"
       Effect = "Allow"
       Principal = {
         Service = "mediaconvert.amazonaws.com"
       }
     },
   ]
 })
}


resource "aws_iam_policy" "media_convertor_policy" {
  name = "tf-media-convertor-policy"
  description = "Policy for media convertor to be used in lambda function"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
                "s3:GetObject",
                "s3:ListBucket",
                "s3-object-lambda:*"
        ]
        Resource = [
           "arn:aws:s3:::${data.aws_s3_bucket.ml_source.bucket}",
            "arn:aws:s3:::${data.aws_s3_bucket.ml_source.bucket}/*"
        ]
      }
    ]
  })
}