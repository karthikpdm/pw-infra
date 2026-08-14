provider "aws" {
  region = "us-east-1"
}


module "iam" {
  source                                      = "./modules/iam"

  codebuild_infra_role_name                   = "pw-role-codebuild-infra_role"
  codepipeline_infra_role_name                = "pw-role-codepipeline-infra_role"
  codeguru_reviewer_role_name                 =  "pw-role-codeguru_reviewer_role"
  artifact_bucket_arn                         = module.s3.artifact_bucket_arn
  build_logs_store_arn                        = module.s3.build_logs_bucket_arn
  dev_account_role_arn                        = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  uat_account_role_arn                        = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
# prod_account_role_arn                       = var.prod_account_role_arn
  pw_codebuild_infra_terraform_plan_arn       = module.infra-base-dev.pw_codebuild_infra_terraform_plan_arn
  pw_codebuild_infra_terraform_apply_arn      = module.infra-base-dev.pw_codebuild_infra_terraform_apply_arn
  aws_sns_topic_manual_approval_arn           = module.infra-base-dev.sns_topic_infra_arn
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  tags = var.tags
 

}

module "s3" {

  source = "./modules/s3"

  artifact_bucket_name = "pw-s3-artifacts-pipeline"
  build-logs_bucket_name = "pw-s3-buildlogs-pipeline"
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  
  access_logs_bucket_name = "pw-s3-access-logs-store"

  tags = var.tags

}
 # access_logs_bucket_name = "pw-s3-access-logs-store"



#*************************** infra pipelines root module ******************************************



#################################################################################################

##################################  infra-base ##################################################

#######################################  dev ####################################################

module "infra-base-dev" {

  source = "./modules/infra-base"


  project_name     = "infra-base"
  environment    = "dev"
  branch = "dev"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-base"
  aws_region = "us-east-1"
  tags = var.tags


}


#######################################  uat ####################################################

module "infra-base-uat" {

  source = "./modules/infra-base"


  project_name     = "infra-base"
  environment    = "uat"
  branch = "uat"
  TFVARS_FILE = "environments/uat/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-base"
  aws_region = "us-east-1"
  tags = var.tags

}


# #######################################  prod ####################################################

module "infra-base-prod" {

  source = "./modules/infra-base"


  project_name     = "infra-base"
  environment    = "prod"
  branch = "main"
  TFVARS_FILE = "environments/uat/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-base"
  aws_region = "us-east-1"
  tags = var.tags
}















######################################################################################################

##################################  infra-microservices ##################################################

#######################################  dev #########################################################


module "infra-microservices-dev" {

  source = "./modules/infra-microservices"


  project_name     = "infra-microservices"
  environment    = "dev"
  branch = "dev"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-microservices"
  aws_region = "us-east-1"
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  # devops-account_role_arn     = "arn:aws:iam::339713024244:role/pw-role-codebuild-infra_role"
  tags = var.tags

}

#######################################  uat #########################################################


module "infra-microservices-uat" {

  source = "./modules/infra-microservices"


  project_name     = "infra-microservices"
  environment    = "uat"
  branch = "uat"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-microservices"
  aws_region = "us-east-1"
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  # devops-account_role_arn     = "arn:aws:iam::339713024244:role/pw-role-codebuild-infra_role"
  tags = var.tags


}


######################################################################################################

##################################  frontend-infra ##################################################

#######################################  dev #########################################################


module "infra-frontend-dev" {

  source = "./modules/infra-frontend"


  project_name     = "infra-frontend"
  environment    = "dev"
  branch = "dev"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-frontend"
  aws_region = "us-east-1"
  tags = var.tags
}


#######################################  uat #########################################################


module "infra-frontend-uat" {

  source = "./modules/infra-frontend"


  project_name     = "infra-frontend"
  environment    = "uat"
  branch = "uat"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-frontend"
  aws_region = "us-east-1"
  tags = var.tags
}



######################################################################################################

##################################  infra-datalake ##################################################

#######################################  dev #########################################################


module "infra-datalake-dev" {

  source = "./modules/infra-datalake"


  project_name     = "infra-datalake"
  environment    = "dev"
  branch = "dev"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-datalake"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  uat #########################################################


module "infra-datalake-uat" {

  source = "./modules/infra-datalake"


  project_name     = "infra-datalake"
  environment    = "uat"
  branch = "uat"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-datalake"
  aws_region = "us-east-1"
  tags = var.tags
}









#####################################################################################################

##################################  contact-center ##################################################

#######################################  dev #########################################################


module "contact-center-dev" {

