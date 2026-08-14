


# module "kms" {
#   source = "./modules/kms"
#   tags   = var.tags
#   env    = var.env
#   glue_role_arn  = module.iam.glue_role_arn

#   # platform_data_incremental_log_group_name = module.cloudwatch.platform_data_incremental_log_group_name
#   # dossier_delta_load_log_group_name    = module.cloudwatch.dossier_delta_load_log_group_name
#   # data_cleansing_log_group_name        = module.cloudwatch.data_cleansing_log_group_name
#   # connect_files_log_group_name         = module.cloudwatch.connect_files_log_group_name
#   # heavy_haul_file_log_group_name       = module.cloudwatch.heavy_haul_file_log_group_name
#   # residential_file_data_log_group_name = module.cloudwatch.residential_file_data_log_group_name
#   # incremental_log_group_name = module.cloudwatch.incremental_log_group_name
#   platform_data_incremental_log_group_arn = module.cloudwatch.platform_data_incremental_log_group_arn
#   connect_files_log_group_arn            = module.cloudwatch.connect_files_log_group_arn
#   data_ingestion_netsuite_log_group_arn  = module.cloudwatch.data_ingestion_netsuite_log_group_arn
#   heavy_haul_file_log_group_arn          = module.cloudwatch.heavy_haul_file_log_group_arn
#   data_cleansing_log_group_arn           = module.cloudwatch.data_cleansing_log_group__arn
#   dossier_delta_load_log_group_arn       = module.cloudwatch.dossier_delta_load_log_group_arn
#   incremental_log_group_arn              = module.cloudwatch.incremental_log_group_arn
#   glue_residential_file_data_job_name    = module.glue.glue_residential_file_data_job_name
#   residential_file_data_log_group_arn    = module.cloudwatch.residential_file_data_log_group_arn
#   # residential_file_data_log_group_name   = module.cloudwatch.residential_file_data_log_group_name
#   #s3
#   pw_amcs_historical_bucket_arn       = module.s3.pw_amcs_historical_bucket_arn
#   temp_bucket_arn                     = module.s3.temp_bucket_arn
#   cleansed_bucket_arn                 = module.s3.cleansed_bucket_arn
#   raw_bucket_arn                      = module.s3.raw_bucket_arn
#   curated_bucket_arn                  = module.s3.curated_bucket_arn
#   aws_glue_bucket_arn                 = module.s3.aws_glue_bucket_arn
#   pw_reporting_bucket_arn             = module.s3.pw_reporting_bucket_arn
#   dossier_layer_bucket_arn            = module.s3.dossier_layer_bucket_arn
#   operational_bucket_arn              = module.s3.operational_bucket_arn







#   glue_connect_files_job_name           = module.glue.glue_connect_files_job_name
#   glue_amcs_incremental_job_name        = module.glue.glue_amcs_incremental_job_name
#   glue_data_ingestion_netsuite_job_name = module.glue.glue_data_ingestion_netsuite_job_name
#   glue_dossier_delta_load_job_name      = module.glue.glue_dossier_delta_load_job_name
#   glue_data_cleansing_job_name          = module.glue.glue_data_cleansing_job_name
#   glue_heavy_haul_file_job_name         = module.glue.glue_heavy_haul_file_job_name
#   glue_platform_data_incremental_load_job_name = module.glue.glue_platform_data_incremental_load_job_name
#   platform_data_bucket_arn                = module.s3.platform_data_bucket_arn

#   depends_on = [module.lambda]
# }  

# module "cloudwatch" {
#   source = "./modules/cloudwatch"
#   s3_kms_key_arn  = module.kms.s3_kms_key_arn
#   env    = var.env
#   tags   = var.tags

# }



# module "iam" {
#   source = "./modules/iam"
#   env    = var.env
#   tags   = var.tags
#   s3_kms_key_arn  = module.kms.s3_kms_key_arn
#   # aws_glue_bucket_name = module.s3.aws_glue_bucket_name
#   # raw_bucket_name  = module.s3.raw_bucket_name
#   amcs_secret_name = module.secrete-manager.amcs_secret_name


