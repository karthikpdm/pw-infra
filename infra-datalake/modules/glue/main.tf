
data "aws_caller_identity" "current" {}

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

data "aws_secretsmanager_secret" "amcs_secret" {
  name = var.amcs_secret_name  # This should be passed from your root module
}

data "aws_secretsmanager_secret_version" "amcs_secret" {
  secret_id = data.aws_secretsmanager_secret.amcs_secret.id
}

locals {
  amcs_secret = jsondecode(data.aws_secretsmanager_secret_version.amcs_secret.secret_string)
}

#  # Data source to reference the existing connection instead of creating a new one
#   data "aws_glue_connection" "existing_amcs_connection" {
#     id = "${data.aws_caller_identity.current.account_id}:glue-amcs-connection"  # Use the name of your existing connection
#     }



#############################################################################################
# Security Configuration for Glue
resource "aws_glue_security_configuration" "connect_glue_security_config" {
  name = "pw-connect-glue-security-config-${var.env}"

  encryption_configuration {
    cloudwatch_encryption {
      cloudwatch_encryption_mode = "SSE-KMS"
      kms_key_arn               = var.datalake_kms_key_arn
    }

    job_bookmarks_encryption {
      job_bookmarks_encryption_mode = "CSE-KMS"
      kms_key_arn                   = var.datalake_kms_key_arn
    }

    s3_encryption {
      s3_encryption_mode = "SSE-KMS"
      kms_key_arn       = var.datalake_kms_key_arn
    }
  }
}



# ########################################################################################################################################
# # First Glue connection in AZ1
resource "aws_glue_connection" "amcs_connection_az1" {
  name            = "pw-glue-amcs-connection-az1-${var.env}"
  connection_type = "JDBC"
  description     = "AMCS connection in AZ1"
  
  # connection_properties = {
  #   JDBC_CONNECTION_URL = data.aws_secretsmanager_secret_version.amcs_secret.secret_string["url"]
  #   JDBC_DRIVER_CLASS_NAME = data.aws_secretsmanager_secret_version.amcs_secret.secret_string["driver_class"]
  #   JDBC_DRIVER_JAR_URI   = "s3://${var.raw_bucket_name}/amcs/jars/sqljdbc_12.8/enu/jars/mssql-jdbc-12.8.1.jre11.jar"
  #   USERNAME            = data.aws_secretsmanager_secret_version.amcs_secret.secret_string["user_name"]
  #   REQUIRE_SSL         = "false"
  # }

  connection_properties = {
    JDBC_CONNECTION_URL      = local.amcs_secret.url
    JDBC_DRIVER_CLASS_NAME   = local.amcs_secret.driver_class
    JDBC_DRIVER_JAR_URI      = "s3://${var.raw_bucket_name}/amcs/jars/sqljdbc_12.8/enu/jars/mssql-jdbc-12.8.1.jre11.jar"
    USERNAME                 = local.amcs_secret.user_name
    JDBC_ENFORCE_SSL         = "false"
    PASSWORD                 = local.amcs_secret.password  # Add this line
  }
  
  physical_connection_requirements {
    subnet_id             = data.aws_subnet.private_az1.id
    security_group_id_list = [var.glue_security_group_id]
    availability_zone      = "us-east-1a"
  }

  tags = var.tags
}

#######################################################################################################################################
# # Second Glue connection in AZ2
resource "aws_glue_connection" "amcs_connection_az2" {
  name            = "pw-glue-amcs-connection-az2-${var.env}"
  connection_type = "JDBC"
  description     = "AMCS connection in AZ2"
  
  # connection_properties = {
  #   JDBC_CONNECTION_URL = data.aws_secretsmanager_secret_version.amcs_secret.secret_string["url"]
  #   JDBC_DRIVER_CLASS_NAME = data.aws_secretsmanager_secret_version.amcs_secret.secret_string["driver_class"]
  #   JDBC_DRIVER_JAR_URI   = "s3://${var.raw_bucket_name}/amcs/jars/sqljdbc_12.8/enu/jars/mssql-jdbc-12.8.1.jre11.jar"
  #   USERNAME            = data.aws_secretsmanager_secret_version.amcs_secret.secret_string["user_name"]
  #   REQUIRE_SSL         = "false"
  # }

  connection_properties = {
    JDBC_CONNECTION_URL      = local.amcs_secret.url
    JDBC_DRIVER_CLASS_NAME   = local.amcs_secret.driver_class
    JDBC_DRIVER_JAR_URI      = "s3://${var.raw_bucket_name}/amcs/jars/sqljdbc_12.8/enu/jars/mssql-jdbc-12.8.1.jre11.jar"
    USERNAME                 = local.amcs_secret.user_name
    JDBC_ENFORCE_SSL         = "false"
    PASSWORD                 = local.amcs_secret.password
  }
  
  physical_connection_requirements {
    subnet_id             = data.aws_subnet.private_az2.id
    security_group_id_list = [var.glue_security_group_id]
    availability_zone      = "us-east-1b"
  }
  tags = var.tags
}

