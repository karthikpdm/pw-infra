# Infra Pulse Frontend

This repository contains Terraform code to set up the infrastructure for the frontend of the Pulse application.

## Structure

- `buildspecs/` - Buildspec files for CI/CD
- `environments/` - Environment-specific configurations (dev and prod)
- `modules/` - Reusable Terraform modules for S3 and CloudFront
- `main.tf` - Root Terraform configuration
- `provider.tf` - Provider configuration
- `variables.tf` - Input variables

## Usage

1. Navigate to the desired environment directory (`environments/dev` or `environments/prod`).
2. Run `terraform init` to initialize the environment.
3. Run `terraform plan` to see the execution plan.
4. Run `terraform apply` to apply the changes.