#   audit_lambda_name = module.lambda.audit_lambda_name
#   amcs_s3_lambda_sns_name = module.lambda.amcs_s3_lambda_sns_name
#   amcs_s3_success_topic_arn  = module.sns.amcs_s3_success_topic_arn
#   amcs_s3_failure_topic_arn  = module.sns.amcs_s3_failure_topic_arn
#   amcs_schema_counts_lambda_name = module.lambda.amcs_schema_counts_lambda_name
#   glue_amcs_incremental_job_name = module.glue.glue_amcs_incremental_job_name

#   dossier_audit_lambda_name    = module.lambda.dossier_audit_lambda_name
#   cleansed_bucket_name         = module.s3.cleansed_bucket_name
#   cleansed_schema_counts_lambda_name = module.lambda.cleansed_schema_counts_lambda_name




# }

# module "sns" {
#   source = "./modules/sns"
#   env    = var.env
#   tags   = var.tags
# }

# module "s3" {
#   source          = "./modules/s3"
#   env             = var.env
#   s3_kms_key_arn  = module.kms.s3_kms_key_arn
#   s3_topic_arn    = module.sns.s3_topic_arn
#   tags            = var.tags

# }

# module "dynamodb" {
#   source = "./modules/dynamodb"

#   env                           = var.env
#   tags                          = var.tags
#   s3_kms_key_arn  = module.kms.s3_kms_key_arn

#  }

#  module "secrete-manager" {
#   source = "./modules/secrete-manager"
#   env    = var.env
#   tags   = var.tags
#   s3_kms_key_arn  = module.kms.s3_kms_key_arn

#   # Variables for the secrets module
#   server_name   = var.server_name
#   database_name = var.database_name
#   user_name     = var.user_name
#   password      = var.password
#   driver_path   = var.driver_path
#   driver_class  = var.driver_class
#   url           = var.url
# }

 

# module "security_group" {
#   source = "./modules/sg"
  
#   env    = var.env
#   tags   = var.tags
# }

# module "lambda" {
#   source = "./modules/lambda"

#   env                           = var.env
#   tags                          = var.tags
#   lambda_security_group_id      = module.security_group.lambda_security_group_id
#   lambda_role_arn               = module.iam.lambda_role_arn
#   amcs_s3_failure_topic_arn     = module.sns.amcs_s3_failure_topic_arn
#   amcs_s3_success_topic_arn     = module.sns.amcs_s3_success_topic_arn
#   dossier_failure_topic_arn     = module.sns.dossier_failure_topic_arn
#   dossier_success_topic_arn     = module.sns.dossier_success_topic_arn
#   platform_data_success_topic_arn = module.sns.platform_data_success_topic_arn
#   platform_data_failure_topic_arn = module.sns.platform_data_failure_topic_arn
#   amcs_secret_name               = module.secrete-manager.amcs_secret_name
#   dossier_layer_bucket_name      = module.s3.dossier_layer_bucket_name
#   raw_bucket_name                = module.s3.raw_bucket_name
#   cleansed_bucket_name           = module.s3.cleansed_bucket_name
  
# }

