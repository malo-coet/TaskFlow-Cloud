# 🧪 Testing Guide - TaskFlow J10-J11

> Note: ce guide detaille reste disponible, mais la version canonique et concise est `docs/runbook/COMMANDS.md`.

## Phase actuelle: Cognito JWT Setup ✅

Après le déploiement, teste avec ces commandes.

---

## 1️⃣ Manual AWS Setup (avant Terraform)

### Create Cognito User Pool manually (optional for testing)
```bash
# Create a test user in Cognito
aws cognito-idp admin-create-user \
  --user-pool-id <USER_POOL_ID> \
  --username testuser@example.com \
  --message-action SUPPRESS \
  --temporary-password TempPassword123!

# Set permanent password
aws cognito-idp admin-set-user-password \
  --user-pool-id <USER_POOL_ID> \
  --username testuser@example.com \
  --password TestPassword123! \
  --permanent
```

---

## 2️⃣ Deploy with Terraform

```bash
cd infra/

# Initialize
terraform init

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Get outputs
terraform output
```

**Save these outputs:**
- `api_endpoint` → API URL
- `cognito_user_pool_id` → For user management
- `cognito_client_id` → For frontend
- `cognito_domain` → For hosted UI

---

## 3️⃣ Get JWT Token

### Option A: Use Cognito Hosted UI (easiest)
```bash
# 1. Go to URL (replace values):
https://taskflow-<ACCOUNT_ID>.auth.<REGION>.amazoncognito.com/login?client_id=<CLIENT_ID>&response_type=code&scope=openid+email+profile&redirect_uri=http://localhost:5173

# 2. Login with test user
# 3. Browser redirects to: http://localhost:5173?code=...

# 4. Exchange code for tokens (requires backend)
# Or use AWS CLI:
aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id <CLIENT_ID> \
  --auth-parameters USERNAME=testuser@example.com,PASSWORD=TestPassword123!
```

### Option B: Use AWS CLI directly
```bash
# Get JWT token
aws cognito-idp admin-initiate-auth \
  --user-pool-id <USER_POOL_ID> \
  --client-id <CLIENT_ID> \
  --auth-flow ADMIN_USER_PASSWORD_AUTH \
  --auth-parameters USERNAME=testuser@example.com,PASSWORD=TestPassword123!

# Save: AuthenticationResult.IdToken (this is your JWT)
```

---

## 4️⃣ Test Endpoints

### Health Check (no auth needed)
```bash
curl -X GET https://<API_ID>.execute-api.<REGION>.amazonaws.com/health
```

**Expected:**
```json
{ "status": "ok" }
```

---

### Create Task (with JWT)
```bash
# Get JWT first (see step 3)
JWT="<YOUR_JWT_TOKEN>"

curl -X POST https://<API_ID>.execute-api.<REGION>.amazonaws.com/tasks \
  -H "Authorization: Bearer $JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Learn Terraform",
    "description": "Complete Terraform setup",
    "dueDate": "2026-04-10"
  }'
```

**Expected:**
```json
{
  "taskId": "uuid-here",
  "userId": "cognito-sub",
  "title": "Learn Terraform",
  "status": "TODO",
  "createdAt": "2026-04-03T...",
  "updatedAt": "2026-04-03T..."
}
```

---

### List Tasks (with JWT)
```bash
curl -X GET https://<API_ID>.execute-api.<REGION>.amazonaws.com/tasks \
  -H "Authorization: Bearer $JWT"
```

**Expected:**
```json
[
  {
    "taskId": "uuid",
    "userId": "cognito-sub",
    "title": "Learn Terraform",
    ...
  }
]
```

---

### Update Task (with JWT)
```bash
curl -X PUT https://<API_ID>.execute-api.<REGION>.amazonaws.com/tasks/uuid \
  -H "Authorization: Bearer $JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "IN_PROGRESS",
    "title": "Learn Terraform Advanced"
  }'
```

---

### Delete Task (with JWT)
```bash
curl -X DELETE https://<API_ID>.execute-api.<REGION>.amazonaws.com/tasks/uuid \
  -H "Authorization: Bearer $JWT"
```

---

## 5️⃣ Test Unauthorized Access

### Without JWT (should fail)
```bash
curl -X GET https://<API_ID>.execute-api.<REGION>.amazonaws.com/tasks
```

**Expected: 401 Unauthorized**

---

## 6️⃣ Monitor & Debug

### View API Gateway Logs
```bash
aws logs tail /aws/apigateway/taskflow-api --follow --since 1h
```

### View Lambda Logs
```bash
aws logs tail /aws/lambda/taskflow-create-task --follow --since 1h
aws logs tail /aws/lambda/taskflow-list-tasks --follow --since 1h
```

### Check Cognito User Pool
```bash
# List users
aws cognito-idp list-users --user-pool-id <USER_POOL_ID>

# Get user details
aws cognito-idp admin-get-user \
  --user-pool-id <USER_POOL_ID> \
  --username testuser@example.com
```

---

## 7️⃣ Frontend Integration (Next: J12-J14)

### Install AWS Amplify
```bash
cd taskflow-frontend/
npm install aws-amplify
```

### Create `src/config/aws-config.ts`
```typescript
export const awsConfig = {
  Auth: {
    region: "us-east-1",
    userPoolId: "<USER_POOL_ID>",
    userPoolWebClientId: "<CLIENT_ID>",
  },
};
```

### Use in Login Component
```typescript
import { Amplify, Auth } from 'aws-amplify';
import awsConfig from './config/aws-config';

Amplify.configure(awsConfig);

// Sign in
const user = await Auth.signIn(email, password);

// Get JWT
const session = await Auth.currentSession();
const jwt = session.idToken.jwtToken;

// Use in API calls
fetch('/tasks', {
  headers: {
    'Authorization': `Bearer ${jwt}`
  }
});
```

---

## 📋 Checklist

- [ ] Cognito User Pool created
- [ ] Test user created + password set
- [ ] App Client configured
- [ ] API Gateway JWT Authorizer enabled
- [ ] Lambda functions deployed
- [ ] Health endpoint works (no auth)
- [ ] Create task works (with JWT)
- [ ] List tasks works (with JWT)
- [ ] Update task works
- [ ] Delete task works
- [ ] Unauthorized requests return 401
- [ ] Cognito logs show successful authorizations

---

## ⚠️ Common Issues

### "Cognito User Pool not found"
```bash
# Fix: Check user pool exists
aws cognito-idp list-user-pools --max-results 10
```

### "Invalid JWT" error
```bash
# Fix: JWT may be expired (default: 1 hour)
# Get new token and try again
```

### "CORS error on frontend"
```bash
# Fix: Add frontend URL to Cognito App Client callback URLs
aws cognito-idp update-user-pool-client \
  --user-pool-id <USER_POOL_ID> \
  --client-id <CLIENT_ID> \
  --callback-urls "http://localhost:5173,https://yourdomain.com"
```

### Lambda can't write to DynamoDB
```bash
# Fix: Check Lambda execution role has DynamoDB permissions
aws iam get-role-policy \
  --role-name <LAMBDA_ROLE> \
  --policy-name DynamoDBAccess
```

---

**Next steps:** Frontend auth integration (J12-J14)

