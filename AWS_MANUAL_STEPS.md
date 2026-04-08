# 🔧 AWS Manual Steps - TaskFlow Cognito Setup

## Step 1: Create Cognito User Pool (AWS Console)

1. Go to **AWS Cognito Console** → User Pools → Create
2. **Pool name:** `taskflow-user-pool`
3. **Sign-in options:** Email
4. **Password policy:**
   - Minimum length: 8
   - Uppercase: Yes
   - Numbers: Yes
   - Symbols: No
5. **Multi-factor authentication:** Optional (for MVP)
6. **Create**

---

## Step 2: Create App Client

1. In User Pool → **App Integration** → **App Clients and analytics**
2. **Create app client**
3. **App name:** `taskflow-web`
4. **Auth flows:**
   - ✅ USER_PASSWORD_AUTH
   - ✅ ALLOW_REFRESH_TOKEN_AUTH
5. **Token expiry:**
   - Access token: 1 hour
   - Refresh token: 30 days
   - ID token: 1 hour
6. **Create app client**

---

## Step 3: Save Client Configuration

Copy these values (you'll need them):

```
User Pool ID: <SAVED>
Client ID: <SAVED>
Region: us-east-1
```

Store in environment variables:
```bash
export COGNITO_USER_POOL_ID="us-east-1_xxxxxxxxx"
export COGNITO_CLIENT_ID="abcd1234efgh5678..."
export COGNITO_REGION="us-east-1"
```

---

## Step 4: Create Test User

### Via AWS Console:
1. User Pool → **Users** → **Create user**
2. **Username:** `testuser@example.com`
3. **Email:** `testuser@example.com`
4. **Mark email as verified:** ✅
5. **Temporary password:** `TempPassword123!`
6. **Create user**

### Set Permanent Password:
1. Right-click user → **Set password**
2. **Password:** `TestPassword123!`
3. **Make permanent:** ✅
4. **Set password**

---

## Step 5: Configure App Client Callbacks (IMPORTANT for frontend)

1. User Pool → **App Integration** → **App client settings**
2. **Allowed callback URLs:**
   ```
   http://localhost:5173
   http://localhost:5173/auth/callback
   ```
3. **Sign out URLs:**
   ```
   http://localhost:5173/auth/logout
   http://localhost:5173
   ```
4. **Save changes**

---

## Step 6: Get JWT Token (for testing)

### Option A: AWS CLI
```bash
aws cognito-idp admin-initiate-auth \
  --user-pool-id us-east-1_xxxxxxxxx \
  --client-id abcd1234efgh5678 \
  --auth-flow ADMIN_USER_PASSWORD_AUTH \
  --auth-parameters USERNAME=testuser@example.com,PASSWORD=TestPassword123!
```

**Response:**
```json
{
  "AuthenticationResult": {
    "IdToken": "eyJhbGc...",  ← USE THIS
    "AccessToken": "eyJhbGc...",
    "RefreshToken": "eyJjdHk...",
    "ExpiresIn": 3600
  }
}
```

### Option B: Hosted UI
```bash
# 1. Get your domain
DOMAIN="taskflow-$(aws sts get-caller-identity --query Account --output text)"

# 2. Go to this URL in browser
https://${DOMAIN}.auth.us-east-1.amazoncognito.com/login?client_id=<CLIENT_ID>&response_type=code&scope=openid+email+profile&redirect_uri=http://localhost:5173

# 3. Login with testuser@example.com / TestPassword123!
# 4. Browser redirects to: http://localhost:5173?code=...
# 5. Exchange code for tokens (requires backend endpoint)
```

---

## Step 7: Test with JWT Token

Save the `IdToken` value:
```bash
JWT="eyJhbGc..."  # Paste IdToken from step 6
API_URL="https://xxxxxx.execute-api.us-east-1.amazonaws.com"
```

### Test Health (no auth)
```bash
curl -X GET $API_URL/health
```

### Test Create Task (with JWT)
```bash
curl -X POST $API_URL/tasks \
  -H "Authorization: Bearer $JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Task",
    "description": "Created from CLI",
    "dueDate": "2026-04-10"
  }'
```

### Test List Tasks (with JWT)
```bash
curl -X GET $API_URL/tasks \
  -H "Authorization: Bearer $JWT"
```

---

## Step 8: Lambda IAM Role (verify permissions)

Check that Lambda execution role has DynamoDB permissions:

```bash
# Get Lambda function
LAMBDA_ROLE=$(aws lambda get-function-configuration \
  --function-name taskflow-create-task \
  --query Role --output text)

# List attached policies
aws iam list-attached-role-policies --role-name $(basename $LAMBDA_ROLE)
```

**Should have:** `DynamoDBAccess` or similar policy

---

## Step 9: API Gateway JWT Authorizer (verify)

Check authorizer is configured:
```bash
# List authorizers
aws apigatewayv2 get-authorizers --api-id <API_ID>
```

**Should show:**
- Type: JWT
- Identity source: `$request.header.Authorization`
- Issuer: `https://cognito-idp.us-east-1.amazonaws.com/<USER_POOL_ID>`

---

## Step 10: Monitor CloudWatch Logs

### API Gateway
```bash
aws logs tail /aws/apigateway/taskflow-api --follow
```

### Lambda
```bash
aws logs tail /aws/lambda/taskflow-create-task --follow
aws logs tail /aws/lambda/taskflow-list-tasks --follow
```

### Cognito (sign-in attempts)
```bash
aws logs tail /aws/cognito/user-pool/taskflow --follow
```

---

## 🔐 Security Checklist

- [ ] User Pool has strong password policy
- [ ] MFA enabled (optional for MVP)
- [ ] Token expiry set to 1 hour (not too long)
- [ ] API Gateway JWT Authorizer enabled
- [ ] Health endpoint excluded from auth (/health)
- [ ] CORS restricted to your frontend domain (production)
- [ ] Lambda role has **least privilege** (DynamoDB only)
- [ ] No hardcoded credentials in code
- [ ] Cognito domain set to custom subdomain (optional)

---

## ✅ Final Verification

```bash
# 1. User Pool exists
aws cognito-idp describe-user-pool --user-pool-id <USER_POOL_ID>

# 2. App Client exists
aws cognito-idp describe-user-pool-client \
  --user-pool-id <USER_POOL_ID> \
  --client-id <CLIENT_ID>

# 3. Test user exists
aws cognito-idp admin-get-user \
  --user-pool-id <USER_POOL_ID> \
  --username testuser@example.com

# 4. API Gateway has authorizer
aws apigatewayv2 get-authorizers --api-id <API_ID>

# 5. Can get JWT
aws cognito-idp admin-initiate-auth \
  --user-pool-id <USER_POOL_ID> \
  --client-id <CLIENT_ID> \
  --auth-flow ADMIN_USER_PASSWORD_AUTH \
  --auth-parameters USERNAME=testuser@example.com,PASSWORD=TestPassword123!
```

---

## Next: Terraform Automation

Once tested manually, run Terraform to automate:

```bash
cd infra/
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Terraform files will create:
- ✅ Cognito User Pool + Client
- ✅ JWT Authorizer
- ✅ API Gateway routes with auth
- ✅ Lambda permissions

**All automated = no more manual steps!**

