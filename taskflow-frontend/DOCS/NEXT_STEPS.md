# 📋 NEXT_STEPS.md — Étapes J5-J7 (Lambda Hello World + API Gateway)

**Date :** 31 Mars 2026  
**Phase :** Semaine 1 J5-J7  
**Durée :** 3 jours  
**Objectif :** Backend "hello world" déployé et connecté au frontend

---

## 🎯 Vue d'ensemble

Cette semaine, nous allons :

1. **J5-J6** : Créer une Lambda Node.js + API Gateway HTTP API
2. **J7** : Frontend integration (appeler la Lambda depuis React)

À la fin de cette semaine, vous aurez :
- ✅ Une Lambda `health-check` opérationnelle
- ✅ Un API Gateway HTTP API déployé manuellement
- ✅ Une intégration frontend fonctionnelle
- ✅ Le schéma DynamoDB défini (pour la semaine 2)

---

## 📊 J5-J6 : Lambda Hello World + API Gateway

### Étape 1 : Créer la Lambda `health-check`

**Objectif :** Une fonction Node.js qui retourne `{ status: "ok" }` sur `/health`

#### 1.1. Créer la structure de dossiers

```bash
# À la racine de TaskFlow
mkdir -p lambda/health-check
cd lambda/health-check
npm init -y
npm install aws-lambda-powertools
```

#### 1.2. Créer le handler Lambda

Fichier : `lambda/health-check/handler.js`

```javascript
/**
 * Health Check Lambda Handler
 * Endpoint: GET /health
 * Response: { status: "ok" }
 */

export const handler = async (event) => {
  console.log('Health check request:', event);

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*', // À remplacer par votre domaine CloudFront
    },
    body: JSON.stringify({
      status: 'ok',
      timestamp: new Date().toISOString(),
      region: process.env.AWS_REGION || 'unknown',
    }),
  };
};
```

**Pourquoi ça ?**
- `statusCode: 200` → HTTP 200 OK
- `headers` → Retourner du JSON + CORS
- `body` → JSON stringifié (Lambda le parse)
- `timestamp` → Preuve que le serveur fonctionne
- `region` → Montre qu'on est sur AWS

#### 1.3. Créer le package.json

Fichier : `lambda/health-check/package.json`

```json
{
  "name": "health-check-lambda",
  "version": "1.0.0",
  "type": "module",
  "main": "handler.js",
  "scripts": {
    "test": "node --test handler.test.js"
  },
  "dependencies": {}
}
```

**Pourquoi ?**
- `"type": "module"` → Utiliser ES6 imports
- `"main": "handler.js"` → Point d'entrée Lambda

---

### Étape 2 : Déployer la Lambda manuellement sur AWS

**Outils :** AWS Console ou AWS CLI

#### Option A : Avec AWS CLI (recommandé)

```bash
# 1. Créer un rôle IAM pour Lambda
aws iam create-role \
  --role-name TaskFlowLambdaRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  }'

# 2. Attacher la politique d'exécution basique
aws iam attach-role-policy \
  --role-name TaskFlowLambdaRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# 3. Zipper le code
cd lambda/health-check
zip -r function.zip .
cd ../../

# 4. Créer la Lambda
aws lambda create-function \
  --function-name taskflow-health-check \
  --runtime nodejs20.x \
  --role arn:aws:iam::ACCOUNT_ID:role/TaskFlowLambdaRole \
  --handler handler.handler \
  --zip-file fileb://lambda/health-check/function.zip \
  --region eu-west-3
```

⚠️ **Remplacer `ACCOUNT_ID`** par votre AWS Account ID (trouver avec `aws sts get-caller-identity`)

#### Option B : Via AWS Console

