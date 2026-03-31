# 🗺️ Roadmap TaskFlow Cloud — 30 jours

> **Objectif :** Livrer une application de gestion de tâches serverless, production-ready, recruiter-friendly en 30 jours.
>
> Suivi : chaque item correspond à une **GitHub Issue** avec son label de semaine et sa catégorie.  
> Script de création automatique des issues → [`scripts/create-issues.sh`](scripts/create-issues.sh)

---

## Vue d'ensemble

```
Semaine 1  →  Setup & Squelette
Semaine 2  →  CRUD & Authentification
Semaine 3  →  IaC, CI/CD, Observabilité
Semaine 4  →  Finition "recruiter-friendly" + Pitch
```

---

## 🗓️ Semaine 1 (J1–J7) — Setup & Squelette

**Objectif de fin de semaine :** Frontend minimal + backend "hello world" déployé, sans auth.

### J1–J2 · Setup initial

- [x] Créer le compte AWS et activer MFA
- [x] Installer et configurer AWS CLI (`aws configure`)
- [x] Installer Terraform (ou AWS SAM CLI)
- [x] Vérifier que le repo GitHub est créé et GitHub Copilot activé
- [x] Créer les labels et milestones GitHub via `scripts/create-issues.sh`

> **Outils suggérés :**
> - [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
> - [Terraform](https://developer.hashicorp.com/terraform/downloads) ou [AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html)
> - [GitHub Copilot](https://github.com/features/copilot)

### J3–J4 · Bootstrap Frontend

- [x] Bootstraper la SPA React/Vite (`npm create vite@latest frontend -- --template react-ts`)
- [x] Créer une page "Hello TaskFlow" avec routing basique (React Router)
- [x] Configurer ESLint + Prettier
- [x] Utiliser Copilot pour générer le squelette des composants React principaux

> **Outils suggérés :**
> - [Vite](https://vitejs.dev/) + [React](https://react.dev/)
> - [React Router v6](https://reactrouter.com/)
> - [Tailwind CSS](https://tailwindcss.com/) (optionnel, pour un UI soigné rapidement)

### J5–J7 · Lambda Hello World + API Gateway

- [ ] Créer une Lambda Node.js `health-check` (`/health` → `{ status: "ok" }`)
- [ ] Configurer un API Gateway HTTP API pointant sur cette Lambda
- [ ] Appeler l'endpoint depuis le frontend et afficher la réponse
- [ ] Définir le schéma de la table DynamoDB (voir `docs/dynamodb-schema.md`)
- [ ] Provisionner manuellement les ressources AWS (avant IaC)

> **Outils suggérés :**
> - [Hoppscotch](https://hoppscotch.io/) ou [Insomnia](https://insomnia.rest/) pour tester les endpoints
> - [AWS Console](https://console.aws.amazon.com/) pour valider le déploiement

---

## 🗓️ Semaine 2 (J8–J14) — CRUD & Authentification

**Objectif de fin de semaine :** Utilisateur connecté peut gérer ses tâches (CRUD complet, auth fonctionnelle).

### J8–J9 · DynamoDB + Lambda CRUD

- [ ] Créer la table DynamoDB `Tasks` (PK: `userId`, SK: `taskId`)
  - Attributs : `taskId`, `userId`, `title`, `description`, `status`, `dueDate`, `tags`, `createdAt`, `updatedAt`
- [ ] Implémenter Lambda `createTask` (POST `/tasks`)
- [ ] Implémenter Lambda `listTasks` (GET `/tasks`)
- [ ] Implémenter Lambda `updateTask` (PUT `/tasks/{taskId}`)
- [ ] Implémenter Lambda `deleteTask` (DELETE `/tasks/{taskId}`)
- [ ] Utiliser Copilot pour générer les handlers et les types TypeScript

> **Outils suggérés :**
> - [AWS SDK v3 for JS](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/)
> - [DynamoDB Toolbox](https://github.com/jeremydaly/dynamodb-toolbox) (simplifie les opérations DDB)
> - [Middy](https://middy.js.org/) (middleware pour Lambda)

### J10–J11 · Cognito + JWT sur API Gateway

- [ ] Créer un Cognito User Pool (signup/login par email)
- [ ] Configurer un App Client Cognito pour le frontend
- [ ] Ajouter un Authorizer JWT Cognito sur API Gateway (toutes routes sauf `/health`)
- [ ] Intégrer AWS Amplify Auth ou `amazon-cognito-identity-js` dans le frontend
- [ ] Créer les pages Login et Signup dans le frontend

> **Outils suggérés :**
> - [AWS Amplify Auth](https://docs.amplify.aws/lib/auth/getting-started/) ou [`amazon-cognito-identity-js`](https://github.com/aws-amplify/amplify-js/tree/main/packages/amazon-cognito-identity-js)

### J12–J14 · Intégration CRUD Frontend + Tests

- [ ] Intégrer le CRUD complet dans le frontend (liste, ajout, édition, suppression de tâches)
- [ ] Gérer les états de chargement et les erreurs dans l'UI
- [ ] Ajouter au moins 5 tests unitaires sur les Lambdas (Jest ou Vitest)
- [ ] Documenter dans le README comment l'auth fonctionne

> **Outils suggérés :**
> - [React Query (TanStack Query)](https://tanstack.com/query) pour la gestion des états serveur
> - [Jest](https://jestjs.io/) ou [Vitest](https://vitest.dev/) pour les tests Lambda
> - [aws-sdk-mock](https://github.com/dwyl/aws-sdk-mock) pour mocker DynamoDB dans les tests

---

## 🗓️ Semaine 3 (J15–J21) — IaC, CI/CD, Observabilité

**Objectif de fin de semaine :** Un seul `git push main` déclenche build, tests, déploiement complet.

### J15–J17 · Infrastructure as Code

- [ ] Écrire les modules Terraform (ou SAM) pour :
  - [ ] S3 bucket (static website hosting)
  - [ ] CloudFront distribution (HTTPS + OAC)
  - [ ] API Gateway HTTP API
  - [ ] Fonctions Lambda (avec rôles IAM granulaires)
  - [ ] Table DynamoDB
  - [ ] Cognito User Pool + App Client
- [ ] Stocker le state Terraform dans un S3 bucket dédié (ou utiliser Terraform Cloud)
- [ ] Utiliser Copilot pour générer les blocs Terraform/SAM, puis relire attentivement

> **Outils suggérés :**
> - [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
> - [Infracost](https://www.infracost.io/) pour estimer les coûts Terraform
> - [tfsec](https://aquasecurity.github.io/tfsec/) pour scanner la sécurité de l'IaC

### J18–J19 · Pipeline CI/CD GitHub Actions

- [ ] Job `build-and-test` : lint ESLint, build Vite, tests Jest/Vitest
- [ ] Job `deploy-infra` : `terraform plan` + `terraform apply` (sur push `main`)
- [ ] Job `deploy-frontend` : build → upload S3 → invalidation CloudFront
- [ ] Stocker les credentials AWS comme secrets GitHub Actions
- [ ] Ajouter un badge CI dans le README

> **Outils suggérés :**
> - [GitHub Actions](https://github.com/features/actions)
> - [`aws-actions/configure-aws-credentials`](https://github.com/aws-actions/configure-aws-credentials)
> - [OIDC pour AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services) (évite les secrets long-lived)

### J20–J21 · CloudWatch + Sécurité API Gateway

- [ ] Configurer CloudWatch Log Groups pour toutes les Lambdas
- [ ] Créer un tableau de bord CloudWatch (erreurs 5xx, latence P99, throttles)
- [ ] Activer CloudWatch Logs sur API Gateway (access logs)
- [ ] Configurer le throttling sur API Gateway (ex : 100 req/s par route)
- [ ] Ajouter des alarmes CloudWatch (ex : taux d'erreur > 5%)

> **Outils suggérés :**
> - [Lumigo](https://lumigo.io/) ou [Sentry](https://sentry.io/) pour l'observabilité Lambda (optionnel)
> - [AWS X-Ray](https://aws.amazon.com/xray/) pour le tracing distribué (optionnel)

---

## 🗓️ Semaine 4 (J22–J30) — Finition "Recruiter-Friendly" + Pitch

**Objectif :** Projet 100% présentable pour un recruteur tech.

### J22–J23 · Schéma d'architecture

- [ ] Créer le diagramme d'architecture dans Excalidraw ou draw.io :
  - Flux : User → CloudFront → S3 (SPA) + API Gateway → Lambda → DynamoDB
  - Cognito et CloudWatch sur les côtés
  - Annotations : "HTTP API (coût réduit)", "Serverless", "Always Free Tier"
- [ ] Exporter en PNG et placer dans `docs/architecture.png`
- [ ] Référencer le schéma dans le README

> **Outils suggérés :**
> - [Excalidraw](https://excalidraw.com/) (open source, export PNG)
> - [draw.io / diagrams.net](https://app.diagrams.net/)
> - [Lucidchart](https://www.lucidchart.com/)
> - [AWS Architecture Icons](https://aws.amazon.com/architecture/icons/)

### J24–J25 · README niveau professionnel

- [ ] Ajouter le diagramme d'architecture
- [ ] Section "Stack Technique" détaillée
- [ ] Section "Décisions de sécurité" (IAM least privilege, JWT, HTTPS, throttling)
- [ ] Tableau "Coûts estimés" (Free Tier)
- [ ] Section "Utilisation des outils IA" (Copilot + ChatGPT)
- [ ] Section "How to Run" (étapes de déploiement claires)
- [ ] Badges : CI status, licence, version Node.js

### J26–J27 · Captures d'écran

- [ ] Capture : page de Login / Signup
- [ ] Capture : liste des tâches + filtres par tag/status
- [ ] Capture : ajout / édition d'une tâche
- [ ] Capture : gestion d'erreur (ex : 401 non authentifié)
- [ ] Capture : pipeline GitHub Actions passé au vert
- [ ] Placer les captures dans `docs/screenshots/`

### J28–J29 · Script de déploiement + documentation

- [ ] Rédiger la section "How to Run" dans le README :
  1. Créer un compte AWS, configurer credentials
  2. Cloner le repo
  3. Lancer `terraform init && terraform apply`
  4. Lancer `npm install && npm run build` pour le frontend
  5. Trouver l'URL CloudFront dans les outputs Terraform
- [ ] Créer `scripts/deploy.sh` ou un `Makefile` pour automatiser le déploiement
- [ ] Fournir un compte de démo (`demo@taskflow.com / Demo123!`) si possible

### J30 · Nettoyage final + Pitch

- [ ] Vérifier que le projet se déploie from scratch sur un compte AWS vierge
- [ ] Supprimer toutes les ressources AWS de test (éviter les coûts)
- [ ] S'assurer que tout est lisible sur GitHub sans connaissance préalable
- [ ] Préparer le pitch 2–3 min : problème → solution → stack → coûts → sécurité → IA
- [ ] Vérifier que le README contient le lien de démo et les captures d'écran

---

## 🏷️ Labels GitHub

| Label | Couleur | Description |
|-------|---------|-------------|
| `semaine-1` | `#0075ca` | Semaine 1 - Setup & Squelette |
| `semaine-2` | `#e4e669` | Semaine 2 - CRUD & Auth |
| `semaine-3` | `#d93f0b` | Semaine 3 - IaC, CI/CD, Observabilité |
| `semaine-4` | `#0e8a16` | Semaine 4 - Finition & Pitch |
| `frontend` | `#bfd4f2` | Composants React/Vite |
| `backend` | `#fef2c0` | Lambda, API Gateway |
| `infrastructure` | `#e99695` | Terraform/SAM, AWS resources |
| `ci-cd` | `#c5def5` | GitHub Actions |
| `auth` | `#f9d0c4` | Cognito, JWT |
| `observabilite` | `#d4c5f9` | CloudWatch, monitoring |
| `documentation` | `#cfd3d7` | README, docs |
| `securite` | `#b60205` | IAM, throttling, sécurité |

---

## 📊 Milestones GitHub

| Milestone | Deadline | Objectif |
|-----------|----------|----------|
| `Semaine 1 — Setup & Squelette` | J+7 | Frontend minimal + backend hello world |
| `Semaine 2 — CRUD & Auth` | J+14 | CRUD complet + auth fonctionnelle |
| `Semaine 3 — IaC, CI/CD, Observabilité` | J+21 | Déploiement automatisé via git push |
| `Semaine 4 — Finition & Pitch` | J+30 | Projet recruiter-friendly |

---

## 🔧 Outils de gestion de projet recommandés

| Outil | Usage | Lien |
|-------|-------|------|
| **GitHub Projects** | Kanban board des issues (vue Board + Roadmap) | [Créer un projet](https://github.com/malo-coet/TaskFlow-Cloud/projects) |
| **GitHub Issues** | Suivi de chaque tâche avec labels et milestones | [Issues](https://github.com/malo-coet/TaskFlow-Cloud/issues) |
| **Notion** | Notes, brouillons, réflexions archi | [notion.so](https://notion.so) |
| **Excalidraw** | Diagrammes d'architecture rapides | [excalidraw.com](https://excalidraw.com) |
| **Hoppscotch** | Tester les endpoints REST | [hoppscotch.io](https://hoppscotch.io) |
| **Infracost** | Estimer les coûts Terraform avant apply | [infracost.io](https://infracost.io) |

---

> **Comment utiliser ce fichier :**
> 1. Ouvrir [`scripts/create-issues.sh`](scripts/create-issues.sh) et lancer le script sur votre machine pour créer automatiquement toutes les issues + labels + milestones dans le repo GitHub.
> 2. Créer un **GitHub Project** (type "Board" ou "Roadmap") et lier ce repo → toutes les issues apparaîtront automatiquement.
> 3. Cocher les tâches dans ce fichier au fur et à mesure de l'avancement.