  source = "./modules/contact-center"


  project_name     = "contact-center"
  environment    = "dev"
  branch = "dev"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "contact-center"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  uat ####################################################
module "contact-center-uat" {

  source = "./modules/contact-center"


  project_name     = "contact-center"
  environment    = "uat"
  branch = "uat"
  TFVARS_FILE = "environments/uat/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "contact-center"
  aws_region = "us-east-1"
  tags = var.tags
}


#######################################  prod ####################################################

module "contact-center-prod" {

  source = "./modules/contact-center"


  project_name     = "contact-center"
  environment    = "prod"
  branch = "main"
  TFVARS_FILE = "environments/prod/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "contact-center"
  aws_region = "us-east-1"
  tags = var.tags
}













#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################




##################################   backend deploy pipeline #######################################








































































####################################################################################################
####################################################################################################
####################################################################################################

######################################## infra-fleet ###############################################


#######################################  dev ####################################################


# module "infra-fleet-dev" {

#   source = "./modules/infra-fleet"


#   project_name                = "infra-fleet"
#   environment                 = "dev"
#   branch                      = "dev"
#   TFVARS_FILE                 = "environments/dev/terraform.tfvars"
#   codebuild_infra_role_arn    = module.iam.codebuild_role_arn
#   codepipeline_infra_role_arn = module.iam.codepipeline_role_arn
#   artifact_bucket_name        = module.s3.artifact_bucket_name
#   build-logs_bucket_name      = module.s3.build-logs_bucket_name
#   bitbucket_connection_arn    = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
#   bitbucket_account           = "prioritywaste"
#   bitbucket_repo_name         =  "infra-fleet"
#   aws_region                  = "us-east-1"
#   tags = var.tags
# }

####################################################################################################
####################################################################################################
####################################################################################################

######################################## ml-backend ###############################################


#######################################  dev ####################################################

module "ml-backend-dev" {
  source = "./modules/ml-backend"
  
  project_name     = "ml-backend"
  environment    = "dev"
  branch = "dev"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "ml-backend"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  uat ####################################################

module "ml-backend-uat" {
  source = "./modules/ml-backend"
  
  project_name     = "ml-backend"
  environment    = "uat"
  branch = "uat"
  TFVARS_FILE = "environments/uat/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "ml-backend"
  aws_region = "us-east-1"
  tags = var.tags
}


#******************************************************************************************************

# ##################################################################################################
####################################################################################################
####################################################################################################


####################################    iot-backend     ##############################################


####################################   dev ##############################################


module "iot-backend-dev" {
  source = "./modules/iot-backend"


  project_name     = "iot-backend"
  environment    = "dev"
  branch = "dev"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "iot-backend"
  aws_region = "us-east-1"
  tags = var.tags
}


# ##################################################################################################

####################################   uat ##############################################


module "iot-backend-uat" {
  source = "./modules/iot-backend"


  project_name     = "iot-backend"
  environment    = "uat"
  branch = "uat"
  TFVARS_FILE = "environments/uat/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "iot-backend"
  aws_region = "us-east-1"
  tags = var.tags
}


# ##################################################################################################
####################################################################################################
####################################################################################################


# ####################################telemetery-solutions##############################################


# ####################################   dev ##############################################


# module "telemetery-solutions-dev" {
#   source = "./modules/telemetery-solutions"
  
#   project_name                = "iot-backend"
#   environment                 = "dev"  
#   branch                      = "dev"  
#   deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
#   codebuild_infra_role_arn   = module.iam.codebuild_role_arn
#   codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
#   artifact_bucket_name    = module.s3.artifact_bucket_name
#   build-logs_bucket_name  = module.s3.build-logs_bucket_name
#   bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
#   bitbucket_account        = "prioritywaste"
#   bitbucket_repo_name      =  "iot-backend"
#   tags = var.tags
# }


######################################## frontend-infra ###############################################


#######################################  dev ####################################################


# module "contact-center" {

#   source = "./modules/contact-center"


#   # sample.tfvars

# project_name = "contact-center"
# environment  = "dev"
# branch = "dev"


# eks_cluster_name   = "pw-eks-cluster"
# eks_cluster_region = "us-west-2"

# target_role_arn = "arn:aws:iam::987654321098:role/eks-deploy-role"


# bitbucket_connection_arn = "arn:aws:codestar-connections:us-west-2:123456789012:connection/abcdef12-3456-7890-abcd-ef1234567890"
# bitbucket_account        = "your-bitbucket-account"
# bitbucket_repo_name      = "contact-center"

# codebuild_infra_role_arn   = module.iam.codebuild_role_arn
# codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
# artifact_bucket_name    = module.s3.artifact_bucket_name
# build-logs_bucket_name  = module.s3.build-logs_bucket_name


# }


# ##################################################################################################

module "portal-backend-demo" {
  source = "./modules/portal-backend"
  
