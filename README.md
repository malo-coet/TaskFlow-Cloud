# TaskFlow Cloud — Gestionnaire de Tâches Serverless

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Node.js 20](https://img.shields.io/badge/Node.js-20.x-green.svg)](https://nodejs.org/)

TaskFlow Cloud est une application de gestion de tâches multi-utilisateurs haute performance, bâtie sur une architecture 100% Serverless AWS.

> **📌 [Documentation Index](INDEX.md)** — Find what you need  
> **🚀 [Deployment Guide](SETUP.md)** — Deploy to AWS  
> **🗺️ [30-day Roadmap](ROADMAP.md)** — Project timeline  
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
- **ChatGPT** : Aide à la conception d'architecture, résolution de bugs, documentation.

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

**Made with ❤️ and Copilot**

