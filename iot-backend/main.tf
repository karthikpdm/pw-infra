module "aws-dynamodb" {
  source = "./modules/aws-dynamodb"

  tags = var.tags
}

module "aws-location-service" {
  source = "./modules/aws-location-service"
  
  tags = var.tags
}

module "aws-lambda" {
  source = "./modules/aws-lambda"

  tableName_liveVehicleStatus = module.aws-dynamodb.tableName_liveVehicleStatus
  tableName_telemetryData     = module.aws-dynamodb.tableName_telemetryData
  table_liveVehicleStatus     = module.aws-dynamodb.table_liveVehicleStatus
  table_telemetryData         = module.aws-dynamodb.table_telemetryData
  arn_kvs_telemetry           = module.aws-kinesis.arn_kvs_telemetry
  telemetry_tracker_name      = module.aws-location-service.telemetry_tracker_name

  s3_ml_domain_name = module.aws-s3.s3_ml_domain_name
  env = var.env
  region = var.region
  tags = var.tags
  
  depends_on = [
    module.aws-s3,
    module.aws-dynamodb
  ]
}

module "aws-iot" {
  source = "./modules/aws-iot"

  location_logs            = "/aws/iot/telemetry"
  lambda_arn_telemetry     = module.aws-lambda.lambda_arn_telemetry
  name_kvs_telemetry       = module.aws-kinesis.name_kvs_telemetry
  table_liveVehicleStatus  = module.aws-dynamodb.table_liveVehicleStatus
  table_telemetryData      = module.aws-dynamodb.table_telemetryData
  tags                     = var.tags
  table_mlAlerts           = module.aws-dynamodb.table_mlAlerts
  tableName_mlAlerts       = module.aws-dynamodb.tableName_mlAlerts

  depends_on = [
    module.aws-lambda,
    module.aws-dynamodb
  ]

}

module "aws-api-gateway" {
    source = "./modules/aws-api-gateway"
    tags = var.tags
    env  = var.env
    depends_on = [
      module.aws-lambda
    ]
}

module "aws_cognito" {
  source                      = "./modules/aws-cognito"
  identity_pool_name          = var.identity_pool_name
  identity_pool_role_name_arn = var.identity_pool_role_name_arn
  tags                        = var.tags
}


module "aws-kinesis" {
  source = "./modules/aws-kinesis"
  tags   = var.tags
}

#module "greengrass_components" {
#  source = "./modules/greengrass_components"

#  component_name  = var.component_name
#  recipe_file     = var.recipe_file
#  artifacts       = var.artifacts
#  s3_bucket_name  = var.s3_bucket_name
#  region          = var.region
#  tags            = var.tags
#  assume_role_arn = var.assume_role_arn
#}

module "location_service" {
  source           = "./modules/recipe_component"
  s3_bucket_name   = var.s3_bucket_name
  recipe_file      = var.location_recipe_file
  artifacts        = var.location_artifacts
  region           = var.region
  assume_role_arn  = var.assume_role_arn
  tags             = var.tags
  component_name   = var.location_component_name
}

module "kinesis_video" {
  source           = "./modules/recipe_component"
  s3_bucket_name   = var.s3_bucket_name
  recipe_file      = var.kinesis_recipe_file
  artifacts        = var.kinesis_artifacts
  region           = var.region
  assume_role_arn  = var.assume_role_arn
  tags             = var.tags
  component_name   = var.kinesis_component_name
}

module "aws-s3" {
  source  = "./modules/aws-s3"

  env     = var.env
  tags    = var.tags
}
