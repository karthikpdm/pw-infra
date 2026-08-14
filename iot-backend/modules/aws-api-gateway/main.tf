#-----------------Remote commands--------------------------------------------
data "aws_lambda_function" "iot_shadow" {
  function_name = "pw-iotShadow"
}

resource "aws_api_gateway_rest_api" "shadow_api" {
  name = "pw-shadow-api"
  tags = var.tags
}

resource "aws_api_gateway_resource" "shadow_api" {
  parent_id   = aws_api_gateway_rest_api.shadow_api.root_resource_id
  path_part   = "shadow"
  rest_api_id = aws_api_gateway_rest_api.shadow_api.id
}

#API methods - GET
resource "aws_api_gateway_method" "shadow_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.shadow_api.id
  rest_api_id   = aws_api_gateway_rest_api.shadow_api.id
}

resource "aws_api_gateway_integration" "integration_get" {
  rest_api_id             = aws_api_gateway_rest_api.shadow_api.id
  resource_id             = aws_api_gateway_resource.shadow_api.id
  http_method             = aws_api_gateway_method.shadow_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.iot_shadow.invoke_arn
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.shadow_api.id
  resource_id = aws_api_gateway_resource.shadow_api.id
  http_method = aws_api_gateway_method.shadow_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = aws_api_gateway_model.empty.name
  }

  response_parameters = {
    "method.response.header.Content-Type"       = false
    "method.response.header.X-My-Demo-Header"   = false
  }

  depends_on = [aws_api_gateway_model.empty]
}

#Api methods - POST
resource "aws_api_gateway_method" "shadow_post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.shadow_api.id
  rest_api_id   = aws_api_gateway_rest_api.shadow_api.id
}

resource "aws_api_gateway_integration" "integration_post" {
  rest_api_id             = aws_api_gateway_rest_api.shadow_api.id
  resource_id             = aws_api_gateway_resource.shadow_api.id
  http_method             = aws_api_gateway_method.shadow_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.iot_shadow.invoke_arn
}

resource "aws_api_gateway_method_response" "response_post" {
  rest_api_id = aws_api_gateway_rest_api.shadow_api.id
  resource_id = aws_api_gateway_resource.shadow_api.id
  http_method = aws_api_gateway_method.shadow_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = aws_api_gateway_model.empty.name
  }

  response_parameters = {
    "method.response.header.Content-Type"       = false
    "method.response.header.X-My-Demo-Header"   = false
  }

  depends_on = [aws_api_gateway_model.empty]
}

resource "aws_lambda_permission" "iot_shadow_lambda_GET" {
  statement_id  = "AllowExecutionFromAPIGatewayGET"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.iot_shadow.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.shadow_api.execution_arn}/*/GET"
}

resource "aws_lambda_permission" "iot_shadow_lambda_POST" {
  statement_id  = "AllowExecutionFromAPIGatewayPOST"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.iot_shadow.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.shadow_api.execution_arn}/*/POST"
}

#Api methods - OPTIONS
resource "aws_api_gateway_method" "shadow_options" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.shadow_api.id
  rest_api_id   = aws_api_gateway_rest_api.shadow_api.id
}

resource "aws_api_gateway_integration" "integration_options" {
  http_method = aws_api_gateway_method.shadow_options.http_method
  resource_id = aws_api_gateway_resource.shadow_api.id
  rest_api_id = aws_api_gateway_rest_api.shadow_api.id
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "response_options" {
  rest_api_id = aws_api_gateway_rest_api.shadow_api.id
  resource_id = aws_api_gateway_resource.shadow_api.id
  http_method = aws_api_gateway_method.shadow_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = aws_api_gateway_model.empty.name
  }

  response_parameters = {
    "method.response.header.Content-Type"       = false
    "method.response.header.X-My-Demo-Header"   = false
  }

  depends_on = [aws_api_gateway_model.empty]
}

resource "aws_api_gateway_model" "empty" {
  rest_api_id  = aws_api_gateway_rest_api.shadow_api.id
  name         = "Empty"
  description  = "a JSON schema"
  content_type = "application/json"

  schema = jsonencode({
    type = "object"
  })
}

# Define API Gateway Deployment
resource "aws_api_gateway_deployment" "shadow_deployment" {
  depends_on = [
    aws_api_gateway_method.shadow_get,
    aws_api_gateway_method.shadow_post,
    aws_api_gateway_method.shadow_options
  ]
  rest_api_id = aws_api_gateway_rest_api.shadow_api.id
  stage_name  = var.env
  description = "Deployment for stage ${var.env}"
}

# Define API Gateway Stage
resource "aws_api_gateway_stage" "shadow_stage" {
  deployment_id = aws_api_gateway_deployment.shadow_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.shadow_api.id
  stage_name    = var.env 
  description   = "Stage for ${var.env}"

  tags = var.tags
}
