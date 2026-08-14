output "amcs_secret_name" {
  value = aws_secretsmanager_secret.amcs-secret.name
}

output "amcs_secret_arn" {
  value = aws_secretsmanager_secret.amcs-secret.arn
}

output "dossier_secret_name" {
  value = aws_secretsmanager_secret.dossier-secret.name
}

output "dossier_secret_arn" {
  value = aws_secretsmanager_secret.dossier-secret.arn
}