  project_name                = "portal-backend"
  environment                 = "dev"  
  branch                      = "demo"  
  eks_cluster_region          = "us-east-1"
  eks_cluster_name            = "pw-eks-cluster-dev"
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend"
  # aws_region  = "us-east-1"
  # target_role_arn   = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  tags = var.tags

}


#########################################################################################################

# module "codeguru-demo" {
#   source = "./modules/codeguru-demo"
  
#   project_name     = "codeguru-demo"
#   environment    = "dev"
#   branch = "dev"
#   TFVARS_FILE = "environments/dev/terraform.tfvars"
#   codebuild_infra_role_arn   = module.iam.codebuild_role_arn
#   codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
#   artifact_bucket_name    = module.s3.artifact_bucket_name
#   build-logs_bucket_name  = module.s3.build-logs_bucket_name
#   bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
#   bitbucket_account        = "prioritywaste"
#   bitbucket_repo_name      =  "codeguru-demo"
#   # aws_region  = "us-east-1"
#   # target_role_arn   = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
#   tags = var.tags

# }

# ###################################  portal-backend-customer   ##########################################################

#######################################  dev ####################################################

module "portal-backend-customer-dev" {
  source = "./modules/portal-backend-customer"
  
  project_name                = "portal-backend-customer"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-customer"
  aws_region = "us-east-1"
  tags = var.tags
}


# ##################################################################################################
#######################################  uat ####################################################

module "portal-backend-customer-uat" {
  source = "./modules/portal-backend-customer"
  
  project_name                = "portal-backend-customer"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-customer"
  aws_region = "us-east-1"
  tags = var.tags
}
# ###############################  portal-backend-job   #################################################################
#######################################  dev ####################################################

module "portal-backend-job-dev" {
  source = "./modules/portal-backend-job"
  
  project_name                = "portal-backend-job"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-job"
  aws_region = "us-east-1"
  tags = var.tags
}

##################################################################################################
#######################################  uat ####################################################

module "portal-backend-job-uat" {
  source = "./modules/portal-backend-job"
  
  project_name                = "portal-backend-job"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-job"
  aws_region = "us-east-1"
  tags = var.tags
}




# ###############################   portal-backend-payment  ###################################################################
#######################################  dev ####################################################

module "portal-backend-payment-dev" {
  source = "./modules/portal-backend-payment"
  
  project_name                = "portal-backend-payment"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-payment"
  aws_region = "us-east-1"
  tags = var.tags
}

# ##################################################################################################
#######################################  uat ####################################################

module "portal-backend-payment-uat" {
  source = "./modules/portal-backend-payment"
  
  project_name                = "portal-backend-payment"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-payment"
  aws_region = "us-east-1"
  tags = var.tags
}

# ###################################  portal-backend-rbac  ###############################################################
#######################################  dev ####################################################

module "portal-backend-rbac-dev" {
  source = "./modules/portal-backend-rbac"
  
  project_name                = "portal-backend-rbac"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-rbac"
  aws_region = "us-east-1"
  tags = var.tags
}

# ##################################################################################################
#######################################  uat ####################################################

module "portal-backend-rbac-uat" {
  source = "./modules/portal-backend-rbac"
  
  project_name                = "portal-backend-rbac"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-rbac"
  aws_region = "us-east-1"
  tags = var.tags
}


####################################################################################################
####################################################################################################
####################################################################################################
# ###################################  portal-backend-website  ###############################################################
#######################################  dev ####################################################

module "portal-backend-website-dev" {
  source = "./modules/portal-backend-website"
  
  project_name                = "portal-backend-website"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-website"
  aws_region = "us-east-1"
  tags = var.tags
}

# ##################################################################################################
#######################################  uat ####################################################

module "portal-backend-website-uat" {
  source = "./modules/portal-backend-website"
  
  project_name                = "portal-backend-website"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-website"
  aws_region = "us-east-1"
  tags = var.tags
}


# ###################################  portal-backend-upload   ##########################################################

#######################################  dev ####################################################

module "portal-backend-upload-dev" {
  source = "./modules/portal-backend-upload"
  
