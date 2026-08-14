# main.tf

module "iam" {
  source = "./modules/iam"

  project_name                  = "pw"
  env                           = var.env
  eks_oidc_provider_arn         = module.eks.oidc_provider_arn
  eks_oidc_provider_url         = module.eks.oidc_provider_url
  map_tagging                   = var.map_tagging
  
  account_id = var.account_id
  
  eks_s3_bucket_arns      = var.eks_s3_bucket_arns
  eks_kms_arns            = var.eks_kms_arns
  eks_secret_manage_arns  = var.eks_secret_manage_arns
  eks_dynamodb_arns       = var.eks_dynamodb_arns
}

module "security_groups" {
  source = "./modules/sg"

  project_name          = "pw"
  env                   = var.env
  master_ingress_rules  = var.master_ingress_rules
  master_egress_rules   = var.master_egress_rules
  map_tagging           = var.map_tagging
  workers_ingress_rules = var.workers_ingress_rules
  workers_egress_rules  = var.workers_egress_rules
  eks_workers_sg_id     = var.eks_workers_sg_id
}

module "eks" {
  source = "./modules/eks"

  project_name                  = "pw"
  env                           = var.env
  eks_version                   = var.eks_version
  master_role_arn               = module.iam.master_role_arn
  worker_role_arn               = module.iam.worker_role_arn
  desired_size                  = var.desired_size
  max_size                      = var.max_size
  min_size                      = var.min_size
  disk_size                     = var.disk_size
  max_unavailable               = var.max_unavailable
  instance_type                 = var.instance_type
  eks_master_sg_id              = module.security_groups.eks_master_sg_id
  aws_region                    = var.aws_region
  map_tagging                   = var.map_tagging
  ami_type                      = var.ami_type
  
  karpenter_version             = var.karpenter_version
  karpenter_vcpu                = var.karpenter_vcpu
  karpenter_memory              = var.karpenter_memory
  
  
  customer_namespace_name       = module.alb_controller.customer_namespace_name
  website_namespace_name        = module.alb_controller.website_namespace_name
  internal_namespace_name       = module.alb_controller.internal_namespace_name
  
  account_id = var.account_id
  
  eks_node_additional_policy    = module.iam.eks_node_additional_policy
  
  metrics_server_version        = var.metrics_server_version
  fluent_bit_version            = var.fluent_bit_version
}


module "alb_controller" {
  source = "./modules/alb_controller"
  
  project_name            = "pw"
  env                     = var.env
  cluster_name            = module.eks.cluster_name
  cluster_endpoint        = module.eks.cluster_endpoint
  cluster_ca_certificate  = module.eks.cluster_ca_certificate
  oidc_provider_arn       = module.eks.oidc_provider_arn
  aws_region              = var.aws_region
  alb_controller_role_arn = module.iam.alb_controller_role_arn
  eks_alb_sg_id           = module.security_groups.eks_alb_ingress_sg_id
  map_tagging             = var.map_tagging
  certificate_arn         = var.certificate_arn
  customer_domain         = var.customer_domain
  website_domain          = var.website_domain
  internal_domain         = var.internal_domain
  eks_websocket_alb_sg_id = module.security_groups.eks_alb_ingress_websocket_sg_id
}

module "waf" {
  source = "./modules/waf"

  project_name            = "pw"
  env                     = var.env
  map_tagging             = var.map_tagging
}

module "monitoring" {
  source = "./modules/monitoring"

  project_name             = "pw"
  env                      = var.env
  map_tagging              = var.map_tagging
  email_subscribers        = var.email_subscribers
}