1. Aller sur [AWS Lambda Console](https://console.aws.amazon.com/lambda/)
2. Cliquer **"Create Function"**
3. Remplir :
   - **Function Name :** `taskflow-health-check`
   - **Runtime :** `Node.js 20.x`
   - **Role :** `TaskFlowLambdaRole` (créer si nécessaire)
4. Copier-coller le code de `handler.js` dans l'éditeur
5. Cliquer **"Deploy"**

---

### Étape 3 : Configurer API Gateway HTTP API

**Objectif :** Exposer la Lambda sur un endpoint public

#### Option A : Avec AWS CLI

```bash
# 1. Créer l'API Gateway HTTP API
API_ID=$(aws apigatewayv2 create-api \
  --name taskflow-api \
  --protocol-type HTTP \
  --target arn:aws:lambda:eu-west-3:ACCOUNT_ID:function:taskflow-health-check \
  --query 'ApiId' \
  --output text \
  --region eu-west-3)

echo "API ID: $API_ID"

# 2. Créer un stage (environment)
STAGE_URL=$(aws apigatewayv2 create-stage \
  --api-id $API_ID \
  --stage-name dev \
  --auto-deploy \
  --query 'InvokeUrl' \
  --output text \
  --region eu-west-3)

echo "API URL: $STAGE_URL/health"
```

#### Option B : Via AWS Console

1. Aller sur [API Gateway Console](https://console.aws.amazon.com/apigatewayv2/)
2. Cliquer **"Create API"** → **"HTTP API"**
3. Remplir :
   - **API Name :** `taskflow-api`
   - **Integration :** Sélectionner la Lambda `taskflow-health-check`
4. Cliquer **"Create"**
5. Aller à **Stages** → **$default** → Copier l'**Invoke URL**

**URL finale :** `https://xxxxxxx.execute-api.eu-west-3.amazonaws.com/dev/health`

---

### Étape 4 : Tester l'endpoint avec Hoppscotch

1. Ouvrir [Hoppscotch](https://hoppscotch.io/)
2. Créer une requête :
   - **Method :** `GET`
   - **URL :** `https://xxxxxxx.execute-api.eu-west-3.amazonaws.com/dev/health`
3. Cliquer **"Send"**
4. Vérifier la réponse :
   ```json
   {
     "status": "ok",
     "timestamp": "2026-03-31T10:30:00.000Z",
     "region": "eu-west-3"
   }
   ```

✅ Si vous voyez cette réponse, la Lambda fonctionne !

---

### Étape 5 : Définir le schéma DynamoDB

**Fichier :** `docs/dynamodb-schema.md`

Créer ce fichier avec le schéma des tâches :

```markdown
# DynamoDB Schema - TaskFlow

## Table: Tasks

### Partition Key (PK)
- **Name :** `userId`
- **Type :** String
- **Example :** `user@example.com`

### Sort Key (SK)
- **Name :** `taskId`
- **Type :** String
- **Example :** `task-001-uuid`

### Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `userId` | String (PK) | Email de l'utilisateur |
| `taskId` | String (SK) | UUID de la tâche |
| `title` | String | Titre de la tâche |
| `description` | String | Description (optionnel) |
| `status` | String | `TODO`, `IN_PROGRESS`, `DONE` |
| `dueDate` | String (ISO8601) | Date d'échéance (optionnel) |
| `tags` | List | Liste de tags (ex: `["urgent", "work"]`) |
| `createdAt` | String (ISO8601) | Timestamp création |
| `updatedAt` | String (ISO8601) | Timestamp modification |

### GSI (Global Secondary Index)

**GSI: statusIndex**
- **PK :** `status` (String)
- **SK :** `updatedAt` (String)
- **Projection :** ALL
- **Purpose :** Lister les tâches par statut

### Example Item

\`\`\`json
{
  "userId": "user@example.com",
  "taskId": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Implémenter API CRUD",
  "description": "Créer Lambda functions pour CRUD",
  "status": "IN_PROGRESS",
  "dueDate": "2026-04-10T23:59:59Z",
  "tags": ["backend", "urgent"],
  "createdAt": "2026-03-31T10:00:00Z",
  "updatedAt": "2026-03-31T10:30:00Z"
}
\`\`\`

### Rationale

- **PK: userId** → Trouver rapidement toutes les tâches d'un utilisateur
- **SK: taskId** → Identifier uniquement chaque tâche
- **GSI: statusIndex** → Requêtes globales par statut (ex: "afficher toutes les tâches IN_PROGRESS")
```

**Pourquoi cette structure ?**
- **Single-table design** → Optimisé pour les requêtes courantes
- **GSI pour status** → Permet des requêtes globales (ex: "afficher toutes les tâches urgentes")
- **Timestamps** → Audit trail et tri par date

---

## 📊 J7 : Frontend Integration

### Étape 1 : Créer un service API

**Fichier :** `taskflow-frontend/src/lib/api.ts`

```typescript
/**
 * API Service - TaskFlow
 * Centralise tous les appels aux Lambda functions
 */

const API_URL = import.meta.env.VITE_API_URL || 'https://xxxxxxx.execute-api.eu-west-3.amazonaws.com/dev';

export interface HealthResponse {
  status: string;
  timestamp: string;
  region: string;
}

/**
 * Appeler l'endpoint /health
 */
export async function checkHealth(): Promise<HealthResponse> {
  try {
    const response = await fetch(`${API_URL}/health`);
    
    if (!response.ok) {
      throw new Error(`Health check failed: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('Health check error:', error);
    throw error;
  }
}
```

**Pourquoi ?**
- `import.meta.env.VITE_API_URL` → Charger l'URL depuis `.env`
- `fetch` → Appel HTTP standard
- `throw` → Propager les erreurs

### Étape 2 : Créer le fichier `.env`

**Fichier :** `taskflow-frontend/.env`

```bash
VITE_API_URL=https://xxxxxxx.execute-api.eu-west-3.amazonaws.com/dev
```

### Étape 3 : Intégrer dans HomePage

**Fichier :** `taskflow-frontend/src/pages/HomePage.tsx`

```typescript
import { useState, useEffect } from 'react';
import { checkHealth, type HealthResponse } from '../lib/api';

export default function HomePage() {
  const [health, setHealth] = useState<HealthResponse | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleCheckHealth = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await checkHealth();
      setHealth(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // Vérifier la santé au chargement
    handleCheckHealth();
  }, []);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100">
      <h1 className="text-4xl font-bold text-gray-900 mb-4">
        🚀 Welcome to TaskFlow
      </h1>
      
      <div className="bg-white p-8 rounded-lg shadow-lg max-w-md w-full">
        <h2 className="text-2xl font-semibold mb-4 text-gray-800">Backend Status</h2>
        
        {loading && <p className="text-blue-600">Checking backend...</p>}
        
        {error && (
          <div className="bg-red-100 text-red-700 p-4 rounded mb-4">
            ❌ Error: {error}
          </div>
        )}
        
        {health && (
          <div className="bg-green-100 text-green-700 p-4 rounded mb-4">
            ✅ Status: {health.status}
            <p className="text-sm mt-2">Region: {health.region}</p>
            <p className="text-sm">Time: {new Date(health.timestamp).toLocaleString()}</p>
          </div>
        )}
        
        <button
          onClick={handleCheckHealth}
          disabled={loading}
          className="w-full bg-indigo-600 text-white py-2 rounded hover:bg-indigo-700 disabled:bg-gray-400"
        >
          {loading ? 'Checking...' : 'Check Backend'}
        </button>
      </div>
    </div>
  );
}
```

### Étape 4 : Tester dans le navigateur

```bash
# 1. Mettre à jour .env avec votre URL
# 2. Lancer le serveur
npm run dev

