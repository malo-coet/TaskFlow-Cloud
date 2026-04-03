# 📋 Implementation Guide — DynamoDB & Lambda CRUD (J8-J9)

**Date:** 2 Avril 2026  
**Phase:** Semaine 2 — CRUD & Authentification (J8-J9)  
**Status:** ✅ Completed

---

## 🎯 Résumé des étapes complétées

### 1. **DynamoDB Table Schema** (`infra/dynamodb.tf`)

La table **TaskFlow-Tasks** a été créée avec le pattern Single-Table Design :

```
PK: USER#{userId}  (Partition Key)
SK: TASK#{taskId}  (Sort Key)
```

**Attributs principaux :**
- `taskId`: UUID unique de la tâche
- `userId`: ID Cognito de l'utilisateur
- `title`: Titre de la tâche (requis)
- `description`: Description optionnelle
- `status`: TODO | IN_PROGRESS | DONE | CANCELLED
- `dueDate`: Date d'échéance (ISO 8601)
- `tags`: Liste d'étiquettes
- `createdAt`, `updatedAt`: Timestamps

**GSI (Global Secondary Indexes) :**
- **GSI-Status**: `userId` (PK) + `status` (SK) → filtrer par statut
- **GSI-DueDate**: `userId` (PK) + `dueDate` (SK) → trier par date

**Configuration :**
- Billing: `PAY_PER_REQUEST` (On-demand, Free Tier compatible)
- Encryption: Server-side enabled
- PITR: Point-In-Time Recovery enabled
- Streaming: DynamoDB Streams enabled (pour des extensions futures)

---

### 2. **Task Service** (`lambda/shared/taskService.ts`)

Module TypeScript partagé avec les opérations CRUD DynamoDB.

**Fonctions exportées :**

| Fonction | Description | Signature |
|----------|-------------|-----------|
| `createTask()` | Créer une nouvelle tâche | `(input: CreateTaskInput) => Promise<Task>` |
| `getTask()` | Récupérer une tâche par ID | `(userId: string, taskId: string) => Promise<Task \| null>` |
| `listTasks()` | Lister toutes les tâches d'un utilisateur | `(userId: string) => Promise<Task[]>` |
| `updateTask()` | Mettre à jour une tâche | `(input: UpdateTaskInput) => Promise<Task>` |
| `deleteTask()` | Supprimer une tâche | `(userId: string, taskId: string) => Promise<void>` |

**Dépendances :**
- `@aws-sdk/client-dynamodb`: Client DynamoDB v3
- `@aws-sdk/util-dynamodb`: Utilitaires de marshalling/unmarshalling

**Utilitaires :**
- `generateTaskId()`: Génère un UUID v4 pour chaque nouvelle tâche

---

### 3. **Lambda Handlers** (`lambda/functions/`)

Quatre fonctions Lambda (une par opération CRUD) :

#### **createTask.ts** — POST /tasks
```typescript
POST /tasks
Body: { title, description?, dueDate?, tags? }
Response: { taskId, userId, title, ... }
```
- Valide que `title` est présent et non-vide
- Extrait `userId` du token JWT Cognito
- Retourne le statut 201 (Created)

#### **listTasks.ts** — GET /tasks
```typescript
GET /tasks
Response: Task[]
```
- Retourne toutes les tâches de l'utilisateur
- Requête DynamoDB avec `begins_with(SK, "TASK#")`

#### **updateTask.ts** — PUT /tasks/{taskId}
```typescript
PUT /tasks/{taskId}
Body: { title?, description?, status?, dueDate?, tags? }
Response: { taskId, userId, ... (updated task) }
```
- Valide les valeurs de `status` (TODO | IN_PROGRESS | DONE | CANCELLED)
- Utilise DynamoDB `UpdateItemCommand` pour les updates partiels
- Retourne le statut 200 (OK)

#### **deleteTask.ts** — DELETE /tasks/{taskId}
```typescript
DELETE /tasks/{taskId}
Response: (204 No Content)
```
- Supprime la tâche
- Retourne le statut 204 (No Content)

**Gestion des erreurs :**
- `400`: Requête invalide (données manquantes/invalides)
- `401`: Unauthorized (token Cognito invalide/manquant)
- `404`: Task not found
- `500`: Internal Server Error

---

### 4. **Infrastructure Terraform** (`infra/`)

#### **dynamodb.tf** — Table DynamoDB
- Table `TaskFlow-Tasks` avec on-demand billing
- 2 GSI (Status, DueDate)
- Outputs: table name, ARN, stream ARN

#### **lambda.tf** — Lambda Functions & IAM
- IAM Role pour les Lambda fonctions
- 4 Lambda functions (createTask, listTasks, updateTask, deleteTask)
- Policy pour accès DynamoDB (PutItem, GetItem, UpdateItem, DeleteItem, Query, Scan)
- Outputs: ARN de chaque fonction

