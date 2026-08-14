# Upload recipe file to S3
resource "aws_s3_object" "recipe" {
  bucket = var.s3_bucket_name
  key    = "recipes/${basename(var.recipe_file)}"
  source = var.recipe_file

  tags = var.tags
}

# Upload artifact files to S3
resource "aws_s3_object" "artifacts" {
  for_each = { for idx, file in var.artifacts : idx => file }
  bucket   = var.s3_bucket_name
  key      = "artifacts/${basename(each.value)}"
  source   = each.value

  tags = var.tags
}

# Check if the component exists
data "external" "component_check" {
  program = ["bash", "-c", <<EOT
ROLE_SESSION=$(aws sts assume-role --role-arn ${var.assume_role_arn} --role-session-name terraform-session)

export AWS_ACCESS_KEY_ID=$(echo $ROLE_SESSION | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $ROLE_SESSION | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $ROLE_SESSION | jq -r .Credentials.SessionToken)

# Read the component version from the recipe file
COMPONENT_VERSION=$(jq -r '.ComponentVersion // .componentVersion // .version' ${var.recipe_file})
if [[ -z "$COMPONENT_VERSION" || "$COMPONENT_VERSION" == "null" ]]; then
  echo '{"component_exists": "false", "component_arn": "", "component_version": ""}'
  exit 0
fi

# Fetch the component ARN
COMPONENT_ARN=$(aws greengrassv2 list-components \
  --region ${var.region} \
  --query "components[?name=='com.example.telemetryComponent'] | [0].arn" \
  --output text)

if [[ "$COMPONENT_ARN" == "None" || -z "$COMPONENT_ARN" ]]; then
  echo '{"component_exists": "false", "component_arn": "", "component_version": ""}'
else
  # Check if the specified version exists
  EXISTING_VERSION=$(aws greengrassv2 list-component-versions \
    --region ${var.region} \
    --arn $COMPONENT_ARN \
    --query "componentVersions[?ComponentVersion=='$COMPONENT_VERSION'] | [0].ComponentVersion" \
    --output text)

  if [[ "$EXISTING_VERSION" == "$COMPONENT_VERSION" ]]; then
    echo '{"component_exists": "true", "component_arn": "'$COMPONENT_ARN'", "component_version": "'$EXISTING_VERSION'"}'
  else
    echo '{"component_exists": "false", "component_arn": "'$COMPONENT_ARN'", "component_version": ""}'
  fi
fi
EOT
  ]
}

resource "local_file" "last_deployed_component" {
  content = jsonencode({
    component_version = data.external.component_check.result.component_version
  })
  filename = "last_deployed_component.json"
}


resource "null_resource" "greengrass_component" {
  provisioner "local-exec" {
    command = <<EOT
if [[ "${data.external.component_check.result.component_exists}" == "false" ]]; then
  ROLE_SESSION=$(aws sts assume-role --role-arn ${var.assume_role_arn} --role-session-name terraform-session)

  export AWS_ACCESS_KEY_ID=$(echo $ROLE_SESSION | jq -r .Credentials.AccessKeyId)
  export AWS_SECRET_ACCESS_KEY=$(echo $ROLE_SESSION | jq -r .Credentials.SecretAccessKey)
  export AWS_SESSION_TOKEN=$(echo $ROLE_SESSION | jq -r .Credentials.SessionToken)

  echo "Creating new component version..."
  aws greengrassv2 create-component-version \
    --region ${var.region} \
    --inline-recipe file://${var.recipe_file} \
    --tags '${jsonencode(var.tags)}'
  echo "${jsonencode({component_version = jsondecode(file(var.recipe_file)).ComponentVersion})}" > last_deployed_component.json
else
  echo "Component version ${data.external.component_check.result.component_version} already exists. Skipping creation."
fi
EOT
  }

  triggers = {
    recipe_version    = jsondecode(file(var.recipe_file))["ComponentVersion"]
    persisted_version = jsondecode(local_file.last_deployed_component.content)["component_version"]
  }
}