# 🔧 TaskFlow Lambda Functions

Node.js 20.x Lambda functions for TaskFlow CRUD operations, built with TypeScript and AWS SDK v3.

## 📁 Structure

```
lambda/
├── functions/              # CRUD Lambda handlers
│   ├── createTask.ts      # POST /tasks
│   ├── listTasks.ts       # GET /tasks
│   ├── updateTask.ts      # PUT /tasks/{taskId}
│   ├── deleteTask.ts      # DELETE /tasks/{taskId}
│   ├── package.json
│   ├── tsconfig.json
│   └── dist/              # Compiled output (gitignored)
│
├── shared/
│   └── taskService.ts     # DynamoDB operations (shared)
│
└── health-check/          # Basic health check (existing)
    ├── handler.js
    └── package.json
```

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd lambda/functions
npm install
```

### 2. Build TypeScript
```bash
npm run build
```

### 3. Package for Lambda
```bash
cd dist
for file in *.js; do
  funcname="${file%.js}"
  zip "$funcname.zip" "$funcname.js"
done
cd ..
```

### 4. Deploy via Terraform
```bash
cd ../../infra
terraform plan
terraform apply
```

## 📝 Available Scripts

```bash
npm run build       # Compile TypeScript to dist/
npm run test        # Run tests with Vitest
npm run test:watch  # Watch mode for development
```

## 🔐 Environment Variables

Each Lambda function reads from environment variables (set by Terraform):

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DYNAMODB_TABLE_NAME` | Yes | `TaskFlow-Tasks` | DynamoDB table name |
| `AWS_REGION` | Auto | `eu-west-3` | AWS region |

## 📚 API Endpoints

### POST /tasks — Create Task
```bash
curl -X POST https://api-endpoint/tasks \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Learn Terraform",
    "description": "Complete Terraform tutorial",
    "dueDate": "2025-05-01",
    "tags": ["learning", "aws"]
  }'
```

### GET /tasks — List Tasks
```bash
curl -X GET https://api-endpoint/tasks \
  -H "Authorization: Bearer TOKEN"
```

### PUT /tasks/{taskId} — Update Task
```bash
curl -X PUT https://api-endpoint/tasks/018f1a2b-3c4d-7e8f \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "IN_PROGRESS",
    "dueDate": "2025-04-15"
  }'
```

### DELETE /tasks/{taskId} — Delete Task
```bash
curl -X DELETE https://api-endpoint/tasks/018f1a2b-3c4d-7e8f \
  -H "Authorization: Bearer TOKEN"
```

## 🧪 Testing

### Run Tests
```bash
npm run test
```

### Test Specific Handler
```bash
npm run test -- createTask.test.ts
```

### Watch Mode (Development)
```bash
npm run test:watch
```

## 🔧 TypeScript Configuration

- **Target**: ES2022
- **Module**: ESNext
- **Strict mode**: Enabled
- **Source maps**: Enabled for debugging

## 🎓 Design Patterns

### Shared Service Layer
All CRUD operations are abstracted in `taskService.ts`:
- Handles DynamoDB marshalling/unmarshalling
- Type-safe operations with TypeScript interfaces
- Error handling and validation

### Handler Pattern
Each Lambda handler:
1. Extracts userId from JWT claims
2. Validates request input
3. Calls service layer
4. Returns formatted response

Example:
```typescript
export const handler = async (event: APIGatewayEvent) => {
  const userId = event.requestContext.authorizer.claims.sub;
  // ... validation
  const result = await taskService.createTask(input);
  return { statusCode: 201, body: JSON.stringify(result) };
};
```

## 📊 Performance

- **Cold start**: ~200ms (Node.js 20, no layers)
- **Warm invocation**: ~10-20ms
- **Memory**: 256MB (configurable via Terraform)
- **Timeout**: 30s (configurable)

## 🔐 Security

- ✅ JWT validation via Cognito Authorizer on API Gateway
- ✅ DynamoDB least-privilege IAM policy
- ✅ Input validation on all endpoints
- ✅ Error responses sanitized (no sensitive data)

## 🐛 Troubleshooting

### "DYNAMODB_TABLE_NAME not set"
Check Terraform outputs and verify environment variables are correctly injected.

### "Unauthorized" error
- Verify JWT token is in `Authorization: Bearer <token>` header
- Check token expiration: `jwt.io`
- Verify Cognito Authorizer is attached to route

### Lambda execution timeout
- Increase timeout in `infra/lambda.tf` (default: 30s)
- Check DynamoDB on-demand capacity (should be unlimited)

## 📖 Related Documentation

- **[docs/IMPLEMENTATION_GUIDE_J8_J9.md](../docs/IMPLEMENTATION_GUIDE_J8_J9.md)** — Full deployment guide
- **[docs/dynamodb-schema.md](../docs/dynamodb-schema.md)** — DynamoDB design
- **[docs/COGNITO_JWT_SETUP_J10_J11.md](../docs/COGNITO_JWT_SETUP_J10_J11.md)** — Auth setup

