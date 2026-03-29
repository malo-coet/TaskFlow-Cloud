# 🚀 TaskFlow Cloud — Gestionnaire de Tâches Serverless

[![CI/CD](https://github.com/malo-coet/TaskFlow-Cloud/actions/workflows/deploy.yml/badge.svg)](https://github.com/malo-coet/TaskFlow-Cloud/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Node.js 20](https://img.shields.io/badge/Node.js-20.x-green.svg)](https://nodejs.org/)

TaskFlow Cloud est une application de gestion de tâches multi-utilisateurs haute performance, bâtie sur une architecture 100% Serverless AWS. Ce projet démontre l'utilisation de l'Infrastructure as Code (IaC), du CI/CD et des bonnes pratiques FinOps.

> 🗺️ **[Voir la Roadmap 30 jours →](ROADMAP.md)**  
> 📋 **[Issues GitHub →](https://github.com/malo-coet/TaskFlow-Cloud/issues)**  
> 🏗️ **[Schéma d'architecture →](docs/architecture.png)** *(à venir)*

---

## 🏗️ Architecture du Système

```
User ──► CloudFront ──► S3 (SPA React/Vite)
           │
           └──► API Gateway (HTTP API)
                     │
                     └──► Lambda (Node.js)
                               │
                     ┌─────────┴─────────┐
                     ▼                   ▼
                 DynamoDB            Cognito
                 (Tasks)          (Auth / JWT)
                                       │
                                  CloudWatch
                               (Logs & Metrics)
```

- **Frontend** : SPA React/Vite hébergée sur **S3** + distribution **CloudFront** (HTTPS).
- **Backend API** : **API Gateway (HTTP API)** déclenchant des fonctions **Lambda** (Node.js).
- **Base de données** : **DynamoDB** (Single-Table Design — [voir le schéma](docs/dynamodb-schema.md)).
- **Authentification** : **AWS Cognito** (User Pool + tokens JWT vérifiés par API Gateway).
- **Observabilité** : **CloudWatch** (Logs, Metrics, Alarmes).
- **Infrastructure** : **Terraform** (modules S3, CloudFront, Lambda, API GW, DynamoDB, Cognito).

---

## 💰 Optimisation FinOps

Le projet est conçu pour résider intégralement dans le **AWS Free Tier** pour un usage de type portfolio.

| Service | Free Tier | Usage projet | Coût estimé |
| :--- | :--- | :--- | :--- |
| Lambda | 1M req + 400k GB‑sec / mois (Always Free) | ~1 000 req/mois | **0,00€** |
| API Gateway | 1M appels / mois pendant 12 mois | Très faible | **0,00€** |
| DynamoDB | 25 Go Always Free | < 1 Go | **0,00€** |
| S3 | 5 Go pendant 12 mois | ~100 Mo | **0,00€** |
| CloudFront | 1 To / mois Always Free | Quelques Mo | **0,00€** |
| Route 53 | Pas de Free Tier | 1 domaine (optionnel) | ~1–2€/mois |

---

## 🛡️ Décisions de Sécurité

- **IAM Least Privilege** : un rôle par Lambda, permissions minimales (pas de `*`).
- **JWT Cognito** : toutes les routes API sont protégées sauf `/health`.
- **HTTPS uniquement** via CloudFront + certificats ACM gratuits.
- **Pas de secrets en dur** : variables d'environnement Lambda, secrets GitHub Actions.
- **Throttling API Gateway** : 100 req/s par route pour limiter les abus.
- **CloudWatch Logs** : audit de tous les accès API.

---

## 🤖 Utilisation des outils IA (Copilot & ChatGPT)

Ce projet intègre l'IA comme **levier de productivité**, pas comme substitut aux compétences.

| Outil | Ce que j'ai laissé faire à l'IA | Ce que j'ai décidé moi-même |
|-------|--------------------------------|-----------------------------|
| **GitHub Copilot** | Génération de boilerplate Lambda, types TypeScript, tests unitaires | Architecture, modélisation DynamoDB, politiques IAM |
| **ChatGPT** | Clarifications AWS (HTTP API vs REST API), aide à la rédaction de la doc | Règles métier, décisions de sécurité, configuration finale |

*Chaque ligne de code générée a été revue, testée et validée manuellement.*

---

## 📁 Structure du projet

```
TaskFlow-Cloud/
├── frontend/           # SPA React/Vite (à créer — Semaine 1)
├── backend/            # Fonctions Lambda Node.js (à créer — Semaine 1)
├── infrastructure/     # Modules Terraform (à créer — Semaine 3)
├── .github/
│   ├── ISSUE_TEMPLATE/ # Templates d'issues GitHub
│   └── workflows/      # Pipelines CI/CD (à créer — Semaine 3)
├── docs/
│   ├── dynamodb-schema.md   # Schéma de la table DynamoDB
│   ├── architecture.png     # Diagramme d'architecture (à créer — Semaine 4)
│   └── screenshots/         # Captures d'écran (à créer — Semaine 4)
├── scripts/
│   └── create-issues.sh     # Script de création des issues GitHub
└── ROADMAP.md               # Roadmap 30 jours avec checklist
```

---

## 🚀 How to Run

> *Section complète à venir en Semaine 4 — voir [Issue #13](https://github.com/malo-coet/TaskFlow-Cloud/issues)*

**Prérequis :** AWS CLI, Terraform, Node.js 20+, `gh` CLI

```bash
# 1. Cloner le repo
git clone https://github.com/malo-coet/TaskFlow-Cloud.git
cd TaskFlow-Cloud

# 2. Déployer l'infrastructure
cd infrastructure
terraform init
terraform apply

# 3. Builder et déployer le frontend
cd ../frontend
npm install
npm run build
# L'URL CloudFront apparaît dans les outputs Terraform
```

---

## 🗺️ Roadmap

Voir [ROADMAP.md](ROADMAP.md) pour la roadmap complète sur 30 jours.

Pour créer automatiquement toutes les issues + labels + milestones dans GitHub :

```bash
# Prérequis : gh CLI installé et authentifié (gh auth login)
chmod +x scripts/create-issues.sh
./scripts/create-issues.sh
```
