
data "aws_vpc" "selected" {
  tags = {
    Name = "pw-vpc-${var.env}"
  }
}
 
data "aws_subnet" "private_az1" {
  tags = {
    Name = "pw-private-subnet-az1-${var.env}"
  }
}
 
data "aws_subnet" "private_az2" {
  tags = {
    Name = "pw-private-subnet-az2-${var.env}"
  }
}

# Data sources for AWS account and region information
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


##########################################################################################

# data "archive_file" "all_datasources" {
#   type        = "zip"
#   source_file = "${path.module}/functions/.mjs"
#   output_path = "${path.module}/functions/.zip"
# }

# # Archive for Lambda function code
# data "archive_file" "all_datasources_lambda" {
#   type        = "zip"
#   source_dir  = "${path.module}/functions/all_datasources_lambda"
#   output_path = "${path.module}/functions/all_datasources_lambda/all_datasources_lambda.zip"
# }

# Create ZIP archive for Lambda function
data "archive_file" "all_datasources_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/functions/all_datasources_lambda"  # Directory containing all Python files
  output_path = "${path.module}/all_datasources_lambda.zip"
}


# data "archive_file" "all_datasources_layer" {
#   type        = "zip"
#   source_dir = "${path.module}/layers/"
#   output_path = "${path.module}/layers/.zip"
# }




# Create Lambda function with environment variables
resource "aws_lambda_function" "all_datasources_lambda" {
  filename         = data.archive_file.all_datasources_lambda.output_path
  source_code_hash = data.archive_file.all_datasources_lambda.output_base64sha256
  # filename         = "${path.module}/functions/.zip"
  function_name    = "pw-${var.env}-data-all-sources-lambda"
  role             = var.lambda_role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60   #900 sec
  architectures    = ["x86_64"]
  # source_code_hash = data.archive_file.all_datasources.output_base64sha256
  
  
  environment {
    variables = {
      SNS_FAILURE_TOPIC_ARN_AMCS     = var.failure-notification-topic-arn
      SNS_FAILURE_TOPIC_ARN_DOSSIER  = var.failure-notification-topic-arn
      SNS_FAILURE_TOPIC_ARN_PF       = var.failure-notification-topic-arn
      SNS_SUCCESS_TOPIC_ARN_AMCS     = var.success-notification-topic-arn
      SNS_SUCCESS_TOPIC_ARN_DOSSIER  = var.success-notification-topic-arn
      SNS_SUCCESS_TOPIC_ARN_PF       = var.success-notification-topic-arn
      amcs_secret_name               = var.amcs_secret_name
      db_name                        = "prw-prd-sqldb-datamart"
      dossier_bucket_name           = "pw-s3-dev-datalake-raw"
      dossier_file_key              = "meta-data/apis/dossier-schemas.txt"
      excluded_schema_list          = "guest,migration,staging,sys,INFORMATION_SCHEMA,db_owner,db_datareader,db_datawriter,db_denydatareader,db_denydatawriter,db_accessadmin"
      pf_bucket_name                = "pw-s3-dev-datalake-raw"
      pf_file_key                   = "misc/platformdata_tables.csv"
    }
  }

   # Reference the layer
  layers = [
    aws_lambda_layer_version.pythonlib_layer.arn
  ]
  

  # layers = [
  #   aws_lambda_layer_version.pythonlib_layer.arn  # Only need your custom layer
  # ]

  # layers = [
  #   "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:layer:pythonlib-layer:1"
  # ]

  vpc_config {
    subnet_ids         = [data.aws_subnet.private_az1.id, data.aws_subnet.private_az2.id]
    security_group_ids = [var.lambda_security_group_id]
  }

  tags = var.tags
}

# Lambda Layer
# Only need your custom Python library layer
# resource "aws_lambda_layer_version" "pythonlib_layer" {
#   filename                = "pythonlib_layer.zip"
#   layer_name             = "pythonlib-layer"
#   description            = "Python library layer for Lambda functions"
#   compatible_runtimes    = ["python3.12"]
#   compatible_architectures = ["x86_64"]
# }

