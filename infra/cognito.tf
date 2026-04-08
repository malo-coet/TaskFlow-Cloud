resource "aws_cognito_user_pool" "taskflow" {
  name = "taskflow-user-pool"

  # Password policy
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  # Auto-verified email (for testing - remove in production)
  auto_verified_attributes = ["email"]

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Schema
  schema {
    name              = "email"
    attribute_data_type = "String"
    required          = true
    mutable           = true
  }

  tags = {
    Project = "TaskFlow"
    Stage   = "dev"
  }
}

# User Pool Client for Frontend
resource "aws_cognito_user_pool_client" "taskflow_web" {
  name            = "taskflow-web-client"
  user_pool_id    = aws_cognito_user_pool.taskflow.id
  generate_secret = false  # No secret for public web apps

  # OAuth 2.0 flows
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  # Token expiry
  access_token_validity  = 1   # hours
  refresh_token_validity = 30  # days
  id_token_validity      = 1   # hours

  token_validity_units {
    access_token  = "hours"
    refresh_token = "days"
    id_token      = "hours"
  }

  # Callback URLs (update with your frontend URL)
  callback_urls = [
    "http://localhost:5173/auth/callback",
    "http://localhost:5173"
  ]

  logout_urls = [
    "http://localhost:5173/auth/logout",
    "http://localhost:5173"
  ]

  allowed_oauth_flows  = ["code"]
  allowed_oauth_scopes = ["phone", "email", "openid", "profile"]

  # For testing: skip URL validation
  # allowed_oauth_flows_user_pool_client = true
}

# User Pool Domain (for hosted UI)
resource "aws_cognito_user_pool_domain" "taskflow" {
  domain       = "taskflow-${data.aws_caller_identity.current.account_id}"
  user_pool_id = aws_cognito_user_pool.taskflow.id
}

# Output for frontend configuration
output "cognito_user_pool_id" {
  value       = aws_cognito_user_pool.taskflow.id
  description = "Cognito User Pool ID"
}

output "cognito_user_pool_arn" {
  value       = aws_cognito_user_pool.taskflow.arn
  description = "Cognito User Pool ARN"
}

output "cognito_client_id" {
  value       = aws_cognito_user_pool_client.taskflow_web.id
  description = "Cognito Client ID (for frontend)"
  sensitive   = false
}

output "cognito_domain" {
  value       = aws_cognito_user_pool_domain.taskflow.domain_name
  description = "Cognito Domain for Hosted UI"
}

output "cognito_region" {
  value       = var.aws_region
  description = "AWS Region for Cognito"
}

