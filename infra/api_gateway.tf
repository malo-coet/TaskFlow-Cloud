# API Gateway REST API for TaskFlow CRUD endpoints

# REST API
resource "aws_api_gateway_rest_api" "taskflow_api" {
  name        = "taskflow-api"
  description = "TaskFlow CRUD API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Root resource
resource "aws_api_gateway_resource" "tasks" {
  rest_api_id = aws_api_gateway_rest_api.taskflow_api.id
  parent_id   = aws_api_gateway_rest_api.taskflow_api.root_resource_id
  path_part   = "tasks"
}

# Task ID resource
resource "aws_api_gateway_resource" "task_id" {
  rest_api_id = aws_api_gateway_rest_api.taskflow_api.id
  parent_id   = aws_api_gateway_resource.tasks.id
  path_part   = "{taskId}"
}

# POST /tasks → createTask
resource "aws_api_gateway_method" "create_task" {
  rest_api_id      = aws_api_gateway_rest_api.taskflow_api.id
  resource_id      = aws_api_gateway_resource.tasks.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "create_task" {
  rest_api_id      = aws_api_gateway_rest_api.taskflow_api.id
  resource_id      = aws_api_gateway_resource.tasks.id
  http_method      = aws_api_gateway_method.create_task.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.create_task.invoke_arn
}

# GET /tasks → listTasks
resource "aws_api_gateway_method" "list_tasks" {
  rest_api_id      = aws_api_gateway_rest_api.taskflow_api.id
  resource_id      = aws_api_gateway_resource.tasks.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "list_tasks" {
  rest_api_id      = aws_api_gateway_rest_api.taskflow_api.id
  resource_id      = aws_api_gateway_resource.tasks.id
  http_method      = aws_api_gateway_method.list_tasks.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.list_tasks.invoke_arn
}

# PUT /tasks/{taskId} → updateTask
resource "aws_api_gateway_method" "update_task" {
  rest_api_id      = aws_api_gateway_rest_api.taskflow_api.id
  resource_id      = aws_api_gateway_resource.task_id.id
  http_method      = "PUT"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "update_task" {
  rest_api_id      = aws_api_gateway_rest_api.taskflow_api.id
  resource_id      = aws_api_gateway_resource.task_id.id
  http_method      = aws_api_gateway_method.update_task.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.update_task.invoke_arn
}

# DELETE /tasks/{taskId} → deleteTask
resource "aws_api_gateway_method" "delete_task" {
  rest_api_id      = aws_api_gateway_rest_api.taskflow_api.id
  resource_id      = aws_api_gateway_resource.task_id.id
  http_method      = "DELETE"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "delete_task" {
  rest_api_id      = aws_api_gateway_rest_api.taskflow_api.id
  resource_id      = aws_api_gateway_resource.task_id.id
  http_method      = aws_api_gateway_method.delete_task.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.delete_task.invoke_arn
}

# Deploy
resource "aws_api_gateway_deployment" "taskflow" {
  rest_api_id = aws_api_gateway_rest_api.taskflow_api.id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_integration.create_task,
    aws_api_gateway_integration.list_tasks,
    aws_api_gateway_integration.update_task,
    aws_api_gateway_integration.delete_task,
  ]
}

# Lambda permissions
resource "aws_lambda_permission" "allow_api_gateway_create" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_task.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.taskflow_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_api_gateway_list" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_tasks.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.taskflow_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_api_gateway_update" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_task.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.taskflow_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_api_gateway_delete" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_task.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.taskflow_api.execution_arn}/*/*"
}

# Outputs
output "api_endpoint" {
  value       = "https://${aws_api_gateway_rest_api.taskflow_api.id}.execute-api.eu-west-3.amazonaws.com/prod"
  description = "API Gateway endpoint URL"
}

output "api_id" {
  value       = aws_api_gateway_rest_api.taskflow_api.id
  description = "API Gateway API ID"
}