  project_name                = "portal-backend-upload"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-upload"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  uat ####################################################

module "portal-backend-upload-uat" {
  source = "./modules/portal-backend-upload"
  
  project_name                = "portal-backend-upload"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-upload"
  aws_region = "us-east-1"
  tags = var.tags
}



# ##################################################################################################



# ###################################  fleet-backend-vehicle  ##########################################################

#######################################  dev ####################################################

module "fleet-backend-vehicle-dev" {
  source = "./modules/fleet-backend-vehicle"
  
  project_name                = "fleet-backend-vehicle"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "fleet-backend-vehicle"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  uat ####################################################

module "fleet-backend-vehicle-uat" {
  source = "./modules/fleet-backend-vehicle"
  
  project_name                = "fleet-backend-vehicle"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "fleet-backend-vehicle"
  aws_region = "us-east-1"
  tags = var.tags
}

# ###################################  fleet-backend-driver  ##########################################################

#######################################  dev ####################################################

module "fleet-backend-driver-dev" {
  source = "./modules/fleet-backend-driver"
  
  project_name                = "fleet-backend-driver"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "fleet-backend-driver"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  uat ####################################################

module "fleet-backend-driver-uat" {
  source = "./modules/fleet-backend-driver"
  
  project_name                = "fleet-backend-driver"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "fleet-backend-driver"
  aws_region = "us-east-1"
  tags = var.tags
}





# ###################################  backend-integration-service  ##########################################################

#######################################  dev ####################################################

module "backend-integration-service-dev" {
  source = "./modules/backend-integration-service"
  
  project_name                = "backend-integration-service"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "backend-integration-service"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  uat ####################################################

module "backend-integration-service-uat" {
  source = "./modules/backend-integration-service"
  
  project_name                = "backend-integration-service"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "backend-integration-service"
  aws_region = "us-east-1"
  tags = var.tags
}

# ##################################################################################################

# ##################################################################################################
# ###################################  cental-swagger-aggregator  ###############################################################
#######################################  dev ####################################################

module "cental-swagger-aggregator-dev" {
  source = "./modules/cental-swagger-aggregator"
  
  project_name                = "cental-swagger-aggregator"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "cental-swagger-aggregator"
  aws_region = "us-east-1"
  tags = var.tags
}


# ##################################################################################################
# ###################################  driver-app  ###############################################################
#######################################  dev ####################################################

module "driver-app-dev" {
  source = "./modules/driver-app"
  
  project_name                = "driver-app"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "driver-app"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  uat ####################################################

module "driver-app-uat" {
  source = "./modules/driver-app"
  
  project_name                = "driver-app"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "driver-app"
  aws_region = "us-east-1"
  tags = var.tags
}


# ##################################################################################################
# ###################################  portal-backend-driver  ###############################################################
#######################################  dev ####################################################

module "portal-backend-driver-dev" {
  source = "./modules/portal-backend-driver"
  
  project_name                = "portal-backend-driver"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-driver"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  uat ####################################################

module "portal-backend-driver-uat" {
  source = "./modules/portal-backend-driver"
  
  project_name                = "portal-backend-driver"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-driver"
  aws_region = "us-east-1"
  tags = var.tags
}



# ##################################################################################################
# ###################################  portal-backend-scheduler-dispatcher  ###############################################################
#######################################  dev ####################################################

module "portal-backend-scheduler-dispatcher-dev" {
  source = "./modules/portal-backend-scheduler-dispatcher"
  
  project_name                = "portal-backend-scheduler-dispatcher"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-scheduler-dispatcher"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  uat ####################################################

module "portal-backend-scheduler-dispatcher-uat" {
  source = "./modules/portal-backend-scheduler-dispatcher"
  
  project_name                = "portal-backend-scheduler-dispatcher"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-scheduler-dispatcher"
  aws_region = "us-east-1"
  tags = var.tags
}

# ##################################################################################################
# ###################################  portal-backend-internal-upload  ###############################################################
#######################################  dev ####################################################

module "portal-backend-internal-upload-dev" {
  source = "./modules/portal-backend-internal-upload"
  
  project_name                = "portal-backend-internal-upload"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-backend-internal-upload"
  aws_region = "us-east-1"
  tags = var.tags
}



# ##################################################################################################
# ###################################  portal-frontend-scheduler  ###############################################################
#######################################  dev ####################################################

module "portal-frontend-scheduler-dev" {
  source = "./modules/portal-frontend-scheduler"
  
