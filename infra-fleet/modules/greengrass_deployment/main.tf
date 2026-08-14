resource "null_resource" "deploy_greengrass_deployment" {
  triggers = {
    target_arn = var.target_arn
  }

  provisioner "local-exec" {
    command = <<EOT
      # Assume role for cross-account deployment
      ASSUME_ROLE=$(aws sts assume-role --role-arn "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role" --role-session-name "greengrass_deployment_session")
      export AWS_ACCESS_KEY_ID=$(echo $ASSUME_ROLE | jq -r .Credentials.AccessKeyId)
      export AWS_SECRET_ACCESS_KEY=$(echo $ASSUME_ROLE | jq -r .Credentials.SecretAccessKey)
      export AWS_SESSION_TOKEN=$(echo $ASSUME_ROLE | jq -r .Credentials.SessionToken)

      # Deployment of Greengrass component
      echo "Deploying Greengrass component to target ARN..."

      # aws greengrassv2 create-deployment \
      #   --target-arn ${var.target_arn} \
      #   --components '{ "MyComponent": { "componentVersion": "1.0.0" } }' \
      #   --deployment-policies '{"failureHandlingPolicy": "ROLLBACK"}' \
      #   --region "${var.region}" || { echo "Failed to create Greengrass deployment"; exit 1; }

      echo "Deployment command would go here (currently commented out)."
    EOT
  }
}