# module "glue" {
#   source = "./modules/glue"
#   env    = var.env
#   tags   = var.tags
#   glue_role_arn  = module.iam.glue_role_arn
#   s3_kms_key_arn  = module.kms.s3_kms_key_arn
#   amcs_secret_name = module.secrete-manager.amcs_secret_name
#   dossier_secret_name = module.secrete-manager.dossier_secret_name
#   aws_glue_bucket_name = module.s3.aws_glue_bucket_name
#   raw_bucket_name  = module.s3.raw_bucket_name
#   dossier_layer_bucket_name = module.s3.dossier_layer_bucket_name
#   # glue_security_group_id = module.security_group.glue_security_group_id
#   incremental_log_group_name = module.cloudwatch.incremental_log_group_name
#   amcs_s3_success_topic_arn  = module.sns.amcs_s3_success_topic_arn
#   amcs_s3_failure_topic_arn  = module.sns.amcs_s3_failure_topic_arn
#   platformdata_failure_topic_arn = module.sns.platformdata_failure_topic_arn
#   platformdata_success_topic_arn = module.sns.platformdata_success_topic_arn
#   platform_data_bucket_name      = module.s3.platform_data_bucket_name
#   cleansed_bucket_name           = module.s3.cleansed_bucket_name
#   pw_reporting_bucket_name       = module.s3.pw_reporting_bucket_name
#   pw_amcs_historical_bucket_name = module.s3.pw_amcs_historical_bucket_name
#   data_ingestion_netsuite_log_group_name = module.cloudwatch.data_ingestion_netsuite_log_group_name
#   platform_data_incremental_log_group_name = module.cloudwatch.platform_data_incremental_log_group_name
#   dossier_delta_load_log_group_name    = module.cloudwatch.dossier_delta_load_log_group_name
#   data_cleansing_log_group_name        = module.cloudwatch.data_cleansing_log_group_name
#   connect_files_log_group_name         = module.cloudwatch.connect_files_log_group_name
#   heavy_haul_file_log_group_name       = module.cloudwatch.heavy_haul_file_log_group_name
#   residential_file_data_log_group_name = module.cloudwatch.residential_file_data_log_group_name
#   cleaning_data_success_topic_arn      = module.sns.cleaning_data_success_topic_arn
#   cleaning_data_failure_topic_arn      = module.sns.cleaning_data_failure_topic_arn




# }

# module "step_function" {

#   source = "./modules/step-function"
#   step_function_role_arn = module.iam.step_function_role_arn
#   audit_lambda_name = module.lambda.audit_lambda_name
#   amcs_s3_lambda_sns_name = module.lambda.amcs_s3_lambda_sns_name
#   amcs_s3_success_topic_arn  = module.sns.amcs_s3_success_topic_arn
#   amcs_s3_failure_topic_arn  = module.sns.amcs_s3_failure_topic_arn
#   amcs_schema_counts_lambda_arn = module.lambda.amcs_schema_counts_lambda_arn
#   glue_amcs_incremental_job_name = module.glue.glue_amcs_incremental_job_name
#   dossier_schemas_lambda_arn    = module.lambda.dossier_schemas_lambda_arn
#   dossier_schemas_lambda_name    = module.lambda.dossier_schemas_lambda_name
#   # dossier_audit_lambda_name     = module.lambda.dossier_schemas_lambda_name
#   dossier_audit_lambda_name      = module.lambda.dossier_audit_lambda_name
#   dossier_failure_topic_arn     = module.sns.dossier_failure_topic_arn
#   dossier_success_topic_arn     = module.sns.dossier_success_topic_arn
#   glue_dossier_delta_load_job_name = module.glue.glue_dossier_delta_load_job_name
#   glue_platform_data_incremental_load_job_name = module.glue.glue_platform_data_incremental_load_job_name
#   dynamoDB_tables_count_lambda_arn  = module.lambda.dynamoDB_tables_count_lambda_arn
#   platform_data_failure_topic_arn = module.sns.platformdata_failure_topic_arn
#   platform_data_success_topic_arn = module.sns.platformdata_success_topic_arn
#   data_curator_lambda_name       = module.lambda.data_curator_lambda_name
#   cleaning_data_success_topic_arn = module.sns.cleaning_data_success_topic_arn
#   cleaning_data_failure_topic_arn  = module.sns.cleaning_data_failure_topic_name
#   cleansed_schema_counts_lambda_name = module.lambda.cleansed_schema_counts_lambda_name


#   env    = var.env
#   tags   = var.tags
# }








# main.tf - Root module with fixed dependency cycle

# First, create the minimal IAM module with just the roles (no policies that depend on KMS)
# module "iam_basic" {
#   source = "./modules/iam-basic"
#   env    = var.env
#   tags   = var.tags
# }

# main.tf - Root module with policy updaters