  project_name                = "portal-frontend-scheduler"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-frontend-scheduler"
  aws_region = "us-east-1"
  tags = var.tags
}


#######################################  uat ####################################################

module "portal-frontend-scheduler-uat" {
  source = "./modules/portal-frontend-scheduler"
  
  project_name                = "portal-frontend-scheduler"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-frontend-scheduler"
  aws_region = "us-east-1"
  tags = var.tags
}

# ##################################################################################################
# ###################################  portal-frontend ###############################################################
#######################################  dev ####################################################

module "portal-frontend-dev" {
  source = "./modules/portal-frontend"
  
  project_name                = "portal-frontend"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-frontend"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  uat ####################################################

module "portal-frontend-uat" {
  source = "./modules/portal-frontend"
  
  project_name                = "portal-frontend"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-frontend"
  aws_region = "us-east-1"
  tags = var.tags
}

# ##################################################################################################
# ###################################  portal-frontend-website  ###############################################################
#######################################  dev ####################################################

module "portal-frontend-website-dev" {
  source = "./modules/portal-frontend-website"
  
  project_name                = "portal-frontend-website"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-frontend-website"
  aws_region = "us-east-1"
  tags = var.tags
}


#######################################  uat ####################################################

module "portal-frontend-website-uat" {
  source = "./modules/portal-frontend-website"
  
  project_name                = "portal-frontend-website"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-uat-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "portal-frontend-website"
  aws_region = "us-east-1"
  tags = var.tags
}


# ##################################################################################################
# ###################################  fleet-frontend ###############################################################
#######################################  dev ####################################################

module "fleet-frontend-dev" {
  source = "./modules/fleet-frontend"
  
  project_name                = "fm-frontend"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "fm-frontend"
  aws_region = "us-east-1"
  tags = var.tags
}







####################################################################################################
####################################################################################################
####################################################################################################

######################################## infra-pulse-frontend ###############################################


#######################################  dev ####################################################

module "infra-pulse-frontend-dev" {
  source = "./modules/infra-pulse-frontend"
  
  project_name     = "infra-pulse-frontend"
  environment    = "dev"
  branch = "dev"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-pulse-frontend"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  uat ####################################################

module "infra-pulse-frontend-uat" {
  source = "./modules/infra-pulse-frontend"
  
  project_name     = "infra-pulse-frontend"
  environment    = "uat"
  branch = "uat"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-pulse-frontend"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  prod ####################################################

module "infra-pulse-frontend-prod" {
  source = "./modules/infra-pulse-frontend"
  
  project_name     = "infra-pulse-frontend"
  environment    = "prod"
  branch = "main"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-pulse-frontend"
  aws_region = "us-east-1"
  tags = var.tags
}

######################################## pulse_frontend ###############################################


#######################################  dev ####################################################

module "pulse-frontend-dev" {
  source = "./modules/pulse-frontend"
  
  project_name                = "pulse-frontend"
  environment                 = "dev"  
  branch                      = "dev"  
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  configuration               = "development"
  codebuild_infra_role_arn    = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn = module.iam.codepipeline_role_arn
  artifact_bucket_name        = module.s3.artifact_bucket_name
  build-logs_bucket_name      = module.s3.build-logs_bucket_name
  bitbucket_connection_arn    = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account           = "prioritywaste"
  bitbucket_repo_name         =  "pulse-frontend"
  tags = var.tags

}

#######################################  uat ####################################################

module "pulse-frontend-uat" {
  source = "./modules/pulse-frontend"
  
  project_name                = "pulse-frontend"
  environment                 = "uat"  
  branch                      = "uat"  
  deployment_role_arn         = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  configuration               = "staging"
  codebuild_infra_role_arn    = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn = module.iam.codepipeline_role_arn
  artifact_bucket_name        = module.s3.artifact_bucket_name
  build-logs_bucket_name      = module.s3.build-logs_bucket_name
  bitbucket_connection_arn    = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account           = "prioritywaste"
  bitbucket_repo_name         =  "pulse-frontend"
  tags = var.tags
  
}

#######################################  prod ####################################################

module "pulse-frontend-prod" {
  source = "./modules/pulse-frontend"
  
