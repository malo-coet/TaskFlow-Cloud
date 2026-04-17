# HTTP API v2 - Integrations and Routes

# JWT Cognito Authorizer
resource "aws_apigatewayv2_authorizer" "cognito_jwt" {
  api_id          = aws_apigatewayv2_api.taskflow_api.id
  authorizer_type = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name            = "cognito-jwt-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.taskflow_web.id]
    issuer   = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.taskflow.id}"
  }
}

# Lambda Integrations
resource "aws_apigatewayv2_integration" "create_task" {
  api_id             = aws_apigatewayv2_api.taskflow_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  payload_format_version = "2.0"
  integration_uri    = aws_lambda_function.create_task.invoke_arn
}

resource "aws_apigatewayv2_integration" "list_tasks" {
  api_id             = aws_apigatewayv2_api.taskflow_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  payload_format_version = "2.0"
  integration_uri    = aws_lambda_function.list_tasks.invoke_arn
}

resource "aws_apigatewayv2_integration" "update_task" {
  api_id             = aws_apigatewayv2_api.taskflow_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  payload_format_version = "2.0"
  integration_uri    = aws_lambda_function.update_task.invoke_arn
}

resource "aws_apigatewayv2_integration" "delete_task" {
  api_id             = aws_apigatewayv2_api.taskflow_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  payload_format_version = "2.0"
  integration_uri    = aws_lambda_function.delete_task.invoke_arn
}

resource "aws_apigatewayv2_integration" "health_check" {
  api_id             = aws_apigatewayv2_api.taskflow_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  payload_format_version = "2.0"
  integration_uri    = aws_lambda_function.health_check.invoke_arn
}

# Routes with JWT Authorization
resource "aws_apigatewayv2_route" "post_tasks" {
  api_id    = aws_apigatewayv2_api.taskflow_api.id
  route_key = "POST /tasks"
  target    = "integrations/${aws_apigatewayv2_integration.create_task.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

resource "aws_apigatewayv2_route" "get_tasks" {
  api_id    = aws_apigatewayv2_api.taskflow_api.id
  route_key = "GET /tasks"
  target    = "integrations/${aws_apigatewayv2_integration.list_tasks.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

resource "aws_apigatewayv2_route" "put_tasks" {
  api_id    = aws_apigatewayv2_api.taskflow_api.id
  route_key = "PUT /tasks/{taskId}"
  target    = "integrations/${aws_apigatewayv2_integration.update_task.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

resource "aws_apigatewayv2_route" "delete_tasks" {
  api_id    = aws_apigatewayv2_api.taskflow_api.id
  route_key = "DELETE /tasks/{taskId}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_task.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

# Health endpoint - NO authorization
resource "aws_apigatewayv2_route" "get_health" {
  api_id    = aws_apigatewayv2_api.taskflow_api.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.health_check.id}"
}

# Stage
resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.taskflow_api.id
  name        = "dev"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 5000
    throttling_rate_limit  = 2000
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      duration       = "$context.integration.latency"
      error          = "$context.error.message"
      errorType      = "$context.error.messageString"
    })
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/taskflow-api"
  retention_in_days = 7

  tags = {
    Project = "TaskFlow"
    Stage   = "dev"
  }
}

# Lambda Permissions for API Gateway
resource "aws_lambda_permission" "api_gateway_create_task" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_task.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.taskflow_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_list_tasks" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_tasks.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.taskflow_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_update_task" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_task.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.taskflow_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_delete_task" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_task.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.taskflow_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_health" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health_check.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.taskflow_api.execution_arn}/*/*"
}

# Output
output "api_endpoint" {
  value       = aws_apigatewayv2_stage.dev.invoke_url
  description = "API Gateway endpoint"
}

output "authorizer_id" {
  value       = aws_apigatewayv2_authorizer.cognito_jwt.id
  description = "JWT Authorizer ID"
}