#### **api_gateway.tf** — HTTP API Gateway
- HTTP API (coût réduit vs REST API)
- 4 routes : POST /tasks, GET /tasks, PUT /tasks/{taskId}, DELETE /tasks/{taskId}
- CORS configuré pour toutes les origines
- Access logs dans CloudWatch
- Lambda permissions pour invocations
- Output: API endpoint URL

---

## 🔧 Commandes de déploiement

### 1. **Installer les dépendances Lambda**
```bash
cd lambda/functions
npm install
cd ../..
```

### 2. **Compiler le TypeScript**
```bash
cd lambda/functions
npm run build
cd ../..
```

### 3. **Packager les Lambda functions**
```bash
cd lambda/functions/dist
for file in *.js; do
  funcname="${file%.js}"
  zip "$funcname.zip" "$funcname.js"
done
cd ../../..
```

### 4. **Initialiser Terraform**
```bash
cd infra
terraform init
```

### 5. **Planifier et appliquer**
```bash
terraform plan
terraform apply
```

### 6. **Récupérer l'endpoint API**
```bash
terraform output api_endpoint
# Output: https://xxxxx.lambda-url.eu-west-3.on.aws
```

---

## 🧪 Test des endpoints

### Exemple : Créer une tâche
```bash
curl -X POST https://xxxxx.lambda-url.eu-west-3.on.aws/tasks \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Implémenter l'\''auth Cognito",
    "description": "Configurer le User Pool",
    "dueDate": "2025-04-15",
    "tags": ["backend", "auth"]
  }'
```

### Exemple : Lister les tâches
```bash
curl -X GET https://xxxxx.lambda-url.eu-west-3.on.aws/tasks \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Exemple : Mettre à jour une tâche
```bash
curl -X PUT https://xxxxx.lambda-url.eu-west-3.on.aws/tasks/018f1a2b-3c4d-7e8f \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "IN_PROGRESS"
  }'
```

### Exemple : Supprimer une tâche
```bash
curl -X DELETE https://xxxxx.lambda-url.eu-west-3.on.aws/tasks/018f1a2b-3c4d-7e8f \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 📁 Structure des fichiers créés

```
TaskFlow/
├── infra/
│   ├── dynamodb.tf          ← Table DynamoDB
│   ├── lambda.tf            ← Lambda functions & IAM
│   ├── api_gateway.tf       ← HTTP API Gateway
│   └── provider.tf          (existing)
│
└── lambda/
    ├── shared/
    │   └── taskService.ts   ← Service partagé CRUD
    ├── functions/
    │   ├── createTask.ts    ← Handler POST /tasks
    │   ├── listTasks.ts     ← Handler GET /tasks
    │   ├── updateTask.ts    ← Handler PUT /tasks/{taskId}
    │   ├── deleteTask.ts    ← Handler DELETE /tasks/{taskId}
    │   ├── package.json
    │   ├── tsconfig.json
    │   └── dist/            (compiled output, gitignored)
    └── health-check/        (existing)
```

---

## ⚠️ Prochaines étapes (J10-J11)

1. **Cognito User Pool** — Créer et configurer Cognito
2. **JWT Authorizer** — Ajouter un authorizer JWT à l'API Gateway
3. **Frontend Integration** — Appeler les endpoints depuis React

---

## 🔐 Notes de sécurité

✅ **Implémentées :**
- IAM least privilege (Lambda ne peut accéder qu'à DynamoDB)
- Extraction du `userId` du token JWT Cognito
- Validation des inputs (title, status, etc.)
- CORS configuré (à restreindre en production)
- Access logs API Gateway

⚠️ **À implémenter :**
- JWT Authorization Cognito sur l'API Gateway
- Throttling API Gateway (rate limiting)
- WAF pour protection DDoS

---

## 📊 Coûts estimés

| Service | Usage | Coût |
|---------|-------|------|
| DynamoDB (on-demand) | ~1000 req/mois | $0.00 (Always Free) |
| Lambda | ~10000 invocations | $0.00 (1M req/mois Free) |
| CloudWatch Logs | ~10 MB/mois | $0.00 (5GB Free) |
| API Gateway HTTP | ~1000 req/mois | $0.00 (Always Free) |
| **Total** | | **$0.00/mois** |

---

## 🎓 Learning Resources

- [AWS SDK for JavaScript v3 — DynamoDB](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/client/dynamodb/)
- [DynamoDB Single-Table Design Pattern](https://www.serverlessland.com/patterns/dynamodb-single-table)
- [API Gateway HTTP API vs REST API](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api.html)
- [Lambda + Terraform Guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)