# ########################################################################################################################################



# resource "aws_glue_connection" "amcs_connection" {
#   name            = "glue-amcs-connection"
#   connection_type = "JDBC"
#   description     = ""  

#   connection_properties = {
#     JDBC_CONNECTION_URL = local.amcs_secret.url
#     JDBC_DRIVER_CLASS_NAME = local.amcs_secret.driver_class
#     JDBC_DRIVER_JAR_URI   = "s3://${var.raw_bucket_name}/amcs/jars/sqljdbc_12.8/enu/jars/mssql-jdbc-12.8.1.jre11.jar"
#     USERNAME                 = local.amcs_secret.user_name
#     # REQUIRE_SSL          = "false"
#     JDBC_ENFORCE_SSL    = "false"
#   }

#   physical_connection_requirements {
#     subnet_id             = "subnet-0735107210d973465"
#     security_group_id_list = ["sg-08fffe656d4b3ca70"]
#     availability_zone      = "us-east-1a"  # You'll need to specify the correct AZ for your subnet
#   }

#   tags = var.tags

#   # catalog_id = "YOUR_ACCOUNT_ID"  # Replace with your AWS account ID
# }


########################################################################################################################################

                                                     #pw-amcs-data-ingestion-glue

########################################################################################################################################

# Upload the Glue job script to S3               #amcs conn amcs
resource "aws_s3_object" "amcs-data-ingestion-glue" {    
  bucket = var.operational_bucket_name
  key    = "scripts/pw-amcs-data-ingestion-glue.py"
  source = "${path.module}/scripts/pw-amcs-data-ingestion-glue.py"
  etag   = filemd5("${path.module}/scripts/pw-amcs-data-ingestion-glue.py")
}


# Glue Job
resource "aws_glue_job" "amcs-data-ingestion-glue" {
  name              = "pw-${var.env}-amcs-data-ingestion-glue"
  role_arn          = var.glue_role_arn
  glue_version      = "4.0"
  worker_type       = "G.2X"
  number_of_workers = 15
  timeout           = 600
  max_retries       = 2
  
  command {
    # name            = "glueray"
    # runtime         = "Ray2.4"
    # script_location = "s3://aws-glue-assets-767397709508-us-east-1/scripts/pw-amcs-incremental-job.py"
    script_location = "s3://${var.operational_bucket_name}/scripts/pw-amcs-data-ingestion-glue.py"
    python_version  = "3"
  }

  
  

  # default_arguments = {
  #   # ... potentially other arguments ...
  #   "--continuous-log-logGroup"          = aws_cloudwatch_log_group.example.name
  #   "--enable-continuous-cloudwatch-log" = "true"
  #   "--enable-continuous-log-filter"     = "true"
  #   "--enable-metrics"                   = ""
  # }

  default_arguments = {
    "--continuous-log-logGroup"          = var.incremental_log_group_name
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--job-language"                     = "python"
    "--enable-glue-datacatalog"         = "true"
    # "--TempDir"                         = "s3://aws-glue-assets-767397709508-us-east-1/temporary/"
    "--TempDir"                          = "s3://${var.operational_bucket_name}/temporary/"
     # Connection-specific arguments
    # "--connection-name"                 = aws_glue_connection.amcs_connection.name
      
    # Other job parameters

    "--BUCKET_NAME"          = var.raw_bucket_name
    "--HASH_PATH"            = "s3://${var.raw_bucket_name}/amcs/hashes/"
    # "--SCHEMA_NAME"          = "common"
    "--SCHEMA_PATH"          = "s3://${var.raw_bucket_name}/amcs/schemas/"
    "--SECRET_NAME"          = var.amcs_secret_name
    "--SNS_FAILURE_TOPIC_ARN" = var.failure-notification-topic-arn
    "--SNS_SUCCESS_TOPIC_ARN" = var.success-notification-topic-arn
  }

  execution_property {
    max_concurrent_runs = 15
  }

  security_configuration = aws_glue_security_configuration.connect_glue_security_config.name
   
    connections = [
    aws_glue_connection.amcs_connection_az1.name,
    aws_glue_connection.amcs_connection_az2.name
  ]
  

  #  connections = [
  #   data.aws_glue_connection.existing_amcs_connection.name
  # ]
  
  # Additional configurations
 
  
  # Enable job metrics and insights
  notification_property {
    notify_delay_after = 60  # Minutes
  }

  tags = var.tags

}







