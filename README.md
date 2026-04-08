# TaskFlow Cloud — Serverless Task Manager ☁️

**Status:** v0.3.0 - JWT Auth ✅ | Phase 2/4 | [Next Steps](#-next-phase)

---

## 📖 Documentation (Start Here!)

Pick your path:

| I want to... | Read this |
|-------------|-----------|
| **Deploy to AWS** | [AWS Manual Steps](AWS_MANUAL_STEPS.md) + [Deployment Guide](DEPLOYMENT_GUIDE.md) |
| **Test API endpoints** | [Testing Guide](TESTING_GUIDE.md) (with curl examples) |
| **Understand changes** | [CHANGELOG](CHANGELOG.md) (v0.3.0 = JWT Auth) |
| **See the 30-day plan** | [Roadmap](ROADMAP.md) |

---

## 🚀 Quick Start (5 min)

### 1. Deploy with Terraform
```bash
cd infra/
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Save these outputs:
# - api_endpoint
# - cognito_user_pool_id
# - cognito_client_id
```

### 2. Get JWT Token
```bash
JWT=$(aws cognito-idp admin-initiate-auth \
  --user-pool-id <USER_POOL_ID> \
  --client-id <CLIENT_ID> \
  --auth-flow ADMIN_USER_PASSWORD_AUTH \
  --auth-parameters USERNAME=testuser@example.com,PASSWORD=TestPassword123! \
  --query 'AuthenticationResult.IdToken' --output text)

echo $JWT  # Save this for API calls
```

### 3. Create a Task
```bash
curl -X POST https://<API_ID>.execute-api.us-east-1.amazonaws.com/tasks \
  -H "Authorization: Bearer $JWT" \
  -H "Content-Type: application/json" \
  -d '{"title": "Build TaskFlow", "dueDate": "2026-04-10"}'
```

**See [TESTING_GUIDE.md](TESTING_GUIDE.md) for all endpoints & debugging**

---

## ⚙️ Architecture

```
Frontend (React)          Backend (Lambda)        Data (DynamoDB)
├─ React Router           ├─ POST /tasks          └─ Tasks table
├─ Cognito Auth           ├─ GET /tasks           (PK: userId, SK: taskId)
└─ API calls              ├─ PUT /tasks/{id}
   with JWT               ├─ DELETE /tasks/{id}
                          └─ JWT auth check
                                 ↑
                          Cognito JWT Authorizer
```

---

## 📊 Current Phase (v0.3.0 - J10-J11)

✅ **Completed:**
- Cognito User Pool (Terraform-managed)
- JWT Authorizer on API Gateway
- Lambda CRUD routes with JWT protection
- Frontend Amplify auth library
- Complete testing guide

⏳ **Next (v0.4.0 - J12-J14):**
- [ ] Login/Signup pages
- [ ] Task CRUD UI
- [ ] Error handling & loading states
- [ ] Lambda unit tests

---

## 📁 Project Structure

```
infra/                      Backend Infrastructure (Terraform)
├── cognito.tf             User Pool, App Client, Domain
├── dynamodb.tf            Single-Table Design (USER#{userId}, TASK#{taskId})
├── lambda.tf              CRUD functions + IAM role
├── api_gateway_v2.tf      HTTP API v2 + JWT routes
└── provider.tf            AWS config

lambda/                     Lambda Functions (TypeScript)
├── functions/
│   ├── createTask.ts      POST /tasks
│   ├── listTasks.ts       GET /tasks
│   ├── updateTask.ts      PUT /tasks/{taskId}
│   └── deleteTask.ts      DELETE /tasks/{taskId}
├── shared/
│   ├── taskService.ts     DynamoDB operations
│   ├── authHelper.ts      JWT → userId extraction
│   └── types.ts           TypeScript interfaces
└── dist/                  Compiled + .zip files

taskflow-frontend/          React SPA (Vite)
├── src/
│   ├── lib/
│   │   ├── api.ts         HTTP client with JWT
│   │   └── auth.ts        Cognito Amplify
│   ├── pages/
│   │   ├── HomePage.tsx
│   │   └── LoginPage.tsx  (next)
│   └── App.tsx
└── .env.example           Cognito credentials template
```

---

## 🔧 Prerequisites

```bash
# Check versions
node --version          # v18+
aws --version          # v2+
terraform --version    # v1.5+
```

---

## 📋 Deployment Checklist

- [ ] AWS account configured: `aws sts get-caller-identity`
- [ ] Cognito User Pool created (manual or Terraform)
- [ ] Test user created
- [ ] App Client configured with callbacks
- [ ] Lambda functions built: `npm run build` (in lambda/)
- [ ] Terraform applied: `terraform apply tfplan`
- [ ] JWT token obtained & tested
- [ ] API endpoints respond with `Authorization` header

---

## 🧪 Testing

**All test commands in [TESTING_GUIDE.md](TESTING_GUIDE.md):**

1. Health check (public, no auth)
   ```bash
   curl https://<API>/health
   ```

2. Create task (with JWT)
   ```bash
   curl -X POST https://<API>/tasks \
     -H "Authorization: Bearer $JWT" \
     -d '{...}'
   ```

3. List, update, delete (same JWT pattern)

**Debug with:** `aws logs tail /aws/lambda/taskflow-* --follow`

---

## 🔐 Security Notes

- ✅ All CRUD routes require JWT (`/health` is public)
- ✅ Lambda has least-privilege IAM (DynamoDB only)
- ✅ CORS restricted (update for production)
- ⚠️ Token expiry: 1 hour (configure in cognito.tf)

---

## 🐛 Common Issues

| Problem | Solution |
|---------|----------|
| 401 Unauthorized | JWT expired? Re-run step 2 above |
| CORS error | Add frontend URL to Cognito callbacks |
| Lambda timeout | Check DynamoDB provisioning |
| No test user | Run AWS manual steps: [AWS_MANUAL_STEPS.md](AWS_MANUAL_STEPS.md) |

---

## 📞 Help

1. **Check the guide**: [TESTING_GUIDE.md](TESTING_GUIDE.md) or [AWS_MANUAL_STEPS.md](AWS_MANUAL_STEPS.md)
2. **View logs**: `aws logs tail /aws/apigateway/taskflow-api --follow`
3. **Verify config**: `terraform output` (in infra/)

---

## 🔗 Phase Status

| Phase | Dates | Status | Docs |
|-------|-------|--------|------|
| **1** | J1-J7 | ✅ Bootstrap | [v0.1.0](CHANGELOG.md) |
| **2** | J8-J11 | ✅ CRUD + Auth | [v0.2-0.3](CHANGELOG.md) |
| **3** | J12-J14 | 🔄 UI & Tests | See [Roadmap](ROADMAP.md) |
| **4** | J15-J30 | 📅 Prod Ready | See [Roadmap](ROADMAP.md) |
> **📝 [Changelog](CHANGELOG.md)** — What changed

---

## 📊 Current Status

| Phase | Status | What's Included |
|-------|--------|-----------------|
| ✅ Week 1 — Setup | Complete | AWS + Frontend (Vite + React) |
| ✅ Week 2 — CRUD | Complete | DynamoDB + 4 Lambda + API Gateway |
| ⏳ Week 2 — Auth | Next (J10-J11) | Cognito + JWT + Login/Signup |
| ⏳ Week 3-4 | Planned | CI/CD + Monitoring + Polish |

---

## 🏗️ Architecture

```
User ──► CloudFront ──► S3 (React)
           │
           └──► API Gateway (HTTP API)
                     │
                     └──► Lambda (Node.js 20)
                               │
                     ┌─────────┴─────────┐
                     ▼                   ▼
                 DynamoDB            Cognito
                 (Tasks)          (Auth / JWT)
                                       │
                                  CloudWatch
```

---

## 🚀 Quick Start

### 1. Deploy Infrastructure
```bash
# See SETUP.md for detailed steps
cd infra
terraform apply tfplan
```

### 2. Test API
```bash
# Get endpoint
API=$(cd infra && terraform output -raw api_endpoint)

# Test (returns 401 without JWT)
curl -X GET $API/tasks
```

### 3. Next: Add Auth (J10-J11)
See [docs/COGNITO_JWT_SETUP_J10_J11.md](docs/COGNITO_JWT_SETUP_J10_J11.md)

---

## 📚 Documentation

| Doc | Purpose |
|-----|---------|
| [INDEX.md](INDEX.md) | 📌 Navigation hub |
| [SETUP.md](SETUP.md) | 🚀 All deployment commands |
| [ROADMAP.md](ROADMAP.md) | 🗺️ 30-day plan |
| [CHANGELOG.md](CHANGELOG.md) | 📝 Version history |
| [docs/](docs/) | 🔧 Technical guides |

---

## 💰 Cost

**$0.00/month** — Fully on AWS Free Tier

| Service | Usage | Cost |
|---------|-------|------|
| Lambda | ~10K invocations/mo | $0.00 |
| DynamoDB | ~1K requests/mo | $0.00 |
| API Gateway | ~1K requests/mo | $0.00 |
| CloudWatch | ~10MB logs/mo | $0.00 |

---

## 🔐 Security

✅ DynamoDB encryption  
✅ IAM least privilege  
✅ CloudWatch logging  
✅ CORS configured  
⏳ JWT auth (coming J10-J11)  

---

## 📊 Tech Stack

- **Frontend:** React 19 + Vite + Tailwind CSS
- **Backend:** Node.js 20 Lambda + TypeScript
- **Database:** AWS DynamoDB
- **Auth:** AWS Cognito (coming J10-J11)
- **Infrastructure:** Terraform
- **API:** HTTP API Gateway

---

## 🎯 Project Goals

- ✅ Serverless CRUD API
- ✅ Production-ready code
- ✅ IaC best practices
- ⏳ Full authentication flow (J10-J11)
- ⏳ CI/CD pipeline (J15+)
- ⏳ Portfolio-ready polish (J22+)

---

## 🤔 Where to Start?

👉 **New here?** → Start with [INDEX.md](INDEX.md)  
👉 **Need deployment?** → Go to [SETUP.md](SETUP.md)  
👉 **Want details?** → Check [docs/](docs/)  
👉 **Want roadmap?** → See [ROADMAP.md](ROADMAP.md)

---

**Version:** v0.2.0 (J8-J9 Complete)  
**Last Updated:** April 2, 2026  
**License:** MIT

---

## 📚 Documentation

| Document | Lien | Durée | Description |
|----------|------|-------|-------------|
| **Roadmap 30j** | [ROADMAP.md](ROADMAP.md) | 5 min | Vue d'ensemble du projet |
| **CHANGELOG** | [CHANGELOG.md](CHANGELOG.md) | 3 min | Historique des versions |
| **DynamoDB Schema** | [docs/dynamodb-schema.md](docs/dynamodb-schema.md) | 10 min | Single-Table Design pattern |
| **J8-J9 Guide** | [docs/IMPLEMENTATION_GUIDE_J8_J9.md](docs/IMPLEMENTATION_GUIDE_J8_J9.md) | 20 min | Lambda CRUD + API Gateway setup |
| **J10-J11 Cognito** | [docs/COGNITO_JWT_SETUP_J10_J11.md](docs/COGNITO_JWT_SETUP_J10_J11.md) | 25 min | Auth & JWT Authorizer setup |
| **Lambda Functions** | [lambda/README.md](lambda/README.md) | 10 min | CRUD handlers & testing |
| **Frontend Bootstrap** | [taskflow-frontend/README.md](taskflow-frontend/README.md) | 5 min | React/Vite setup |

---

## 🚀 Quick Start — J8-J9 (Lambda CRUD)

### 1. Build & Package Lambda Functions
```bash
cd scripts
bash deploy-lambda.sh
```

### 2. Deploy Infrastructure
```bash
cd infra
terraform init
terraform plan
terraform apply
```

### 3. Test CRUD Endpoints
```bash
# Get API endpoint from Terraform output
API_ENDPOINT=$(terraform output -raw api_endpoint)

# Example: Create a task
curl -X POST $API_ENDPOINT/tasks \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Learn Terraform",
    "description": "Complete IaC setup",
    "dueDate": "2025-05-01"
  }'
```

---

## 💰 Optimisation FinOps

Le projet est conçu pour résider intégralement dans le **AWS Free Tier** pour un usage de type portfolio (< 1€/mois).

| Service | Usage | Coût |
|---------|-------|------|
| Lambda | ~10,000 invocations/mois | **$0.00** (1M free/mois) |
| DynamoDB (on-demand) | ~1,000 req/mois | **$0.00** (Always Free) |
| API Gateway HTTP | ~1,000 req/mois | **$0.00** (Always Free) |
| CloudFront | 50 GB transfert | **$0.00** (Always Free) |
| CloudWatch Logs | ~10 MB/mois | **$0.00** (5GB free/mois) |
| **Total** | | **$0.00/mois** ✅ |

---

## 🤖 Utilisation de l'IA (Copilot & ChatGPT)

Ce projet intègre l'IA comme levier de productivité :
- **GitHub Copilot** : Génération de boilerplate, types TypeScript, handlers Lambda, tests.

*Note : Chaque ligne de code générée a été revue, testée et validée manuellement.*

---

## 🔐 Sécurité

- ✅ JWT Cognito Authorizer sur tous les endpoints `/tasks`
- ✅ IAM least-privilege (Lambda ne peut accéder qu'à DynamoDB)
- ✅ HTTPS/CloudFront obligatoire
- ✅ CORS configuré
- ✅ Access logs API Gateway + CloudWatch
- ⚠️ À implémenter : Rate limiting, WAF, secrets rotation

---

## 📁 Structure du Projet

```
TaskFlow/
├── README.md                    ← Tu es ici
├── CHANGELOG.md                 ← Historique des versions
├── ROADMAP.md                   ← 30-jour roadmap
│
├── docs/
│   ├── dynamodb-schema.md       ← DynamoDB design
│   ├── IMPLEMENTATION_GUIDE_J8_J9.md    ← Lambda CRUD setup
│   └── COGNITO_JWT_SETUP_J10_J11.md     ← Auth setup
│
├── infra/                       ← Infrastructure Terraform
│   ├── provider.tf              ← AWS region config
│   ├── dynamodb.tf              ← Table DynamoDB
│   ├── lambda.tf                ← Lambda functions + IAM
│   ├── api_gateway.tf           ← HTTP API Gateway
│   └── s3.tf                    ← S3 buckets
│
├── lambda/
│   ├── README.md                ← Lambda functions guide
│   ├── functions/               ← CRUD handlers (TypeScript)
│   │   ├── createTask.ts
│   │   ├── listTasks.ts
│   │   ├── updateTask.ts
│   │   ├── deleteTask.ts
│   │   └── package.json
│   ├── shared/
│   │   └── taskService.ts       ← DynamoDB service layer
│   └── health-check/            ← Basic health endpoint
│
├── scripts/
│   ├── deploy-lambda.sh         ← Build & package Lambda
│   ├── create-issues.sh         ← Create GitHub issues
│   └── deploy-api-gateway.sh
│
└── taskflow-frontend/           ← React/Vite frontend
    ├── README.md
    ├── src/
    │   ├── components/          ← React components
    │   ├── pages/               ← Page components
    │   └── lib/
    │       ├── api.ts           ← API client
    │       └── auth.ts          ← Cognito auth (J10)
    └── vite.config.ts
```

---

## 🧪 Tests

### Lambda CRUD Functions
```bash
cd lambda/functions
npm run build
npm run test
```

### Frontend
```bash
cd taskflow-frontend
npm run build
npm run lint
```

---

## 📞 Support

- Issues: [GitHub Issues](https://github.com/malo-coet/TaskFlow-Cloud/issues)
- Discussions: [GitHub Discussions](https://github.com/malo-coet/TaskFlow-Cloud/discussions)

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details