# First, create IAM module with simplified roles and policies
module "iam" {
  source = "./modules/iam"
  env    = var.env
  tags   = var.tags
  
  # # Pass minimal required values, empty strings for values that would create circular dependencies
  datalake_kms_key_arn = module.kms.datalake_kms_key_arn
  # amcs_secret_name = ""
  # audit_lambda_name = ""
  # amcs_s3_lambda_sns_name = ""
  # amcs_s3_success_topic_arn = ""
  # amcs_s3_failure_topic_arn = ""
  # amcs_schema_counts_lambda_name = ""
  # glue_amcs_incremental_job_name = ""
  # dossier_audit_lambda_name = ""
  # cleansed_bucket_name = ""
  # cleansed_schema_counts_lambda_name = ""
  depends_on = [module.kms]
}

# Create KMS module with simplified policy
module "kms" {
  source = "./modules/kms"
  tags   = var.tags
  env    = var.env

  # depends_on = [module.iam]
  
  # # Pass the glue_role_arn but use empty strings for other values
  # glue_role_arn = module.iam.glue_role_arn
  
  # # Empty strings for values that would create circular dependencies
  # raw_bucket_arn = ""
  # cleansed_bucket_arn = ""
  # curated_bucket_arn = ""
  # operational_bucket_arn = ""
  # platform_data_bucket_arn = ""
  # temp_bucket_arn = ""
  # aws_glue_bucket_arn = ""
  # dossier_layer_bucket_arn = ""
  # pw_reporting_bucket_arn = ""
  # pw_amcs_historical_bucket_arn = ""
  
  # incremental_log_group_arn = ""
  # data_ingestion_netsuite_log_group_arn = ""
  # platform_data_incremental_log_group_arn = ""
  # dossier_delta_load_log_group_arn = ""
  # data_cleansing_log_group_arn = ""
  # connect_files_log_group_arn = ""
  # heavy_haul_file_log_group_arn = ""
  # residential_file_data_log_group_arn = ""
  
  # glue_amcs_incremental_job_name = ""
  # glue_data_ingestion_netsuite_job_name = ""
  # glue_platform_data_incremental_load_job_name = ""
  # glue_dossier_delta_load_job_name = ""
  # glue_data_cleansing_job_name = ""
  # glue_connect_files_job_name = ""
  # glue_heavy_haul_file_job_name = ""
  # glue_residential_file_data_job_name = ""
  
  
}

# Create SNS module (no dependencies)
module "sns" {
  source = "./modules/sns"
  env    = var.env
  tags   = var.tags
  subscription_email = var.subscription_email
  # raw_bucket_arn = module.s3.raw_bucket_arn
  # cleansed_bucket_arn = module.s3.cleansed_bucket_arn
  # # aws_glue_bucket_name = module.s3.aws_glue_bucket_name
  # operational_bucket_arn    = module.s3.operational_bucket_arn
  # curated_bucket_arn         = module.s3.curated_bucket_arn
  # temp_bucket_arn            = module.s3.temp_bucket_arn

}

# Create CloudWatch module with KMS dependency
module "cloudwatch" {
  source = "./modules/cloudwatch"
  datalake_kms_key_arn = module.kms.datalake_kms_key_arn
  env    = var.env
  tags   = var.tags
  
  depends_on = [module.kms]
}

# Create S3 module with KMS and SNS dependencies
module "s3" {
  source          = "./modules/s3"
  env             = var.env
  datalake_kms_key_arn = module.kms.datalake_kms_key_arn
  s3_topic_arn    = module.sns.s3_topic_arn
  tags            = var.tags
  
  depends_on = [module.kms, module.sns]
}

# Create secrets manager module
module "secrete-manager" {
  source = "./modules/secrete-manager"
  env    = var.env
  tags   = var.tags
  datalake_kms_key_arn = module.kms.datalake_kms_key_arn
  
  # Variables for the secrets module
  server_name   = var.server_name
  database_name = var.database_name
  user_name     = var.user_name
  password      = var.password
  # driver_path   = var.driver_path
  raw_bucket_name  = module.s3.raw_bucket_name
  driver_class  = var.driver_class
  url           = var.url
  
