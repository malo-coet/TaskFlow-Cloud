# 📚 TaskFlow Documentation Index

Quick reference for all project documentation.

---

## 🚀 Getting Started

| Document | Purpose | For |
|----------|---------|-----|
| **[README.md](README.md)** | Main project overview & quick start | Everyone |
| **[TESTING_GUIDE.md](TESTING_GUIDE.md)** | How to test API endpoints with JWT | Developers |
| **[AWS_MANUAL_STEPS.md](AWS_MANUAL_STEPS.md)** | Step-by-step AWS console setup | DevOps |

---

## 📖 Reference

| Document | Purpose | For |
|----------|---------|-----|
| **[CHANGELOG.md](CHANGELOG.md)** | What was built in each version | Everyone |
| **[ROADMAP.md](ROADMAP.md)** | 30-day project timeline & phases | Product Managers |
| **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** | Full deployment commands (Terraform + AWS CLI) | DevOps |

---

## 🔄 Current Phase

| Document | Purpose |
|----------|---------|
| **[PHASE_J10_J11_COMPLETE.md](PHASE_J10_J11_COMPLETE.md)** | What was built in J10-J11 (JWT Auth) |

---

## 📁 In-Code Documentation

| Path | Purpose |
|------|---------|
| `infra/README.md` | Terraform setup & outputs |
| `lambda/README.md` | Lambda build & deployment |
| `lambda/shared/taskService.ts` | DynamoDB operations (JSDoc comments) |
| `lambda/shared/authHelper.ts` | JWT extraction helpers |
| `taskflow-frontend/README.md` | Frontend setup & build |

---

## 🎯 By Role

### Developer (Full-Stack)
1. Read: [README.md](README.md) - understand architecture
2. Read: [TESTING_GUIDE.md](TESTING_GUIDE.md) - test locally
3. Deploy: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - run Terraform
4. Reference: [CHANGELOG.md](CHANGELOG.md) - what was built

### DevOps
1. Read: [AWS_MANUAL_STEPS.md](AWS_MANUAL_STEPS.md) - AWS setup
2. Deploy: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Terraform
3. Monitor: `aws logs tail ...` commands in [TESTING_GUIDE.md](TESTING_GUIDE.md)

### Product/Manager
1. Read: [ROADMAP.md](ROADMAP.md) - timeline
2. Track: [CHANGELOG.md](CHANGELOG.md) - progress
3. Status: [PHASE_J10_J11_COMPLETE.md](PHASE_J10_J11_COMPLETE.md) - current phase

---

## 📊 Document Status

| Document | Last Updated | Status |
|----------|--------------|--------|
| README.md | 2026-04-03 | ✅ v0.3.0 complete |
| CHANGELOG.md | 2026-04-03 | ✅ v0.3.0 entry |
| TESTING_GUIDE.md | 2026-04-03 | ✅ JWT + all endpoints |
| AWS_MANUAL_STEPS.md | 2026-04-03 | ✅ Cognito setup |
| DEPLOYMENT_GUIDE.md | 2026-04-03 | ✅ Terraform + AWS CLI |
| ROADMAP.md | 2026-03-29 | 📅 Phases 1-4 outline |
| PHASE_J10_J11_COMPLETE.md | 2026-04-03 | ✅ Current work |

---

## ❓ Common Questions

**Q: Where do I start?**  
A: Read [README.md](README.md) first, then pick your path above

**Q: How do I test the API?**  
A: [TESTING_GUIDE.md](TESTING_GUIDE.md) has curl examples & JWT instructions

**Q: How do I deploy?**  
A: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for all commands

**Q: Where's the AWS setup?**  
A: [AWS_MANUAL_STEPS.md](AWS_MANUAL_STEPS.md) for manual setup, or use Terraform

**Q: What's the plan?**  
A: [ROADMAP.md](ROADMAP.md) shows all 30 days

**Q: What changed recently?**  
A: [CHANGELOG.md](CHANGELOG.md) for version history

---

## 🔗 Quick Links

**AWS Services:**
- [Cognito Console](https://console.aws.amazon.com/cognito)
- [API Gateway Console](https://console.aws.amazon.com/apigateway)
- [Lambda Console](https://console.aws.amazon.com/lambda)
- [DynamoDB Console](https://console.aws.amazon.com/dynamodb)

**Tools:**
- [Terraform Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Docs](https://docs.aws.amazon.com/cli/)
- [AWS SDK v3 JS](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/)

---

**Total Documentation:** 7 files | Last sync: 2026-04-03

