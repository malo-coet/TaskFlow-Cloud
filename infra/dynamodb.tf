# DynamoDB Table for TaskFlow Cloud
resource "aws_dynamodb_table" "tasks" {
  name           = "TaskFlow-Tasks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"
  range_key      = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  attribute {
    name = "dueDate"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI-Status"
    hash_key        = "userId"
    range_key       = "status"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "GSI-DueDate"
    hash_key        = "userId"
    range_key       = "dueDate"
    projection_type = "ALL"
  }

  tags = {
    Project     = "TaskFlow-Cloud"
    Environment = "production"
  }
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tasks.name
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.tasks.arn
}