  project_name                = "pulse-frontend"
  environment                 = "prod"  
  branch                      = "main"  
  deployment_role_arn         = "arn:aws:iam::471112621064:role/pw-role-prod-crossaccount_infra_role"
  configuration               = "production"
  codebuild_infra_role_arn    = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn = module.iam.codepipeline_role_arn
  artifact_bucket_name        = module.s3.artifact_bucket_name
  build-logs_bucket_name      = module.s3.build-logs_bucket_name
  bitbucket_connection_arn    = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account           = "prioritywaste"
  bitbucket_repo_name         =  "pulse-frontend"
  tags = var.tags
  
}



######################################## infra-pulse-backend ###############################################


#######################################  dev ####################################################

module "infra-pulse-backend-dev" {
  source = "./modules/infra-pulse-backend"
  
  project_name     = "infra-pulse-backend"
  environment    = "dev"
  branch = "dev"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-pulse-backend"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  uat ####################################################

module "infra-pulse-backend-uat" {
  source = "./modules/infra-pulse-backend"
  
  project_name     = "infra-pulse-backend"
  environment    = "uat"
  branch = "uat"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-pulse-backend"
  aws_region = "us-east-1"
  tags = var.tags
}

#######################################  prod ####################################################

module "infra-pulse-backend-prod" {
  source = "./modules/infra-pulse-backend"
  
  project_name     = "infra-pulse-backend"
  environment    = "prod"
  branch = "main"
  TFVARS_FILE = "environments/dev/terraform.tfvars"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "infra-pulse-backend"
  aws_region = "us-east-1"
  tags = var.tags
}




######################################## pulse-backend ###############################################


#######################################  dev ####################################################

module "pulse-backend-dev" {
  source = "./modules/pulse-backend"

  
  project_name     = "pulse-backend"
  environment    = "dev"
  branch = "dev"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "pulse-backend"
  aws_region = "us-east-1"
  deployment_role_arn = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  tags = var.tags

}


#######################################  uat ####################################################

module "pulse-backend-uat" {
  source = "./modules/pulse-backend"

  
  project_name     = "pulse-backend"
  environment    = "uat"
  branch = "uat"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "pulse-backend"
  aws_region = "us-east-1"
  deployment_role_arn = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
  tags = var.tags

}


#######################################  prod ####################################################

module "pulse-backend-prod" {
  source = "./modules/pulse-backend"

  
  project_name     = "pulse-backend"
  environment    = "prod"
  branch = "main"
  codebuild_infra_role_arn   = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn   = module.iam.codepipeline_role_arn
  artifact_bucket_name    = module.s3.artifact_bucket_name
  build-logs_bucket_name  = module.s3.build-logs_bucket_name
  bitbucket_connection_arn = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account        = "prioritywaste"
  bitbucket_repo_name      =  "pulse-backend"
  aws_region = "us-east-1"
  deployment_role_arn = "arn:aws:iam::471112621064:role/pw-role-prod-crossaccount_infra_role"
  tags = var.tags
}

########################################################################################################



######################################## mock-mobile-app ###############################################


#######################################  dev ####################################################

module "mock-mobile-app-dev" {
  source = "./modules/mock-mobile-app"
  
  project_name                = "mock-mobile-app-poc"
  environment                 = "dev"  
  branch                      = "dev"  
  s3_bucket_name              = "pw-s3-dev-mobile-app"
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn    = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn = module.iam.codepipeline_role_arn
  artifact_bucket_name        = module.s3.artifact_bucket_name
  build-logs_bucket_name      = module.s3.build-logs_bucket_name
  bitbucket_connection_arn    = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account           = "prioritywaste"
  bitbucket_repo_name         =  "mock-mobile-app"
  tags = var.tags
}


module "mobile-customer-app-dev" {
  source = "./modules/mock-mobile-app"
  
  project_name                = "mobile-customer-app"
  environment                 = "dev"  
  branch                      = "dev"  
  s3_bucket_name              = "pw-s3-dev-mobile-app"
  deployment_role_arn         = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
  codebuild_infra_role_arn    = module.iam.codebuild_role_arn
  codepipeline_infra_role_arn = module.iam.codepipeline_role_arn
  artifact_bucket_name        = module.s3.artifact_bucket_name
  build-logs_bucket_name      = module.s3.build-logs_bucket_name
  bitbucket_connection_arn    = "arn:aws:codeconnections:us-east-1:339713024244:connection/be627432-fbf2-4fc8-9a93-c7c907a5217c"
  bitbucket_account           = "prioritywaste"
  bitbucket_repo_name         =  "mobile-customer-app"
  tags = var.tags
}



