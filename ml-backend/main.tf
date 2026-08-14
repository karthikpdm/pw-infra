module "s3" {
  source = "./modules/s3"
   
  project_name                  = var.project_name
  env                           = var.env
  s3_bucket_input_training_path = var.s3_bucket_input_training_path
  s3_bucket_output_models_path  = var.s3_bucket_output_models_path 
  s3_bucket_ml                  = var.s3_bucket_ml
  tags = var.tags
}

module "sagemaker" {
  source = "./modules/sagemaker"

  project_name                  = var.project_name
  env                           = var.env
  s3_bucket_input_training_path = var.s3_bucket_input_training_path
  s3_bucket_output_models_path  = var.s3_bucket_output_models_path
  s3_bucket_ml                  = var.s3_bucket_ml
  # model_artifact_s3_path        = var.model_artifact_s3_path
  model_image_uri               = var.model_image_uri
  model_name                    = var.model_name
  instance_type                 = var.instance_type
  initial_instance_count        = var.initial_instance_count 
  pipeline_name                 = var.pipeline_name 
  # pipeline_definition           = var.pipeline_definition
  model_registry_name           = var.model_registry_name
  model_registry_description    = var.model_registry_description
  tags = var.tags
}


module "ecr" {
  source = "./modules/ecr"
  
  project_name                  = var.project_name
  env                           = var.env
  scan                          = var.scan
  tags = var.tags
}

module "ec2" {
  source = "./modules/ec2"
  
  ec2_ami                      = var.ec2_ami 
  ec2_instance_type            = var.ec2_instance_type
  ec2_security_group_name      = var.ec2_security_group_name 
  env                          = var.env
  tags = var.tags
}

module "lambda" {
  source = "./modules/lambda"
  tags = var.tags
}