  depends_on = [module.kms]
}

# Create security group module
module "security_group" {
  source = "./modules/sg"
  env    = var.env
  tags   = var.tags
}

# Create DynamoDB module
module "dynamodb" {
  source = "./modules/dynamodb"
  env    = var.env
  tags   = var.tags
  # s3_kms_key_arn = module.kms.s3_kms_key_arn
  datalake_kms_key_arn = module.kms.datalake_kms_key_arn
  
  depends_on = [module.kms]
}

# Create Lambda module
module "lambda" {
  source = "./modules/lambda"
  env    = var.env
  tags   = var.tags
  lambda_security_group_id = module.security_group.lambda_security_group_id
  lambda_role_arn = module.iam.lambda_role_arn

  #sns
  # amcs_s3_failure_topic_arn = module.sns.amcs_s3_failure_topic_arn
  # amcs_s3_success_topic_arn = module.sns.amcs_s3_success_topic_arn
  # dossier_failure_topic_arn = module.sns.dossier_failure_topic_arn
  # dossier_success_topic_arn = module.sns.dossier_success_topic_arn
  # platform_data_success_topic_arn = module.sns.platform_data_success_topic_arn
  # platform_data_failure_topic_arn = module.sns.platform_data_failure_topic_arn
  failure-notification-topic-arn  = module.sns.failure-notification-topic-arn
  success-notification-topic-arn  = module.sns.success-notification-topic-arn

  #
  amcs_secret_name = module.secrete-manager.amcs_secret_name
  # dossier_layer_bucket_name = module.s3.dossier_layer_bucket_name
  raw_bucket_name = module.s3.raw_bucket_name
  cleansed_bucket_name = module.s3.cleansed_bucket_name
  
  depends_on = [
    module.iam,
    module.security_group,
    module.sns,
    module.secrete-manager,
    module.s3
  ]
}

# Create Glue module with all dependencies
module "glue" {
  source = "./modules/glue"
  env    = var.env
  tags   = var.tags
  glue_role_arn = module.iam.glue_role_arn
  datalake_kms_key_arn = module.kms.datalake_kms_key_arn
  amcs_secret_name = module.secrete-manager.amcs_secret_name
  dossier_secret_name = module.secrete-manager.dossier_secret_name
  glue_security_group_id = module.security_group.glue_security_group_id
  
  # S3 bucket names
  # aws_glue_bucket_name = module.s3.aws_glue_bucket_name
  raw_bucket_name = module.s3.raw_bucket_name
  # dossier_layer_bucket_name = module.s3.dossier_layer_bucket_name
  operational_bucket_name     = module.s3.operational_bucket_name
  curated_bucket_name         = module.s3.curated_bucket_name

  # platform_data_bucket_name = module.s3.platform_data_bucket_name
  cleansed_bucket_name = module.s3.cleansed_bucket_name
  # pw_reporting_bucket_name = module.s3.pw_reporting_bucket_name
  # pw_amcs_historical_bucket_name = module.s3.pw_amcs_historical_bucket_name
  
  # CloudWatch log group names
  incremental_log_group_name = module.cloudwatch.incremental_log_group_name
  data_ingestion_netsuite_log_group_name = module.cloudwatch.data_ingestion_netsuite_log_group_name
  platform_data_incremental_log_group_name = module.cloudwatch.platform_data_incremental_log_group_name
  dossier_delta_load_log_group_name = module.cloudwatch.dossier_delta_load_log_group_name
  data_cleansing_log_group_name = module.cloudwatch.data_cleansing_log_group_name
  connect_files_log_group_name = module.cloudwatch.connect_files_log_group_name
  heavy_haul_file_log_group_name = module.cloudwatch.heavy_haul_file_log_group_name
  residential_file_data_log_group_name = module.cloudwatch.residential_file_data_log_group_name
  