# # Create Lambda layer from S3
# resource "aws_lambda_layer_version" "pythonlib_layer" {
#   layer_name          = "pw-${var.env}-data-all-sources-lambda-layer"
#   description         = "Python libraries for data processing"
#   s3_bucket           = "pw-s3-dev-datalake-cleansed"
#   s3_key              = "amcs/misc/pythonlib-layer.zip"  # Assuming this is the ZIP filename
#   compatible_runtimes = ["python3.12"]
# }

# Create Lambda layer from local file
resource "aws_lambda_layer_version" "pythonlib_layer" {
  layer_name          = "pw-${var.env}-data-all-sources-lambda-layer"
  description         = "Python libraries for data processing"
  filename            = "${path.module}/layers/pymssql.zip"
  compatible_runtimes = ["python3.12"]
}

#####################################################################################################################
                                      #  audit-lambda
#####################################################################################################################


data "archive_file" "audit-lambda" {
  type        = "zip"
  source_dir  = "${path.module}/functions/audit-lambda"  # Directory containing all Python files
  output_path = "${path.module}/audit-lambda.zip"
}


# Create Lambda function with environment variables
resource "aws_lambda_function" "audit-lambda" {
  filename         = data.archive_file.audit-lambda.output_path
  source_code_hash = data.archive_file.audit-lambda.output_base64sha256
  # filename         = "${path.module}/functions/.zip"
  # function_name    = "pw-audit-lambda"
  function_name    = "pw-${var.env}-data-audit-lambda"
  role             = var.lambda_role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  architectures    = ["x86_64"]
  # source_code_hash = data.archive_file.audit-lambda.output_base64sha256
  
  vpc_config {
    subnet_ids         = [data.aws_subnet.private_az1.id, data.aws_subnet.private_az2.id]
    security_group_ids = [var.lambda_security_group_id]
  }

  tags = var.tags
}





# #####################################################################################################################
#                                       #  pw-cleansed-schema-counts > audit
# #####################################################################################################################




# data "archive_file" "cleansed_schema_counts" {
#   type        = "zip"
#   source_dir  = "${path.module}/functions/cleansed_schema_counts"  # Directory containing all Python files
#   output_path = "${path.module}/cleansed_schema_counts.zip"
# }




# # pw-cleansed-schema-counts

# # Create Lambda function with environment variables
# resource "aws_lambda_function" "cleansed_schema_counts" {
#   filename = data.archive_file.cleansed_schema_counts.output_path
#   # function_name    = "pw-lambda-${var.env}-cleansed-schema"
#   # function_name    = "pw-cleansed-schema-counts"
#   function_name    = "pw-${var.env}-data-audit-lambda"
#   role             = var.lambda_role_arn
#   handler          = "lambda_function.lambda_handler"
#   runtime          = "python3.12"
#   timeout          = 60
#   architectures    = ["x86_64"]
#   source_code_hash = data.archive_file.cleansed_schema_counts.output_base64sha256
  
#   vpc_config {
#     subnet_ids         = [data.aws_subnet.private_az1.id, data.aws_subnet.private_az2.id]
#     security_group_ids = [var.lambda_security_group_id]
#   }

#   tags = var.tags
# }




# #####################################################################################################################
                         # pw-amcs-schema-counts-lambda   > audit
#####################################################################################################################

# data "archive_file" "amcs-schema" {
#   type        = "zip"
#   source_file = "${path.module}/functions/.mjs"
#   output_path = "${path.module}/functions/.zip"
# }

# data "archive_file" "amcs-schema" {
#   type        = "zip"
#   source_dir  = "${path.module}/functions/amcs_schema"  # Directory containing all Python files
#   output_path = "${path.module}/amcs_schema.zip"
# }


# # pw-amcs-schema-counts-lambda

