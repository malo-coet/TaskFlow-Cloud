# API Gateway HTTP API v2 for TaskFlow CRUD with JWT Authorization

# HTTP API
resource "aws_apigatewayv2_api" "taskflow_api" {
  name          = "taskflow-api"
  protocol_type = "HTTP"
  description   = "TaskFlow CRUD API with JWT Cognito Auth"

  cors_configuration {
    allow_credentials = false
    allow_headers     = ["*"]
    allow_methods     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_origins     = ["*"]  # Restrict in production
    expose_headers    = ["*"]
    max_age           = 300
  }

  tags = {
    Project = "TaskFlow"
    Stage   = "dev"
  }
}

