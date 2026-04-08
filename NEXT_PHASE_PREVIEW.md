# 🎬 Next Phase Preview - J12-J14 Frontend CRUD UI

After you commit v0.3.0, here's what's next.

---

## 🎯 Phase J12-J14 Goals

- [ ] Create Login page (form + cognito signIn)
- [ ] Create Signup page (form + cognito signUp)
- [ ] Create Task list page (API GET /tasks + JWT)
- [ ] Create Task form (API POST /tasks + JWT)
- [ ] Create Edit task page (API PUT /tasks/{id})
- [ ] Create Delete button (API DELETE /tasks/{id})
- [ ] Add error handling + loading states
- [ ] Add unit tests for Lambda functions

---

## 📝 Files to Create/Update

### Frontend Pages

**`taskflow-frontend/src/pages/LoginPage.tsx`**
```typescript
import { signIn } from '../lib/auth';

export function LoginPage() {
  const handleSubmit = async (email, password) => {
    try {
      await signIn(email, password);
      // Redirect to /tasks
    } catch (error) {
      // Show error
    }
  };
  // JSX: email + password form
}
```

**`taskflow-frontend/src/pages/SignupPage.tsx`**
```typescript
import { signUp, confirmSignUp } from '../lib/auth';

export function SignupPage() {
  // 1. Email + password form
  // 2. Confirmation code form
}
```

**`taskflow-frontend/src/pages/TasksPage.tsx`**
```typescript
import { getJWTToken } from '../lib/auth';

export function TasksPage() {
  // List tasks (GET /tasks with JWT)
  // Create task button → TaskFormModal
}
```

**`taskflow-frontend/src/pages/TaskFormPage.tsx`** or Modal
```typescript
// POST /tasks or PUT /tasks/{id}
```

---

## 🔧 Implementation Steps

### Step 1: Update Router
```typescript
// src/App.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { LoginPage } from './pages/LoginPage';
import { SignupPage } from './pages/SignupPage';
import { TasksPage } from './pages/TasksPage';
import { ProtectedRoute } from './components/ProtectedRoute';

export function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/signup" element={<SignupPage />} />
        <Route
          path="/tasks"
          element={<ProtectedRoute><TasksPage /></ProtectedRoute>}
        />
      </Routes>
    </BrowserRouter>
  );
}
```

### Step 2: Create ProtectedRoute Component
```typescript
// src/components/ProtectedRoute.tsx
import { Navigate } from 'react-router-dom';
import { getCurrentUser } from '../lib/auth';

export function ProtectedRoute({ children }) {
  const user = getCurrentUser();
  if (!user) return <Navigate to="/login" />;
  return children;
}
```

### Step 3: Update API Client
```typescript
// src/lib/api.ts
import { getJWTToken } from './auth';

export async function createTask(task) {
  const jwt = await getJWTToken();
  return fetch(`${API_URL}/tasks`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${jwt}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(task)
  });
}

// Similar for listTasks, updateTask, deleteTask
```

---

## 🧪 Testing Lambda Functions

Create test files:

**`lambda/functions/__tests__/createTask.test.ts`**
```typescript
import { handler } from '../createTask';

describe('createTask', () => {
  it('should create task with valid JWT', async () => {
    const event = {
      headers: { authorization: 'Bearer <VALID_JWT>' },
      body: JSON.stringify({ title: 'Test' })
    };
    const result = await handler(event);
    expect(result.statusCode).toBe(201);
  });

  it('should reject without JWT', async () => {
    const event = { body: JSON.stringify({ title: 'Test' }) };
    const result = await handler(event);
    expect(result.statusCode).toBe(401);
  });
});
```

**Run tests:**
```bash
cd lambda/functions/
npm test  # Uses Jest/Vitest
```

---

## 📋 UI Wireframe (Simple)

```
┌─────────────────────────────┐
│     TaskFlow                 │
├─────────────────────────────┤
│ [Login] [Signup] [Logout]   │  ← Navigation (if logged in)
├─────────────────────────────┤
│ 📋 My Tasks                  │
│                              │
│ [New Task]                   │
│                              │
│ ✓ Learn Terraform           │  Done
│   [Edit] [Delete]            │
│                              │
│ ⏳ Build Frontend            │  In Progress
│   [Edit] [Delete]            │
│                              │
│ ○ Write tests               │  TODO
│   [Edit] [Delete]            │
└─────────────────────────────┘
```

---

## 🎨 Component Structure

```
App.tsx
├── Header.tsx (logo + logout button)
├── Layout.tsx (wrapper)
├── pages/
│   ├── LoginPage.tsx
│   ├── SignupPage.tsx
│   └── TasksPage.tsx
│       ├── TaskList.tsx
│       └── TaskForm.tsx (modal or separate page)
└── components/
    ├── ProtectedRoute.tsx
    ├── TaskCard.tsx
    ├── TaskForm.tsx
    ├── ErrorBoundary.tsx
    └── LoadingSpinner.tsx
```

---

## 🔑 Key Patterns

### Pattern 1: Get JWT + Make API Call
```typescript
const jwt = await getJWTToken();
const response = await fetch(`${API_URL}/tasks`, {
  headers: { 'Authorization': `Bearer ${jwt}` }
});
```

### Pattern 2: Handle Auth Errors
```typescript
try {
  await signIn(email, password);
} catch (error) {
  if (error.code === 'UserNotConfirmedException') {
    // Show confirmation code form
  }
  if (error.code === 'InvalidPasswordException') {
    // Show password error
  }
}
```

### Pattern 3: Refresh Token on Expiry
```typescript
async function makeAuthedRequest(url, options) {
  let jwt = await getJWTToken();
  let response = await fetch(url, {
    headers: { 'Authorization': `Bearer ${jwt}` },
    ...options
  });
  
  if (response.status === 401) {
    // Token expired, refresh
    jwt = await refreshToken();
    response = await fetch(url, {
      headers: { 'Authorization': `Bearer ${jwt}` },
      ...options
    });
  }
  
  return response;
}
```

---

## 📚 Resources

- **AWS Amplify Docs:** https://docs.amplify.aws/lib/auth/
- **React Hook Form:** https://react-hook-form.com/ (for forms)
- **TanStack Query:** https://tanstack.com/query/ (for data fetching)
- **Jest:** https://jestjs.io/ (for testing)

---

## 📅 Estimated Timeline

- **Day 1:** Router + pages structure
- **Day 2:** Login/Signup implementation
- **Day 3:** Task CRUD UI
- **Day 4:** Error handling + UX polish
- **Day 5:** Lambda tests
- **Day 6-7:** QA + bug fixes

---

## 🎯 Definition of Done (J12-J14)

- [ ] Can login with Cognito
- [ ] Can create/list/update/delete tasks in UI
- [ ] All API calls include JWT
- [ ] Errors show user-friendly messages
- [ ] Loading states displayed during requests
- [ ] At least 1 test per Lambda function
- [ ] README updated with frontend setup
- [ ] .env.example filled with real values

---

## 🚀 Start Template

```bash
# When you're ready to start J12-J14:

cd taskflow-frontend/

# Create new pages
touch src/pages/LoginPage.tsx
touch src/pages/SignupPage.tsx
touch src/pages/TasksPage.tsx

# Create components
touch src/components/ProtectedRoute.tsx
touch src/components/TaskCard.tsx
touch src/components/TaskForm.tsx

# Then start coding! Use auth.ts functions from lib/
```

---

**See:** [ROADMAP.md](ROADMAP.md) for full timeline  
**Docs:** [README.md](README.md) for architecture  
**Ready for:** Phase J12-J14 after v0.3.0 commit ✅