  # SNS topic ARNs
  # amcs_s3_success_topic_arn = module.sns.amcs_s3_success_topic_arn
  # amcs_s3_failure_topic_arn = module.sns.amcs_s3_failure_topic_arn
  # platformdata_failure_topic_arn = module.sns.platformdata_failure_topic_arn
  # platformdata_success_topic_arn = module.sns.platformdata_success_topic_arn
  # cleaning_data_success_topic_arn = module.sns.cleaning_data_success_topic_arn
  # cleaning_data_failure_topic_arn = module.sns.cleaning_data_failure_topic_arn
  failure-notification-topic-arn  = module.sns.failure-notification-topic-arn
  success-notification-topic-arn  = module.sns.success-notification-topic-arn
  
  depends_on = [
    module.iam,
    module.kms,
    module.s3,
    module.cloudwatch,
    module.secrete-manager,
    module.sns
  ]
}

# Create Step Function module
module "step_function" {
  source = "./modules/step-function"
  env    = var.env
  tags   = var.tags
  step_function_role_arn = module.iam.step_function_role_arn
  
  # Lambda resources
  audit_lambda_name = module.lambda.audit_lambda_name
  audit_lambda_arn = module.lambda.audit_lambda_arn
  # amcs_s3_lambda_sns_name = module.lambda.amcs_s3_lambda_sns_name

  # amcs_schema_counts_lambda_arn = module.lambda.amcs_schema_counts_lambda_arn

  # dossier_schemas_lambda_arn = module.lambda.dossier_schemas_lambda_arn
  # dossier_schemas_lambda_name = module.lambda.dossier_schemas_lambda_name

  # dossier_audit_lambda_name = module.lambda.dossier_audit_lambda_name
  # dynamoDB_tables_count_lambda_arn = module.lambda.dynamoDB_tables_count_lambda_arn
  data_curator_lambda_name = module.lambda.data_curator_lambda_name
  all_datasources_lambda_arn = module.lambda.all_datasources_lambda_arn
  # cleansed_schema_counts_lambda_name = module.lambda.cleansed_schema_counts_lambda_name
  
  # Glue job names
  # glue_amcs_incremental_job_name = module.glue.glue_amcs_incremental_job_name
  amcs-data-ingestion-glue_name  = module.glue.amcs-data-ingestion-glue_name
  glue_dossier_delta_load_job_name = module.glue.glue_dossier_delta_load_job_name
  glue_platform_data_incremental_load_job_name = module.glue.glue_platform_data_incremental_load_job_name
  
  # SNS topics
  failure-notification-topic-arn  = module.sns.failure-notification-topic-arn
  success-notification-topic-arn  = module.sns.success-notification-topic-arn
  # amcs_s3_success_topic_arn = module.sns.amcs_s3_success_topic_arn
  # amcs_s3_failure_topic_arn = module.sns.amcs_s3_failure_topic_arn
  # dossier_failure_topic_arn = module.sns.dossier_failure_topic_arn
  # dossier_success_topic_arn = module.sns.dossier_success_topic_arn
  # platform_data_failure_topic_arn = module.sns.platform_data_failure_topic_arn
  # platform_data_success_topic_arn = module.sns.platform_data_success_topic_arn
  # cleaning_data_success_topic_arn = module.sns.cleaning_data_success_topic_arn
  # cleaning_data_failure_topic_arn = module.sns.cleaning_data_failure_topic_name
  
  depends_on = [
    module.iam, 
    module.lambda,
    module.glue,
    module.sns
  ]
}

# Update the KMS policy with specific resources
module "kms_policy_updater" {
  source = "./modules/kms-policy-updater"
  datalake_kms_key_arn = module.kms.datalake_kms_key_arn

  glue_role_arn = module.iam.glue_role_arn
  