####################################################################################################################
                                    #pw-netsuite-data-ingestion-glue
####################################################################################################################
# Upload the Glue job script to S3      no connection , no secretes
resource "aws_s3_object" "data_ingestion_netsuite" {
  bucket = var.operational_bucket_name
  key    = "scripts/pw-netsuite-data-ingestion-glue.py"
  source = "${path.module}/scripts/pw-netsuite-data-ingestion-glue.py"
  etag   = filemd5("${path.module}/scripts/pw-netsuite-data-ingestion-glue.py")
}





resource "aws_glue_job" "data_ingestion_netsuite" {
  name              = "pw-${var.env}-netsuite-data-ingestion-glue"
  # name              = "pw-data-ingestion-netsuite-glue"
  role_arn          = var.glue_role_arn
  glue_version      = "5.0"  # Supports spark 3.5, Scala 2, Python 3
  worker_type       = "G.1X"
  number_of_workers = 3
  timeout           = 180  # 30 hours in minutes
  max_retries       = 2

  command {
    script_location = "s3://${var.operational_bucket_name}/scripts/pw-netsuite-data-ingestion-glue.py"
    python_version  = "3"
  }

  default_arguments = {
    "--continuous-log-logGroup"          = var.data_ingestion_netsuite_log_group_name
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-job-insights"              = "true"
    "--enable-continuous-log-filter"     = "true"
    "--job-language"                     = "python"
    "--enable-glue-datacatalog"         = "true"
    # Job Metrics and Logging


    # "--enable-metrics"                    = "true"
    # "--enable-continuous-cloudwatch-log"  = "true"
    # "--enable-job-insights"              = "true"
    # "--enable-glue-datacatalog"          = "true"
    
    # Job Parameters
    "--BUCKET_NAME"                      =  var.raw_bucket_name
    # "--DATA_SOURCE"                      = "netsuite"
    "--SCHEMA_PATH"                      = "s3://${var.raw_bucket_name}/netsuite/schemas/"
    "--additional-python-modules"        = "s3://${var.raw_bucket_name}/netsuite/misc/requirement.txt"
    "--python-modules-installer-opt"     = "-r"
    
    # Library Paths
    "--extra-py-files"                   = "s3://${var.raw_bucket_name}/netsuite/misc/lib/requests-pyjwt-cryptography.zip"
    
    # Temporary and working directories
    "--TempDir"                          = "s3://${var.operational_bucket_name}/temporary/"
  }

  execution_property {
    max_concurrent_runs = 30
  }

  security_configuration = aws_glue_security_configuration.connect_glue_security_config.name
   
  #  connections = [
  #     aws_glue_connection.amcs_connection_az1.name,
  #     aws_glue_connection.amcs_connection_az2.name
  #     ]
  # Additional job properties
  
  
  # Enable auto-scaling
  non_overridable_arguments = {
    "--enable-auto-scaling" = "true"
  }

  tags = var.tags
}






################################################################################################################################

                                      # pw-platform-data-ingestion-glue
