# 📝 CHANGELOG - TaskFlow Cloud Project

## [v0.2.0] - 2026-04-02 - DynamoDB & Lambda CRUD Implementation

### 🎯 Objectifs de fin de phase (J8-J9)
✅ DynamoDB table créée avec Single-Table Design  
✅ 4 Lambda functions CRUD implémentées (TypeScript)  
✅ API Gateway HTTP API configurée avec 4 routes  
✅ IAM roles et policies configurés (least privilege)  
✅ TaskService partagée pour opérations DynamoDB  
✅ Infrastructure complète en Terraform  

### 📦 Backend Changes

#### **Infrastructure Terraform** (`infra/`)
- ✅ **dynamodb.tf** - Table `TaskFlow-Tasks` avec Single-Table Design
  - PK: `USER#{userId}` | SK: `TASK#{taskId}`
  - GSI-Status et GSI-DueDate pour filtrage
  - On-demand billing (Free Tier compatible)
  - PITR et Server-side encryption enabled
  - Streaming enabled pour futures extensions

- ✅ **lambda.tf** - 4 Lambda functions + IAM
  - `createTask` (POST /tasks) - Créer une nouvelle tâche
  - `listTasks` (GET /tasks) - Lister les tâches de l'utilisateur
  - `updateTask` (PUT /tasks/{taskId}) - Mettre à jour une tâche
  - `deleteTask` (DELETE /tasks/{taskId}) - Supprimer une tâche
  - IAM Role avec least privilege (DynamoDB access only)
  - CloudWatch Logs intégrés

- ✅ **api_gateway.tf** - HTTP API Gateway
  - 4 routes pour CRUD complet
  - CORS configuré (à restreindre en production)
  - Access logs dans CloudWatch
  - Lambda permissions configurées

#### **Lambda Functions** (`lambda/functions/`)
- ✅ **createTask.ts** - Créer une tâche
  - Validation du titre
  - Extraction userId du JWT Cognito
  - Génération UUID v4 pour taskId
  - Response: 201 Created + Task object

- ✅ **listTasks.ts** - Lister les tâches
  - Query DynamoDB avec `PK = USER#{userId}, SK begins_with TASK#`
  - Response: 200 OK + Array<Task>

- ✅ **updateTask.ts** - Mettre à jour une tâche
  - Valide status (TODO | IN_PROGRESS | DONE | CANCELLED)
  - Updates partiels supportés
  - UpdateExpression généré dynamiquement
  - Response: 200 OK + Updated Task

- ✅ **deleteTask.ts** - Supprimer une tâche
  - Suppression simple via PK+SK
  - Response: 204 No Content

#### **Task Service** (`lambda/shared/taskService.ts`)
- ✅ Interfaces TypeScript : `Task`, `CreateTaskInput`, `UpdateTaskInput`
- ✅ Fonctions exportées : `createTask()`, `getTask()`, `listTasks()`, `updateTask()`, `deleteTask()`
- ✅ Utilise AWS SDK v3 (DynamoDB client)
- ✅ Marshalling/unmarshalling automatique
- ✅ Gestion des erreurs

#### **Configuration Lambda**
- ✅ **package.json** - Dépendances (AWS SDK v3, TypeScript)
- ✅ **tsconfig.json** - Compilation TypeScript stricte (ES2022)

### 📋 Documentation
- ✅ **docs/IMPLEMENTATION_GUIDE_J8_J9.md** - Guide détaillé
  - Résumé des schémas DynamoDB/Lambda/API
  - Commandes de déploiement complet
  - Exemples curl pour test des endpoints
  - Notes de sécurité et coûts estimés

### 🔄 Reasoning

**Pourquoi Single-Table Design ?**
- Simpler à maintenir (1 table = 1 facture)
- Query patterns couverts par PK+SK
- Scalabilité massive (on-demand)
- Plus facile à versioner avec Terraform

**Pourquoi HTTP API vs REST API ?**
- Coût réduit (70% moins cher)
- Performance similaire
- Tout ce qu'il faut pour nos use-cases

**Pourquoi TypeScript pour Lambda ?**
- Type safety + refactoring safer
- Meilleure DX avec IDE
- Compilation stricte (noImplicitAny, strictNullChecks)
- Generated types avec AWS SDK v3

### ⚠️ Points d'attention

- [ ] JWT Cognito Authorizer à configurer sur API GW (J10-J11)
- [ ] Cognito User Pool à créer (J10-J11)
- [ ] Frontend integration des endpoints API (J12-J14)
- [ ] Rate limiting/throttling à ajouter (J20-J21)
- [ ] Tests unitaires Lambda (min 5 par fonction)

---

## [v0.1.1] - 2026-03-31 - Documentation Cleanup & Roadmap Integration

### 🎯 Updates
Documentation cleanup and preparation for J5-J7 (Lambda Hello World + API Gateway).

### 📦 Changes (Frontend)
- ✅ README.md - Completely rewritten for clarity
- ✅ DOCS/NEXT_STEPS.md - NEW (J5-J7 roadmap)
- ✅ DOCS/PROJECT_STRUCTURE.md - Updated file index

---

## [v0.1.0] - 2026-03-29 - Frontend Bootstrap Complete

### 🎯 Objective
Complete frontend bootstrap with React Router, ESLint configuration, production-ready component skeleton.

### 📦 Changes (Frontend)
- ✅ Vite + React 19 + TypeScript setup
- ✅ React Router v6 for navigation
- ✅ ESLint + Prettier configuration
- ✅ Tailwind CSS setup
- ✅ Component skeleton (Header, Footer, Layout, HomePage)

### ✅ Phase 1 Completed (J1-J7)
- ✅ AWS account + AWS CLI configured
- ✅ Terraform installed
- ✅ Frontend bootstrap (Vite + React + Router)
- ✅ Lambda health-check deployed
- ✅ API Gateway HTTP API created

---

## 🔗 Related Documentation

- **[ROADMAP.md](ROADMAP.md)** — 30-day project roadmap with weekly milestones
- **[docs/dynamodb-schema.md](docs/dynamodb-schema.md)** — DynamoDB table schema & patterns
- **[docs/IMPLEMENTATION_GUIDE_J8_J9.md](docs/IMPLEMENTATION_GUIDE_J8_J9.md)** — Detailed J8-J9 implementation guide
- **[taskflow-frontend/DOCS/CHANGELOG.md](taskflow-frontend/DOCS/CHANGELOG.md)** — Frontend-specific changelog