  # Log group ARNs
  log_group_arns = [
    module.cloudwatch.incremental_log_group_arn,
    module.cloudwatch.data_ingestion_netsuite_log_group_arn,
    module.cloudwatch.platform_data_incremental_log_group_arn,
    module.cloudwatch.dossier_delta_load_log_group_arn,
    module.cloudwatch.data_cleansing_log_group__arn,
    module.cloudwatch.connect_files_log_group_arn,
    module.cloudwatch.heavy_haul_file_log_group_arn,
    module.cloudwatch.residential_file_data_log_group_arn
  ]
  
  # Bucket ARNs
  bucket_arns = [
    module.s3.raw_bucket_arn,
    module.s3.cleansed_bucket_arn,
    module.s3.curated_bucket_arn,
    module.s3.operational_bucket_arn,
    # module.s3.platform_data_bucket_arn,
    module.s3.temp_bucket_arn
    # module.s3.aws_glue_bucket_arn,
    # module.s3.dossier_layer_bucket_arn,
    # module.s3.pw_reporting_bucket_arn,
    # module.s3.pw_amcs_historical_bucket_arn
  ]
  
  # Glue job names
  glue_job_names = [
    module.glue.amcs-data-ingestion-glue_name,
    module.glue.glue_data_ingestion_netsuite_job_name,
    module.glue.glue_platform_data_incremental_load_job_name,
    module.glue.glue_dossier_delta_load_job_name,
    module.glue.glue_data_cleansing_job_name,
    module.glue.glue_connect_files_job_name,
    module.glue.glue_heavy_haul_file_job_name,
    module.glue.glue_residential_file_data_job_name
  ]
  
  depends_on = [
    module.cloudwatch,
    module.s3,
    module.glue,
    module.lambda,
    module.step_function
  ]
}

# Update IAM policies with specific resources
module "iam_policy_updater" {

  source = "./modules/iam-policy-updater"
  env    = var.env
  
  lambda_role_id = module.iam.lambda_role_id
  glue_role_name = module.iam.glue_role_name
  step_function_role_name = module.iam.step_function_role_name
  
  # S3 bucket names
  raw_bucket_name = module.s3.raw_bucket_name
  cleansed_bucket_name = module.s3.cleansed_bucket_name
  # aws_glue_bucket_name = module.s3.aws_glue_bucket_name
  operational_bucket_name     = module.s3.operational_bucket_name
  curated_bucket_name         = module.s3.curated_bucket_name


  # Secret name
  amcs_secret_name = module.secrete-manager.amcs_secret_name

  # Lambda function names
  audit_lambda_name = module.lambda.audit_lambda_name
  all_datasources_lambda_arn = module.lambda.all_datasources_lambda_arn
  # amcs_s3_lambda_sns_name = module.lambda.amcs_s3_lambda_sns_name

  # amcs_schema_counts_lambda_name = module.lambda.amcs_schema_counts_lambda_name
  # dossier_audit_lambda_name = module.lambda.dossier_audit_lambda_name
  # cleansed_schema_counts_lambda_name = module.lambda.cleansed_schema_counts_lambda_name
  
  # Glue job name
  amcs-data-ingestion-glue_name = module.glue.amcs-data-ingestion-glue_name
  
  # SNS topics
  failure-notification-topic-arn  = module.sns.failure-notification-topic-arn
  success-notification-topic-arn  = module.sns.success-notification-topic-arn
  # amcs_s3_success_topic_arn = module.sns.amcs_s3_success_topic_arn
  # amcs_s3_failure_topic_arn = module.sns.amcs_s3_failure_topic_arn
  # dossier_success_topic_arn = module.sns.dossier_success_topic_arn
  # dossier_failure_topic_arn = module.sns.dossier_failure_topic_arn
  # platform_data_success_topic_arn = module.sns.platform_data_success_topic_arn
  # platform_data_failure_topic_arn = module.sns.platform_data_failure_topic_arn
  # cleaning_data_success_topic_arn = module.sns.cleaning_data_success_topic_arn
  # cleaning_data_failure_topic_arn = module.sns.cleaning_data_failure_topic_arn
  
  depends_on = [
    module.iam,
    module.lambda,
    module.glue,
    module.s3,
    module.secrete-manager,
    module.sns,
    module.step_function
  ]
}