################################################################################################################################
# Upload the Glue job script to S3      no no
resource "aws_s3_object" "platform_data_ingestion" {
  bucket = var.operational_bucket_name
  key    = "scripts/pw-platform-data-ingestion-load.py"
  source = "${path.module}/scripts/pw-platform-data-ingestion-glue.py"
  etag   = filemd5("${path.module}/scripts/pw-platform-data-ingestion-glue.py")
}



resource "aws_glue_job" "platform_data_ingestion" {
  name              = "pw-${var.env}-platform-data-ingestion-glue"
  # name              = "pw-platform-data-incremental-load-job"
  role_arn          = var.glue_role_arn
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 5
  timeout           = 180
  max_retries       = 2

  command {
    script_location = "s3://${var.operational_bucket_name}/scripts/pw-platform-data-ingestion-glue.py"
    python_version  = "3"
  }

  default_arguments = {
    # Job Metrics and Logging
    "--continuous-log-logGroup"          = var.platform_data_incremental_log_group_name
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-job-insights"              = "true"
    "--enable-continuous-log-filter"     = "true"
    "--job-language"                     = "python"
    "--enable-glue-datacatalog"         = "true"
    

    
    # Job Parameters
    "--COUNTS_PATH"                      = "s3://${var.raw_bucket_name}/fleet/counts/"
    "--HASH_PATH"                        = "s3://${var.raw_bucket_name}/fleet/hashes/"
    "--SCHEMA_NAME"                      = "pwLiveVehicleStatus"
    "--SCHEMA_PATH"                      = "s3://${var.raw_bucket_name}/fleet/schemas/"
    "--SNS_FAILURE_TOPIC_ARN"            = var.failure-notification-topic-arn
    "--SNS_SUCCESS_TOPIC_ARN"            = var.success-notification-topic-arn
    
    # Temporary and working directories
    "--TempDir"                          = "s3://${var.operational_bucket_name}/temporary/"
  }

  execution_property {
    max_concurrent_runs = 30
  }

  security_configuration = aws_glue_security_configuration.connect_glue_security_config.name

  # connections = [
  #     aws_glue_connection.amcs_connection_az1.name,
  #     aws_glue_connection.amcs_connection_az2.name
  #     ]

  # Additional properties
 
  
  # Enable auto-scaling
  non_overridable_arguments = {
    "--enable-auto-scaling" = "true"
  }

  tags = var.tags
}




################################################################################################################################

                                      # "pw-dossier-data-ingestion-glue"
################################################################################################################################
# Upload the Glue job script to S3       secret ,,, no
resource "aws_s3_object" "dossier_delta_load" {
  bucket = var.operational_bucket_name
  key    = "scripts/pw-dossier-data-ingestion-glue.py"
  source = "${path.module}/scripts/pw-dossier-data-ingestion-glue.py"
  etag   = filemd5("${path.module}/scripts/pw-dossier-data-ingestion-glue.py")
}



resource "aws_glue_job" "dossier_delta_load" {
  name              = "pw-${var.env}-dossier-data-ingestion-glue"
  
  # name              = "pw-dossier-delta-load-job"
  role_arn          = var.glue_role_arn
  glue_version      = "4.0"
  worker_type       = "G.2X"
  number_of_workers = 5
  timeout           = 180
  max_retries       = 2

  command {
    script_location = "s3://${var.operational_bucket_name}/scripts/pw-dossier-data-ingestion-glue.py"
    python_version  = "3"
  }

  default_arguments = {
    # Job Metrics and Logging
    "--continuous-log-logGroup"          = var.dossier_delta_load_log_group_name
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-job-insights"              = "true"
    "--enable-continuous-log-filter"     = "true"
    "--job-language"                     = "python"
    "--enable-glue-datacatalog"         = "true"
    
    # Job Parameters
    "--SCHEMA_NAME"                      = "notifications"
    "--SECRET_NAME"                      = var.dossier_secret_name
    "--SNS_FAILURE_TOPIC_ARN"           = var.failure-notification-topic-arn
    "--SNS_SUCCESS_TOPIC_ARN"           = var.success-notification-topic-arn
    "--content_type"                     = "application/json"
    "--content_type2"                    = "application/x-www-form-urlencoded"
    "--dossier_url"                      = "https://d7.dossierondemand.co"
    "--hashes_path"                      = "s3://${var.raw_bucket_name}/data/hashes"
    "--schemas_path"                     = "s3://${var.raw_bucket_name}/data/schema"
    "--token_url"                        = "https://authentication.d7.dossi"
    
    # Temporary and working directories
    "--TempDir"                          = "s3://${var.operational_bucket_name}/temporary/"
  }

  execution_property {
    max_concurrent_runs = 30
  }

  # connections = [
  #     aws_glue_connection.amcs_connection_az1.name,
  #     aws_glue_connection.amcs_connection_az2.name
  #     ]

  # security_configuration = aws_glue_security_configuration.connect_glue_security_config.name

  tags = var.tags
}