# 3. Ouvrir http://localhost:5173
# 4. Cliquer "Check Backend"
# 5. Voir la réponse s'afficher
```

✅ Si la réponse s'affiche, l'intégration fonctionne !

---

## ✅ Checklist J5-J7

### J5 Matin
- [ ] Créer la Lambda `health-check`
- [ ] Tester localement avec Node.js
- [ ] Déployer sur AWS

### J5 Après-midi
- [ ] Créer API Gateway HTTP API
- [ ] Obtenir l'URL publique
- [ ] Tester avec Hoppscotch

### J6
- [ ] Définir le schéma DynamoDB (docs/dynamodb-schema.md)
- [ ] Réviser les patterns (single-table, GSI)
- [ ] Planifier les CRUD Lambda functions

### J7 Matin
- [ ] Créer `lib/api.ts`
- [ ] Ajouter `.env`
- [ ] Intégrer dans HomePage

### J7 Après-midi
- [ ] Tester l'intégration end-to-end
- [ ] Vérifier les error cases (offline, timeout)
- [ ] Committer le code

---

## 🔧 Ressources utiles

| Ressource | Lien |
|-----------|------|
| **AWS Lambda Docs** | https://docs.aws.amazon.com/lambda/ |
| **API Gateway HTTP API** | https://docs.aws.amazon.com/apigatewayv2/ |
| **Node.js Lambda Runtime** | https://docs.aws.amazon.com/lambda/latest/dg/lambda-nodejs.html |
| **Hoppscotch** | https://hoppscotch.io/ |
| **DynamoDB Single Table Design** | https://www.youtube.com/watch?v=I1_XvV4Q1bE |

---

## 💡 Tips importants

✅ **À faire :**
- Tester la Lambda localement avant de la déployer
- Garder les logs AWS CloudWatch ouverts pour déboguer
- Utiliser des variables d'environnement pour l'URL API
- Committer le code Lambda dans le repo

❌ **À éviter :**
- Hardcoder l'URL API dans le code React
- Oublier le CORS (`Access-Control-Allow-Origin`)
- Déployer sans tester avec Hoppscotch
- Ignorer les erreurs TypeScript

---

## 🚀 Prochaine étape (Semaine 2)

Une fois J7 terminé, vous pourrez passer à la **Semaine 2** :

1. **Créer les Lambda CRUD** (CREATE, READ, UPDATE, DELETE, LIST)
2. **Ajouter Cognito** pour l'authentification
3. **Intégrer le CRUD frontend**

Bon courage ! 🎉

---

**Generated :** 31 Mars 2026  
**Project :** TaskFlow Cloud  
**Phase :** Semaine 1 J5-J7  
**Status :** Ready to go ✅

