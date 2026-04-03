# 🚀 Deployment Guide - TaskFlow

## Table des matières
- [Infrastructure Setup](#infrastructure-setup)
- [Lambda Deployment](#lambda-deployment)
- [Local Development](#local-development)
- [AWS CLI Commands](#aws-cli-commands)
- [Troubleshooting](#troubleshooting)

---

## Infrastructure Setup

### 1️⃣ Prerequisites
```bash
# Install Terraform
brew install terraform

# Install AWS CLI
brew install awscli

# Configure AWS credentials
aws configure
# Enter: Access Key ID, Secret Access Key, Region (us-east-1), Output format (json)
```

### 2️⃣ Deploy with Terraform
```bash
cd infra/

# Initialize Terraform
terraform init

# Review planned changes
terraform plan -out=tfplan

# Apply infrastructure
terraform apply tfplan

# Output: API Gateway URL, Lambda ARNs, DynamoDB table name
```

---

## Lambda Deployment

### Build Lambda Functions
```bash
cd lambda/functions/

# Install dependencies
npm install

# Compile TypeScript
npm run build

# Create ZIP files for each function
for file in dist/*.js; do
  funcname="${file%.js}"
  zip "${funcname##*/}.zip" -j dist/
done
```

### Deploy Individual Functions
```bash
# Update Lambda function code
aws lambda update-function-code \
  --function-name taskflow-create-task \
  --zip-file fileb://dist/createTask.zip

aws lambda update-function-code \
  --function-name taskflow-list-tasks \
  --zip-file fileb://dist/listTasks.zip

aws lambda update-function-code \
  --function-name taskflow-update-task \
  --zip-file fileb://dist/updateTask.zip

aws lambda update-function-code \
  --function-name taskflow-delete-task \
  --zip-file fileb://dist/deleteTask.zip
```

---

## Local Development

### Setup Frontend
```bash
cd taskflow-frontend/

# Install dependencies
npm install

# Start dev server
npm run dev
# Available at: http://localhost:5173
```

### Setup Lambda Locally (SAM)
```bash
# Install AWS SAM CLI
brew install aws-sam-cli

# Run local lambda
sam local start-api
# API available at: http://localhost:3000
```

---

## AWS CLI Commands

### DynamoDB Operations
```bash
# List tables
aws dynamodb list-tables

# Describe Tasks table
aws dynamodb describe-table --table-name TaskFlow-Tasks

# Scan tasks (limit 10)
aws dynamodb scan --table-name TaskFlow-Tasks --limit 10

# Query tasks by user
aws dynamodb query \
  --table-name TaskFlow-Tasks \
  --key-condition-expression "PK = :pk" \
  --expression-attribute-values '{":pk": {"S": "USER#user123"}}'
```

### Lambda Operations
```bash
# List Lambda functions
aws lambda list-functions

# Get function configuration
aws lambda get-function-configuration --function-name taskflow-create-task

# View Lambda logs
aws logs tail /aws/lambda/taskflow-create-task --follow

# Invoke Lambda function
aws lambda invoke \
  --function-name taskflow-list-tasks \
  --payload '{"userId": "user123"}' \
  response.json
```

### API Gateway Operations
```bash
# List APIs
aws apigatewayv2 get-apis

# Get API details
aws apigatewayv2 get-api --api-id <API_ID>

# Test API endpoint
curl https://<API_ID>.execute-api.us-east-1.amazonaws.com/tasks
```

### IAM Verification
```bash
# List IAM roles
aws iam list-roles

# Get role details
aws iam get-role --role-name TaskFlowLambdaRole

# View role policies
aws iam list-attached-role-policies --role-name TaskFlowLambdaRole
```

---

## Environment Variables

### Backend (.env - Lambda)
```
DYNAMODB_TABLE_NAME=TaskFlow-Tasks
AWS_REGION=us-east-1
```

### Frontend (.env.local - React)
```
VITE_API_URL=https://<API_ID>.execute-api.us-east-1.amazonaws.com
```

---

## Troubleshooting

### Lambda: "Cannot find module '@aws-sdk/client-dynamodb'"
```bash
# Solution: Reinstall dependencies
cd lambda/functions/
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Terraform: "Saved plan is stale"
```bash
# Solution: Delete old plan and create new one
rm tfplan
terraform plan -out=tfplan
terraform apply tfplan
```

### DynamoDB: Access Denied
```bash
# Solution: Verify IAM policy on Lambda role
aws iam get-role-policy \
  --role-name TaskFlowLambdaRole \
  --policy-name TaskFlowDynamoDBPolicy
```

### CORS Issues
```bash
# Check CORS configuration in API Gateway
aws apigatewayv2 get-api-cors \
  --api-id <API_ID>
```

---

## Monitoring & Logs

### View Lambda Logs
```bash
aws logs tail /aws/lambda/taskflow-create-task --follow --since 1h
```

### View API Gateway Access Logs
```bash
aws logs tail /aws/apigateway/taskflow-api --follow --since 1h
```

### CloudWatch Metrics
```bash
# Lambda Invocations
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=taskflow-create-task \
  --start-time 2026-04-01T00:00:00Z \
  --end-time 2026-04-03T00:00:00Z \
  --period 3600 \
  --statistics Sum
```

---

**Last Updated:** 2026-04-03  
**Version:** v0.2.0

