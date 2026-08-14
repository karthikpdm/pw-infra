# Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, uat, prod)"
  type        = string
}

variable "codebuild_infra_role_arn" {
  description = "ARN of the IAM role for CodeBuild"
  type        = string
}

variable "codepipeline_infra_role_arn" {
  description = "ARN of the IAM role for CodePipeline"
  type        = string
}



# variable "target_role_arn" {
#   description = "ARN of the role in the target account with EKS permissions"
#   type        = string
# }

variable "artifact_bucket_name" {
  description = "Name of the S3 bucket for storing pipeline artifacts"
  type        = string
}

variable "build-logs_bucket_name" {
  description = "Name of the S3 bucket for storing pipeline artifacts"
  type        = string
}

variable "bitbucket_connection_arn" {
  description = "ARN of the CodeStar connection to Bitbucket"
  type        = string
}

variable "bitbucket_account" {
  description = "Bitbucket account name"
  type        = string
}

variable "bitbucket_repo_name" {
  description = "Name of the Bitbucket repository"
  type        = string
}

variable "branch" {
  description = "Branch name to trigger the pipeline"
  type        = string
}

variable "deployment_role_arn" {
  description = "Branch name to trigger the pipeline"
  type        = string
}


variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}





# version: 0.2

# env:
#   variables:
#     AWS_DEFAULT_REGION: ${EKS_CLUSTER_REGION}
#   exported-variables:
#     - AWS_DEFAULT_REGION

# phases:
#   install:
#     runtime-versions:
#       python: 3.8
#     commands:
#       - echo "Installing kubectl"
#       - curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
#       - chmod +x ./kubectl
#       - mv ./kubectl /usr/local/bin/kubectl
#       - echo "Installing AWS CLI"
#       - pip3 install awscli --upgrade
#       - echo "Installing other dependencies"
#       - yum install -y jq gettext

#   pre_build:
#     commands:
#       - echo "Deploying to ${ENVIRONMENT} environment"
#       - echo "EKS Cluster Name: ${EKS_CLUSTER_NAME}"
#       - echo "Logging in to Amazon EKS"
#       - aws eks get-token --cluster-name ${EKS_CLUSTER_NAME} | kubectl apply -f -
#       - echo "Assuming deployment role"
#       - CREDENTIALS=$(aws sts assume-role --role-arn ${DEPLOYMENT_ROLE_ARN} --role-session-name EKSDeploymentSession --duration-seconds 900)
#       - export AWS_ACCESS_KEY_ID=$(echo ${CREDENTIALS} | jq -r '.Credentials.AccessKeyId')
#       - export AWS_SECRET_ACCESS_KEY=$(echo ${CREDENTIALS} | jq -r '.Credentials.SecretAccessKey')
#       - export AWS_SESSION_TOKEN=$(echo ${CREDENTIALS} | jq -r '.Credentials.SessionToken')
#       - echo "Configuring kubectl"
#       - aws eks --region ${EKS_CLUSTER_REGION} update-kubeconfig --name ${EKS_CLUSTER_NAME}

#   build:
#     commands:
#       - echo "Deploying to ${EKS_CLUSTER_NAME} in ${EKS_CLUSTER_REGION}"
#       - kubectl create namespace ${ENVIRONMENT} --dry-run=client -o yaml | kubectl apply -f -
#       - |
#         for file in k8s/*.yaml; do
#           envsubst < $file | kubectl apply -n ${ENVIRONMENT} -f -
#         done
#       - echo "Deployment completed successfully"

#   post_build:
#     commands:
#       - echo "Checking deployment status"
#       - kubectl get pods -n ${ENVIRONMENT}
#       - echo "Deployment status check completed"

# artifacts:
#   files:
#     - '**/*'