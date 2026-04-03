# 🔐 Cognito & JWT Authorization Setup Guide (J10-J11)

**Prochaine phase:** Semaine 2 Phase 2 — Authentication  
**Durée estimée:** 2-3 jours (J10-J11)  
**Dépendances:** Phase 1 terminée (DynamoDB + Lambda CRUD + API Gateway)

---

## 🎯 Objectif

Ajouter l'authentification Cognito JWT à l'API Gateway pour sécuriser les endpoints CRUD. Tous les appels à `/tasks` nécessiteront un token JWT valide.

---

## 📋 Checklist Cognito Setup

### 1. **Créer le Cognito User Pool** (AWS Console)

```bash
# Alternatively, via Terraform (voir infra/cognito.tf à créer)
AWS Console → Cognito → Create user pool
```

**Configuration recommandée :**
- **Name :** `TaskFlow-UserPool`
- **MFA :** Optional (production: Required)
- **User attributes :**
  - ✅ Email (Required)
  - ✅ Email verified
  - ✅ Given name (Optional)
  - ✅ Family name (Optional)

### 2. **Créer une Cognito App Client**

**Configuration :**
- **App client name :** `taskflow-web`
- **Redirect URIs (after signup/login) :**
  - `http://localhost:3000/auth-callback` (dev)
  - `https://d111111abcdef8.cloudfront.net/auth-callback` (production - CloudFront URL)
- **Post logout redirect URIs :**
  - `http://localhost:3000/` (dev)
  - `https://d111111abcdef8.cloudfront.net/` (production)
- **Allowed OAuth scopes :**
  - ✅ openid
  - ✅ email
  - ✅ profile
- **Auth flows :**
  - ✅ Allow user password auth (ALLOW_USER_PASSWORD_AUTH)
  - ✅ Allow admin user password auth (ALLOW_ADMIN_USER_PASSWORD_AUTH)
  - ✅ Allow refresh token based auth (ALLOW_REFRESH_TOKEN_AUTH)

**Outputs à conserver :**
- `User Pool ID` (ex: `eu-west-3_abc123def`)
- `Client ID` (ex: `1a2b3c4d5e6f7g8h9i0j`)
- `User Pool Domain` (ex: `taskflow-auth.auth.eu-west-3.amazoncognito.com`)

### 3. **Ajouter JWT Authorizer à API Gateway** (Terraform)

À implémenter dans `infra/cognito.tf` :

```hcl
# Cognito Authorizer
resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  api_id          = aws_apigatewayv2_api.taskflow_api.id
  authorizer_type = "JWT"
  name            = "taskflow-cognito-authorizer"

  identity_source = "$request.header.Authorization"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.taskflow_web.id]
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.taskflow.id}"
  }
}

# Mise à jour des routes avec l'authorizer
resource "aws_apigatewayv2_route" "create_task_route" {
  # ...
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_authorizer.id
}
```

### 4. **Frontend : Implémenter l'Auth** (React)

**Installation :**
```bash
cd taskflow-frontend
npm install @aws-amplify/auth @aws-amplify/core
# ou
npm install amazon-cognito-identity-js
```

**Configuration Amplify (`src/lib/auth.ts`) :**
```typescript
import { Amplify } from '@aws-amplify/core';
import { signIn, signUp, confirmSignUp, signOut } from '@aws-amplify/auth';

Amplify.configure({
  Auth: {
    region: 'eu-west-3',
    userPoolId: process.env.REACT_APP_COGNITO_USER_POOL_ID!,
    userPoolWebClientId: process.env.REACT_APP_COGNITO_CLIENT_ID!,
    identityPoolId: process.env.REACT_APP_COGNITO_IDENTITY_POOL_ID!,
    domain: process.env.REACT_APP_COGNITO_DOMAIN!,
    redirectSignIn: `${window.location.origin}/auth-callback`,
    redirectSignOut: window.location.origin,
  },
});

export async function login(email: string, password: string) {
  const result = await signIn({ username: email, password });
  return result;
}

export async function register(email: string, password: string) {
  await signUp({
    username: email,
    password,
    attributes: { email },
  });
}

export async function confirmSignUpCode(email: string, code: string) {
  await confirmSignUp({ username: email, confirmationCode: code });
}

export async function logout() {
  await signOut();
}
```

**Pages à créer :**

- **`src/pages/LoginPage.tsx`**
  - Form avec email + password
  - Appel à `login()`
  - Stockage du token dans localStorage
  - Redirection vers HomePage

- **`src/pages/SignupPage.tsx`**
  - Form d'inscription (email, password, nom, prénom)
  - Appel à `register()`
  - Étape de confirmation du code (email)
  - Redirection vers LoginPage

- **`src/pages/AuthCallbackPage.tsx`**
  - Redirection post-login depuis Cognito
  - Récupère le token JWT
  - Stocke le token
  - Redirection vers `/tasks`

### 5. **Frontend : Ajouter le token JWT aux requêtes API** (`src/lib/api.ts`)

```typescript
import axios, { AxiosInstance } from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_ENDPOINT || 'https://xxxxx.lambda-url.eu-west-3.on.aws';

function getAuthToken(): string | null {
  return localStorage.getItem('jwtToken');
}

const apiClient: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor pour ajouter le token JWT à chaque requête
apiClient.interceptors.request.use(
  (config) => {
    const token = getAuthToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Appels API
export const taskApi = {
  createTask: (data) => apiClient.post('/tasks', data),
  listTasks: () => apiClient.get('/tasks'),
  updateTask: (taskId, data) => apiClient.put(`/tasks/${taskId}`, data),
  deleteTask: (taskId) => apiClient.delete(`/tasks/${taskId}`),
};
```

