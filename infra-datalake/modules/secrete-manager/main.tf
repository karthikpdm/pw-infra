# Create secret in Secrets Manager
resource "aws_secretsmanager_secret" "amcs-secret" {
  name = "pw-${var.env}-amcs-secret"
  kms_key_id             = var.datalake_kms_key_arn
  recovery_window_in_days = 30

  tags = merge(var.tags, 
  {
    Name = "pw-amcs-secret"
  })
  

}

resource "aws_secretsmanager_secret_version" "amcs-secret" {
  secret_id = aws_secretsmanager_secret.amcs-secret.id
  secret_string = jsonencode({
    server_name     = var.server_name
    database_name   = var.database_name
    user_name       = var.user_name
    password        = var.password
    driver_path     = "s3://${var.raw_bucket_name}/jars/sqljdbc_12.8/enu/jars/mssql-jdbc-12.8.1.jre11.jar"
    driver_class    = var.driver_class
    url             = var.url
  })
}


##############################################################################################

resource "aws_secretsmanager_secret" "dossier-secret" {
  # name = "pw-dossier-secrets"
  name = "pw-${var.env}-dossier-secrets"
  kms_key_id             = var.datalake_kms_key_arn
  recovery_window_in_days = 30

  tags = merge(var.tags, 
  {
    Name = "pw-dossier-secret"
  })
  

}

resource "aws_secretsmanager_secret_version" "dossier-secret" {
  secret_id = aws_secretsmanager_secret.dossier-secret.id
  secret_string = jsonencode({
    client_id     = var.client_id
    client_secret   = var.client_secret
    grant_type       = var.grant_type
    scope       = var.scope
    username     = var.username
    passwords    = var.passwords
    
  })
}