# # Create Lambda function with environment variables
# resource "aws_lambda_function" "amcs-schema" {
#   filename         = data.archive_file.amcs-schema.output_path
#   # function_name    = "pw-lambda-${var.env}-amcs-schema-counts-lambda"
#   function_name    = "pw-amcs-schema-counts-lambda"
#   role             = var.lambda_role_arn
#   handler          = "lambda_function.lambda_handler"
#   runtime          = "python3.12"
#   timeout          = 60
#   architectures    = ["x86_64"]
#   source_code_hash = data.archive_file.amcs-schema.output_base64sha256
  
# environment {
#     variables = {
#       bucket     = var.raw_bucket_name
#       prefix     = "amcs/counts/"
#     }
#   }

#   vpc_config {
#     subnet_ids         = [data.aws_subnet.private_az1.id, data.aws_subnet.private_az2.id]
#     security_group_ids = [var.lambda_security_group_id]
#   }

#   tags = var.tags
# }


# #############################################################################

#                    #amcs_s3_lambda_sns  > all sources 

# #############################################################################
# data "archive_file" "amcs_s3_lambda_sns" {
#   type        = "zip"
#   source_dir  = "${path.module}/functions/amcs_s3_lambda_sns"  # Directory containing all Python files
#   output_path = "${path.module}/amcs_s3_lambda_sns.zip"
# }

# # Lambda function
# resource "aws_lambda_function" "amcs_s3_lambda_sns" {
#   filename         = data.archive_file.amcs_s3_lambda_sns.output_path  # You'll need to create this zip file containing your Python code
#   function_name    = "amcs-s3-lambda-sns"
#   role            = var.lambda_role_arn
#   handler         = "lambda_function.lambda_handler"
#   runtime         = "python3.12"
#   architectures   = ["x86_64"]
#   source_code_hash = data.archive_file.amcs_s3_lambda_sns.output_base64sha256

#   # layers = [
#   #   "arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:layer:pythonlib-layer:1"
#   # ]


#   environment {
#     variables = {
#       SNS_FAILURE_TOPIC_ARN = var.amcs_s3_failure_topic_arn
#       SNS_SUCCESS_TOPIC_ARN = var.amcs_s3_success_topic_arn
#       db_name               = "prw-prd-sqldb-datamart"
#       excluded_schema_list  = "guest,migration,staging,sys,INFORMATION_SCHEMA,db_owner,db_datareader,db_datawriter,db_denydatareader,db_denydatawriter,db_accessadmin,db_backupoperator"
#       secret_name          = var.amcs_secret_name
#     }
#   }

#   vpc_config {
#     subnet_ids         = [data.aws_subnet.private_az1.id, data.aws_subnet.private_az2.id]
#     security_group_ids = [var.lambda_security_group_id]
#   }

#   tags = var.tags
# }



# #############################################################################

#                    #dossier_audit > audit

# #############################################################################
# data "archive_file" "dossier_audit" {
#   type        = "zip"
#   source_dir  = "${path.module}/functions/dossier_audit"  # Directory containing all Python files
#   output_path = "${path.module}/dossier_audit.zip"
# }


# # Lambda function
# resource "aws_lambda_function" "dossier_audit" {
#   filename         = data.archive_file.dossier_audit.output_path 
#    # You'll need to create this zip file containing your Python code
#   function_name    = "pw-dossier-audit"
#   role            = var.lambda_role_arn
#   handler         = "lambda_function.lambda_handler"
#   runtime         = "python3.12"
#   architectures   = ["x86_64"]
#   source_code_hash = data.archive_file.dossier_audit.output_base64sha256

  

#   vpc_config {
#     subnet_ids         = [data.aws_subnet.private_az1.id, data.aws_subnet.private_az2.id]
#     security_group_ids = [var.lambda_security_group_id]
#   }

#   tags = var.tags
# }



#############################################################################

                   #dossier-schemas > pw-${var.env}-data-all-sources-lambda"