### 6. **Frontend : Protéger les routes** (React Router)

```typescript
// src/components/ProtectedRoute.tsx
import { Navigate } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { getCurrentUser } from '@aws-amplify/auth';

interface ProtectedRouteProps {
  children: React.ReactNode;
}

export function ProtectedRoute({ children }: ProtectedRouteProps) {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function checkAuth() {
      try {
        await getCurrentUser();
        setIsAuthenticated(true);
      } catch {
        setIsAuthenticated(false);
      } finally {
        setLoading(false);
      }
    }

    checkAuth();
  }, []);

  if (loading) return <div>Loading...</div>;
  
  return isAuthenticated ? <>{children}</> : <Navigate to="/login" />;
}

// Usage dans App.tsx
<Route path="/tasks" element={<ProtectedRoute><TasksPage /></ProtectedRoute>} />
```

---

## 🧪 Test des endpoints

### 1. **Obtenir un token Cognito**

```bash
# Via AWS CLI
aws cognito-idp admin-initiate-auth \
  --user-pool-id eu-west-3_abc123def \
  --client-id 1a2b3c4d5e6f7g8h9i0j \
  --auth-flow ADMIN_NO_SRP_AUTH \
  --auth-parameters USERNAME=demo@taskflow.com,PASSWORD=Demo123! \
  --region eu-west-3
```

**Response :**
```json
{
  "AuthenticationResult": {
    "AccessToken": "eyJhbGc...",
    "IdToken": "eyJhbGc...",
    "RefreshToken": "...",
    "ExpiresIn": 3600,
    "TokenType": "Bearer"
  }
}
```

### 2. **Tester un endpoint CRUD protégé**

```bash
# Copier le token depuis la réponse
TOKEN="eyJhbGc..."

# Créer une tâche
curl -X POST https://xxxxx.lambda-url.eu-west-3.on.aws/tasks \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Première tâche",
    "description": "Test avec JWT",
    "dueDate": "2025-04-15"
  }'

# Lister les tâches
curl -X GET https://xxxxx.lambda-url.eu-west-3.on.aws/tasks \
  -H "Authorization: Bearer $TOKEN"
```

### 3. **Tester sans token (devrait retourner 401)**

```bash
curl -X GET https://xxxxx.lambda-url.eu-west-3.on.aws/tasks
# Response: {"message":"Unauthorized"}
```

---

## 🔐 Sécurité — Points clés

✅ **À implémenter :**
- Token JWT stocké dans `localStorage` (accessible au frontend)
- Expiration du token : 1h (force la reconnexion régulière)
- Refresh token pour prolonger la session
- HTTPS/CORS pour éviter les attaques XSS/CSRF
- Validation du token côté API Gateway

⚠️ **À considérer :**
- Stocker les tokens dans les cookies `httpOnly` (plus sécurisé que localStorage)
- Implémenter un logout côté frontend (effacer le token)
- Gérer les erreurs 401/403 et rediriger vers login

---

## 📊 Fichiers à créer/modifier

```
taskflow-frontend/
├── src/
│   ├── lib/
│   │   ├── auth.ts           ← NEW: Cognito auth functions
│   │   └── api.ts            ← MODIFY: Ajouter JWT header
│   ├── pages/
│   │   ├── LoginPage.tsx      ← NEW: Login form
│   │   ├── SignupPage.tsx     ← NEW: Signup form
│   │   ├── AuthCallbackPage.tsx ← NEW: OAuth callback
│   │   ├── HomePage.tsx       ← MODIFY: Protéger la route
│   │   └── TasksPage.tsx      ← NEW: CRUD UI
│   ├── components/
│   │   └── ProtectedRoute.tsx ← NEW: Route guard
│   └── App.tsx                ← MODIFY: Ajouter les routes auth
├── .env.local                 ← NEW: Variables d'env Cognito
└── package.json               ← MODIFY: Ajouter Amplify

infra/
├── cognito.tf                 ← NEW: Cognito User Pool + Authorizer
└── api_gateway.tf             ← MODIFY: Ajouter JWT authorizer aux routes
```

---

## ⏱️ Timeline

| Jour | Tâche | Durée |
|------|-------|-------|
| J10 - Matin | Créer Cognito User Pool + App Client | 30 min |
| J10 - Midi | Créer `infra/cognito.tf` + déployer | 1h |
| J10 - Après-midi | Ajouter JWT Authorizer API Gateway | 1h |
| J11 - Matin | Implémenter LoginPage + SignupPage | 2h |
| J11 - Midi | Intégrer tokens JWT dans les appels API | 1h |
| J11 - Après-midi | Tester workflow complet (signup → login → CRUD) | 1h |

---

## 🔗 Ressources

- [AWS Cognito Console](https://console.aws.amazon.com/cognito/)
- [AWS Amplify Auth Docs](https://docs.amplify.aws/lib/auth/getting-started/)
- [JWT.io — Debug tokens](https://jwt.io/)
- [AWS SDK Cognito Types](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/Package/-aws-sdk-client-cognito-identity-provider/)

---

## ✅ Validation — End of J11

- [ ] Cognito User Pool créé + test de signup/login réussi
- [ ] JWT Authorizer configuré sur API Gateway
- [ ] Frontend LoginPage et SignupPage fonctionnels
- [ ] Appels CRUD depuis le frontend réussissent avec JWT
- [ ] Appels sans JWT retournent 401 Unauthorized
- [ ] Token stocké dans localStorage et envoyé dans les headers
- [ ] Logout fonctionne et efface le token

