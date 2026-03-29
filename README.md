# 🚀 TaskFlow Cloud - Gestionnaire de Tâches Serverless

TaskFlow Cloud est une application de gestion de tâches multi-utilisateurs haute performance, bâtie sur une architecture 100% Serverless AWS. Ce projet démontre l'utilisation de l'Infrastructure as Code (IaC), du CI/CD et des bonnes pratiques FinOps.

## 🏗️ Architecture du Système
- **Frontend** : SPA React/Vite hébergée sur **S3** + distribution **CloudFront** (HTTPS).
- **Backend API** : **API Gateway (HTTP API)** déclenchant des fonctions **Lambda** (Node.js).
- **Base de données** : **DynamoDB** (Modélisation Single-Table design).
- **Authentification** : **AWS Cognito** (Gestion des identités et JWT).
- **Observabilité** : **CloudWatch** (Logs & Metrics).
- **Infrastructure** : **Terraform** (ou AWS SAM).

## 💰 Optimisation FinOps
Le projet est conçu pour résider intégralement dans le **AWS Free Tier** pour un usage de type portfolio (< 1€/mois pour le nom de domaine).
| Service | Usage | Coût |
| :--- | :--- | :--- |
| Lambda / DynamoDB | ~1000 req/mois | 0,00€ (Always Free) |
| CloudFront | 1 To de transfert | 0,00€ (Always Free) |

## 🛡️ Sécurité
- Permissions IAM granulaires (Principle of Least Privilege).
- Protection des routes API via Authorizer Cognito (JWT).
- En-têtes de sécurité via CloudFront.

## 🤖 Utilisation de l'IA (Copilot & ChatGPT)
Ce projet intègre l'IA comme levier de productivité :
- **GitHub Copilot** : Génération de boilerplate et tests unitaires.
- **ChatGPT** : Aide à la conception de l'architecture et résolution de bugs complexes.
*Note : Chaque ligne de code générée a été revue, testée et validée manuellement.*