################################################################################################################################

                                      # pw-data-cleansing-glue
################################################################################################################################
# Upload the Glue job script to S3    no no
resource "aws_s3_object" "data_cleansing" {
  bucket = var.operational_bucket_name
  key    = "scripts/pw-data-cleansing-glue.py"
  source = "${path.module}/scripts/pw-data-cleansing-glue.py"
  etag   = filemd5("${path.module}/scripts/pw-data-cleansing-glue.py")
}


resource "aws_glue_job" "data_cleansing" {
  name              = "pw-${var.env}-data-cleansing-glue"
  # name              = "pw-data-cleansing-job"
  role_arn          = var.glue_role_arn
  glue_version      = "4.0"
  worker_type       = "G.2X"
  number_of_workers = 10
  timeout           = 600 

  command {
    script_location = "s3://${var.operational_bucket_name}/scripts/pw-data-cleansing-glue.py"
    python_version  = "3"
  }

  default_arguments = {
    # Job Metrics and Logging
    "--continuous-log-logGroup"          = var.data_cleansing_log_group_name
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-job-insights"              = "true"
    "--enable-continuous-log-filter"     = "true"
    "--job-language"                     = "python"
    "--enable-glue-datacatalog"         = "true"
    "--enable-auto-scaling"              = "true"
    
    # Job Parameters
    "--BUCKET_NAME"                      = var.cleansed_bucket_name
    # "--DATA_SOURCE"                      = "amcs"
    # "--SCHEMA_NAME"                      = "common"
    "--SCHEMA_PATH"                      = "s3://${var.cleansed_bucket_name}/amcs/schemas/"
    "--SNS_FAILURE_TOPIC_ARN"           = var.failure-notification-topic-arn
    "--SNS_SUCCESS_TOPIC_ARN"           = var.success-notification-topic-arn
    
    # Temporary and working directories
    "--TempDir"                          = "s3://${var.operational_bucket_name}/temporary/"
  }

  # connections = [
  #     aws_glue_connection.amcs_connection_az1.name,
  #     aws_glue_connection.amcs_connection_az2.name
  #     ]

  execution_property {
    max_concurrent_runs = 30
  }

  security_configuration = aws_glue_security_configuration.connect_glue_security_config.name

  

 

  tags = var.tags

}


################################################################################################################################

                             # pw-connect-data-ingestion-glue
################################################################################################################################

# Upload the Glue job script to S3    no  no
resource "aws_s3_object" "connect_files" {
  bucket = var.operational_bucket_name
  key    = "scripts/pw-connect-data-ingestion-glue.py"
  source = "${path.module}/scripts/pw-connect-data-ingestion-glue.py"
  etag   = filemd5("${path.module}/scripts/pw-connect-data-ingestion-glue.py")
}


# Create the Glue job
resource "aws_glue_job" "connect_files" {
  name              = "pw-${var.env}-connect-data-ingestion-glue"
  # name              = "Connect Files"
  role_arn          = var.glue_role_arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 10
  timeout           = 180
  max_retries       = 0
  
  command {
    name            = "glueetl"
    script_location = "s3://${var.operational_bucket_name}/scripts/pw-connect-data-ingestion-glue.py"
    python_version  = "3"
  }
  
  default_arguments = {


    "--continuous-log-logGroup"          = var.connect_files_log_group_name
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-job-insights"              = "true"
    "--enable-continuous-log-filter"     = "true"
    "--job-language"                     = "python"
    "--enable-glue-datacatalog"         = "true"
    "--job-bookmark-option"        = "job-bookmark-disable"




    "--enable-spark-ui"            = "true"
    "--spark-event-logs-path"      = "s3://${var.operational_bucket_name}/sparkHistoryLogs/"
    "--TempDir"                    = "s3://${var.operational_bucket_name}/temporary/"
    "--source_bucket"              = var.curated_bucket_name
    "--target_bucket"              = var.curated_bucket_name
  }
  
  execution_property {
    max_concurrent_runs = 1
  }

  # connections = [
  #     aws_glue_connection.amcs_connection_az1.name,
  #     aws_glue_connection.amcs_connection_az2.name
  #     ]

  tags = var.tags
}



