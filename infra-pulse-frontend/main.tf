data "aws_caller_identity" "current" {}

module "s3" {

  source      = "./modules/s3"
  bucket_name = var.bucket_name
  env         = var.env  # Use `env` instead of `environment`
  # cloudfront_oai_iam_arn = module.cloudfront.cloudfront_oai_iam_arn
  # cloudfront_distribution_arn = module.cloudfront.cloudfront_distribution_arn
  # cloudfront_distribution_arn = module.cloudfront.distribution_arn
  cloudfront_full_arn = module.cloudfront.cloudfront_full_arn
  #aws_region =   var.aws_region


  # cloudfront_oai_iam_arn = module.cloudfront.distribution_arn
  tags = var.tags
  

}

module "cloudfront" {

  source        = "./modules/cloudfront"
  s3_bucket_id  = module.s3.bucket_id
  s3_bucket_arn = module.s3.bucket_arn
  s3_bucket_domain_name = module.s3.bucket_domain_name  # Pass domain name from s3 module
  env           = var.env  # Pass `env` to the cloudfront module
  acm_certificate_arn = var.acm_certificate_arn
  cloudfront_alias       = var.cloudfront_alias
  tags = var.tags
  bucket_name = var.bucket_name
  kms_key_id    = module.s3.kms_key_arn


}

module "iam" {


  source      = "./modules/iam"
  bucket_name = var.bucket_name
  account_id  = data.aws_caller_identity.current.account_id
  env           = var.env  # Pass `env` to the cloudfront module
  tags = var.tags

  

}