# #############################################################################
# data "archive_file" "dossier_schemas" {
#   type        = "zip"
#   source_dir  = "${path.module}/functions/dossier_schemas"  # Directory containing all Python files
#   output_path = "${path.module}/dossier_schemas.zip"
# }
# # Lambda function
# resource "aws_lambda_function" "dossier_schemas" {
#   filename         = data.archive_file.dossier_schemas.output_path
#   function_name = "dossier-schemas"
#   source_code_hash = data.archive_file.dossier_schemas.output_base64sha256
#   role          = var.lambda_role_arn
#   handler       = "lambda_function.lambda_handler"
#   runtime       = "python3.12"
  

  
#   environment {
#     variables = {
#       SNS_FAILURE_TOPIC_ARN = var.dossier_failure_topic_arn
#       SNS_SUCCESS_TOPIC_ARN = var.dossier_success_topic_arn
#       bucket_name           = var.dossier_layer_bucket_name
#       file_key              = "meta-data/apis/dossier-schemas.txt"
#     }
#   }

#   vpc_config {
#     subnet_ids         = [data.aws_subnet.private_az1.id, data.aws_subnet.private_az2.id]
#     security_group_ids = [var.lambda_security_group_id]
#   }

#   tags = var.tags
# }


# # # CloudWatch Log Group for Lambda
# # resource "aws_cloudwatch_log_group" "lambda_logs" {
# #   name              = "/aws/lambda/${aws_lambda_function.dossier_schemas.function_name}"
# #   retention_in_days = 14
# # }

# # # S3 Bucket notification to trigger Lambda
# # resource "aws_s3_bucket_notification" "bucket_notification" {
# #   bucket = aws_s3_bucket.schema_bucket.id

# #   lambda_function {
# #     lambda_function_arn = aws_lambda_function.dossier_schemas.arn
# #     events              = ["s3:ObjectCreated:*"]
# #     filter_prefix       = "meta-data/apis/"
# #     filter_suffix       = ".txt"
# #   }
# # }

# #############################################################################

#                    #dynamoDB-tables-count  > audit

# #############################################################################
# data "archive_file" "dynamoDB-tables-count" {
#   type        = "zip"
#   source_dir  = "${path.module}/functions/pw-dynamoDB-tables-count"  # Directory containing all Python files
#   output_path = "${path.module}/pw-dynamoDB-tables-count.zip"
# }
# # Lambda function
# resource "aws_lambda_function" "dynamoDB-tables-count" {
#   filename         = data.archive_file.dynamoDB-tables-count.output_path
#   function_name = "pw-dynamoDB-tables-count"
#   source_code_hash = data.archive_file.dynamoDB-tables-count.output_base64sha256
#   role          = var.lambda_role_arn
#   handler       = "lambda_function.lambda_handler"
#   runtime       = "python3.12"
#     # You'll need to create this zip file with your Python code

#   vpc_config {
#     subnet_ids         = [data.aws_subnet.private_az1.id, data.aws_subnet.private_az2.id]
#     security_group_ids = [var.lambda_security_group_id]
#   }

#   tags = var.tags
# }
 



#############################################################################

                   # pw-data-curator-lambda

#############################################################################

# Lambda function code
data "archive_file" "data_curator" {
  type        = "zip"
  source_dir  = "${path.module}/functions/data_curator"  # Directory containing all Python files
  output_path = "${path.module}/data_curator.zip"
}

# Lambda function
resource "aws_lambda_function" "data_curator" {
  function_name    = "pw-${var.env}-data-clencing-lambda"
  # function_name = "pw-data-curator-lambda"
  
  role          = var.lambda_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.data_curator.output_path
  source_code_hash = data.archive_file.data_curator.output_base64sha256
  timeout       = 60
  memory_size   = 256
  architectures = ["x86_64"]

  # Environment variables
  environment {
    variables = {
      SNS_FAILURE_TOPIC_ARN = var.failure-notification-topic-arn
      SNS_SUCCESS_TOPIC_ARN = var.success-notification-topic-arn
      cleansed_bucket_name  = var.cleansed_bucket_name
      raw_bucket_name       = var.raw_bucket_name
    }
  }
  
  # Layerclencing
  # layers = ["arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:layer:oauth-layer:1"]
  
  vpc_config {
    subnet_ids         = [data.aws_subnet.private_az1.id, data.aws_subnet.private_az2.id]
    security_group_ids = [var.lambda_security_group_id]
  }

  tags = var.tags

  }



