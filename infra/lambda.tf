# Lambda functions for TaskFlow CRUD operations
# Each function is triggered through API Gateway HTTP API

# IAM Role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "taskflow-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach basic Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Policy for DynamoDB access
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "taskflow-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.tasks.arn,
          "${aws_dynamodb_table.tasks.arn}/index/*"
        ]
      }
    ]
  })
}

# Reference to the DynamoDB table created in dynamodb.tf
# (Comment: The table is created by aws_dynamodb_table.tasks, no data source needed)

# Lambda function - createTask
resource "aws_lambda_function" "create_task" {
  filename      = "../lambda/functions/dist/createTask.zip"
  function_name = "taskflow-create-task"
  role          = aws_iam_role.lambda_role.arn
  handler       = "createTask.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.tasks.name
    }
  }

  source_code_hash = filebase64sha256("../lambda/functions/dist/createTask.zip")

  depends_on = [aws_iam_role_policy.lambda_dynamodb_policy]
}

# Lambda function - listTasks
resource "aws_lambda_function" "list_tasks" {
  filename      = "../lambda/functions/dist/listTasks.zip"
  function_name = "taskflow-list-tasks"
  role          = aws_iam_role.lambda_role.arn
  handler       = "listTasks.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.tasks.name
    }
  }

  source_code_hash = filebase64sha256("../lambda/functions/dist/listTasks.zip")

  depends_on = [aws_iam_role_policy.lambda_dynamodb_policy]
}

# Lambda function - updateTask
resource "aws_lambda_function" "update_task" {
  filename      = "../lambda/functions/dist/updateTask.zip"
  function_name = "taskflow-update-task"
  role          = aws_iam_role.lambda_role.arn
  handler       = "updateTask.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.tasks.name
    }
  }

  source_code_hash = filebase64sha256("../lambda/functions/dist/updateTask.zip")

  depends_on = [aws_iam_role_policy.lambda_dynamodb_policy]
}

# Lambda function - deleteTask
resource "aws_lambda_function" "delete_task" {
  filename      = "../lambda/functions/dist/deleteTask.zip"
  function_name = "taskflow-delete-task"
  role          = aws_iam_role.lambda_role.arn
  handler       = "deleteTask.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.tasks.name
    }
  }

  source_code_hash = filebase64sha256("../lambda/functions/dist/deleteTask.zip")

  depends_on = [aws_iam_role_policy.lambda_dynamodb_policy]
}

# Outputs
output "create_task_function_arn" {
  value = aws_lambda_function.create_task.arn
}

output "list_tasks_function_arn" {
  value = aws_lambda_function.list_tasks.arn
}

output "update_task_function_arn" {
  value = aws_lambda_function.update_task.arn
}

output "delete_task_function_arn" {
  value = aws_lambda_function.delete_task.arn
}