################################################################################################################################

                                      # pw-curated-data-heavyhaul-glue
################################################################################################################################

# Upload the Glue job script to S3       pras
resource "aws_s3_object" "heavy_haul_file" {
  bucket = var.operational_bucket_name
  key    = "scripts/pw-curated-data-heavyhaul-glue.py"
  source = "${path.module}/scripts/pw-curated-data-heavyhaul-glue.py"
  etag   = filemd5("${path.module}/scripts/pw-curated-data-heavyhaul-glue.py")
}


# Create the Glue job
resource "aws_glue_job" "heavy_haul_file" {
  name              = "pw-${var.env}-curated-data-heavyhaul-glue"
  # name              = "Heavy Haul File"
  role_arn          = var.glue_role_arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 10
  timeout           = 480
  max_retries       = 2
  # max_capacity      = 10
  
  command {
    name            = "glueetl"
    script_location = "s3://${var.operational_bucket_name}/scripts/pw-curated-data-heavyhaul-glue.py"
    python_version  = "3"
  }
  
  default_arguments = {
    "--continuous-log-logGroup"          = var.heavy_haul_file_log_group_name
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-job-insights"              = "true"
    "--enable-continuous-log-filter"     = "true"
    "--job-language"                     = "python"
    "--enable-glue-datacatalog"         = "true"
    "--job-bookmark-option"        = "job-bookmark-disable"



    "--source_bucket"                     = "${var.raw_bucket_name}/raw-data-la"
    "--target_bucket"                     = var.curated_bucket_name
  }
  
  execution_property {
    max_concurrent_runs = 1
  }

  # connections = [
  #     aws_glue_connection.amcs_connection_az1.name,
  #     aws_glue_connection.amcs_connection_az2.name
  #     ]

  tags = var.tags
}



################################################################################################################################

                                      # Residential File Data
################################################################################################################################


# # Upload the Glue job script to S3
resource "aws_s3_object" "residential_file_data" {
  bucket = var.operational_bucket_name
  key    = "scripts/pw-curated-data-residential-glue.py"
  source = "${path.module}/scripts/pw-curated-data-residential-glue.py"
  etag   = filemd5("${path.module}/scripts/pw-curated-data-residential-glue.py")
}


# Create the Glue job
resource "aws_glue_job" "residential_file_data" {
  name               =   "pw-${var.env}-curated-data-residential-glue"
  # name              = "Residential File Data"
  role_arn          = var.glue_role_arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 10
  timeout           = 480
  max_retries       = 0
  
  command {
    name            = "glueetl"
    script_location = "s3://${var.operational_bucket_name}/scripts/pw-curated-data-residential-glue.py"
    python_version  = "3"
  }
  
  default_arguments = {
    "--continuous-log-logGroup"          = var.residential_file_data_log_group_name
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-job-insights"              = "true"
    "--enable-continuous-log-filter"     = "true"
    "--continuous-log-logLevel"          = "ALL"
    "--job-language"                     = "python"
    "--enable-glue-datacatalog"         = "true"
    "--job-bookmark-option"        = "job-bookmark-disable"

    "--TempDir"                           = "s3://${var.operational_bucket_name}/temporary/"
    "--source_bucket"                     = "${var.raw_bucket_name}/amcs"
    "--target_bucket"                     = var.curated_bucket_name
  }
  
  execution_property {
    max_concurrent_runs = 1
  }

  # connections = [
  #     aws_glue_connection.amcs_connection_az1.name,
  #     aws_glue_connection.amcs_connection_az2.name
  #     ]

  tags = var.tags
}


