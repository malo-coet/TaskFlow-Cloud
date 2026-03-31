# TaskFlow Cloud — Gestionnaire de Tâches Serverless

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

## Optimisation FinOps
Le projet est conçu pour résider intégralement dans le **AWS Free Tier** pour un usage de type portfolio (< 1€/mois pour le nom de domaine).
| Service | Usage | Coût |
| :--- | :--- | :--- |
| Lambda / DynamoDB | ~1000 req/mois | 0,00€ (Always Free) |
| CloudFront | 1 To de transfert | 0,00€ (Always Free) |

---

## Utilisation de l'IA (Copilot & ChatGPT)
Ce projet intègre l'IA comme levier de productivité :
- **GitHub Copilot** : Génération de boilerplate et tests unitaires.
- **ChatGPT** : Aide à la conception de l'architecture et résolution de bugs complexes.
*Note : Chaque ligne de code générée a été revue, testée et validée manuellement.*
