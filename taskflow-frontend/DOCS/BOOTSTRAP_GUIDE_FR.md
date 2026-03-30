# 🎓 Guide Complet - Bootstrap Frontend TaskFlow

**Date:** 29 Mars 2026  
**Statut:** ✅ Bootstrap Terminé  
**Prochaine étape:** CRUD & Authentification  

---

## 📖 Table des matières

1. [Résumé exécutif](#résumé-exécutif)
2. [Étapes réalisées](#étapes-réalisées)
3. [Explication architecturale](#explication-architecturale)
4. [Configuration ESLint + Prettier](#configuration-eslint--prettier)
5. [Comprendre React Router](#comprendre-react-router)
6. [Structure des composants](#structure-des-composants)
7. [Sécurité et CVE](#sécurité-et-cve)
8. [Commandes utiles](#commandes-utiles)

---

## Résumé exécutif

### Qu'est ce qui à été réalisé :

Un **squelette React minimal** (CRUD + Authentification).

**Qu'est ce qui marche ? :**
- 🌍 Page d'accueil, petit bouton intéractif
- 🔀 Routing avec React Router (navigation sans rechargement)
- ✨ ESLint + Prettier
- 🎨 Tailwind CSS
- 🔒 TypeScript strict
- 🧪 Build optimisé (234 KB JS, 74 KB gzippé)

**Zéro vulnérabilité :** 351 packages audités, 0 CVE trouvée ✅

---

## Étapes réalisées

### 1️⃣ Configuration des dépendances

**Pourquoi ?**  
Comme Vite était déjà là avec React Router, il fallait ajouter les outils (Prettier, eslint-plugin-react).

**Fichier modifié :** `package.json`

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "lint": "eslint . --fix",        // ← NOUVEAU : auto-fix
    "format": "prettier --write ...", // ← NOUVEAU : format
    "type-check": "tsc --noEmit",    // ← NOUVEAU : check TS
    "preview": "vite preview"
  },
  "devDependencies": {
    // ...existant...
    "@types/react-router-dom": "^5.3.3",  // ← NOUVEAU
    "eslint-plugin-react": "^7.35.2",      // ← NOUVEAU
    "prettier": "^3.3.3"                   // ← NOUVEAU
  }
}
```

**Bénéfice :**
- `npm run lint` = automatically fixes code issues
- `npm run format` = consistent formatting before commits
- `npm run type-check` = catch TypeScript errors early

---

### 2️⃣ Configuration ESLint améliorée

**Pourquoi ?**  
Le fichier ESLint par défaut était minimaliste. Il fallait ajouter React-specific rules et configurer correctement le JSX runtime.

**Fichier créé :** `eslint.config.js`

**Améliorations clés :**

```javascript
extends: [
  js.configs.recommended,
  tseslint.configs.recommended,
  react.configs.flat.recommended,        // ← NOUVEAU : React rules
  react.configs.flat['jsx-runtime'],     // ← NOUVEAU : React 19 JSX
  reactHooks.configs.flat.recommended,
  reactRefresh.configs.vite,
]

rules: {
  'react-refresh/only-export-components': ['warn', { allowConstantExport: true }],
  '@typescript-eslint/no-unused-vars': ['warn', {
    argsIgnorePattern: '^_',              // ← Permet le "_unused = ..."
    varsIgnorePattern: '^_',
  }],
}
```

**Exemple :** Si le code est non-conforme, ESLint le signal :

```typescript
// ❌ Non-conforme : variable inutilisée
export function Component() {
  const unused = "hello";
  return <div>world</div>;
}

// ✅ Conforme : préfixe avec underscore
export function Component() {
  const _unused = "hello";
  return <div>world</div>;
}
```

**Benefices ? :** code plus propre.

---

### 3️⃣ Configuration Prettier

**Pourquoi ?**  
Pour automatiser le formatage et éviter les débats "2 espaces vs 4 espaces" en code review.

**Fichier créé :** `.prettierrc.json`

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always"
}
```

**Exemples de ce que Prettier fait :**

```typescript
// ❌ Avant
const greeting = (name)=>"Hello, "+name

// ✅ Après (run `npm run format`)
const greeting = (name) => 'Hello, ' + name;
```

**Fichier créé :** `.prettierignore`
```
node_modules
dist
build
*.min.js
*.lock
.DS_Store
```

Prettier ignore ces fichiers (pas de besoin de les formater).

---

### 4️⃣ Structure React avec Router

**Pourquoi React Router ?**  
Pour naviguer entre pages **sans rechargement** (SPA = Single Page Application).

**Fichier créé :** `src/App.tsx`

```typescript
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import Layout from './components/Layout'
import HomePage from './pages/HomePage'
import NotFoundPage from './pages/NotFoundPage'

export default function App() {
  return (
    <Router>
      <Routes>
        {/* Toutes les routes partagent Layout */}
        <Route element={<Layout />}>
          <Route index element={<HomePage />} />        {/* "/" */}
          <Route path="*" element={<NotFoundPage />} />  {/* 404 */}
        </Route>
      </Routes>
    </Router>
  )
}
```

**Comment ça marche :**

```
URL: http://localhost:5173/
  ↓
<Router> matches "/" (index)
  ↓
Renders <Layout />
  ↓
<Outlet /> in Layout → renders <HomePage />
  ↓
Result: Header + HomePage + Footer
```

**Ajout de routes future (Prochain steps) :**
```typescript
<Route element={<Layout />}>
  <Route index element={<HomePage />} />
  <Route path="tasks" element={<TaskListPage />} />      // Next time
  <Route path="login" element={<LoginPage />} />          // Next time
  <Route path="*" element={<NotFoundPage />} />
</Route>
```

---

### 5️⃣ Composants principaux

#### **Layout (`src/components/Layout.tsx`)**

**Rôle :** Conteneur partagé pour toutes les pages.

```typescript
export default function Layout() {
  return (
    <div className="app-container">
      <Header />
      <main className="app-content">
        <Outlet />  {/* ← Les pages s'affichent juste là */}
      </main>
      <Footer />
    </div>
  )
}
```

**Structure CSS (dans `src/App.css`) :**
```css
.app-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.app-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}
```

**Bénéfices ? :** Le footer reste en bas même si la page est courte.

#### **Header (`src/components/Header.tsx`)**

**Rôle :** Navigation + Branding.

```typescript
export default function Header() {
  return (
    <header className="bg-white shadow">
      <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
        <div className="flex justify-between items-center">
          <Link to="/" className="...">
            <span>📋</span>
            <span>TaskFlow</span>
          </Link>
          <div className="flex gap-4">
            <Link to="/">Home</Link>
          </div>
        </div>
      </nav>
    </header>
  )
}
```

**Points clés :**
- `<Link to="/">` = React Router navigation (pas de rechargement)
- Tailwind classes : `bg-white shadow` = fond blanc avec ombre
- Responsive : `px-4 sm:px-6 lg:px-8` = padding qui augmente sur les grands écrans (révisions possibles... Pas très beau)

#### **Footer (`src/components/Footer.tsx`)**

```typescript
export default function Footer() {
  const currentYear = new Date().getFullYear()
  return (
    <footer className="bg-gray-800 text-white mt-12">
      <div className="...">
        <p>© {currentYear} TaskFlow. All rights reserved.</p>
      </div>
    </footer>
  )
}
```

---

### 6️⃣ Pages (Page Components)

#### **HomePage (`src/pages/HomePage.tsx`)**

**Rôle :** Page d'accueile.

```typescript
export default function HomePage() {
  const [count, setCount] = useState(0)
  
  return (
    <div className="...">
      <h1>Welcome to TaskFlow</h1>
      
      {}
      <p className="text-6xl font-bold">{count}</p>
      <button onClick={() => setCount(count + 1)}>Increase</button>
      <button onClick={() => setCount(count - 1)}>Decrease</button>
      <button onClick={() => setCount(0)}>Reset</button>
    </div>
  )
}
```

**Pourquoi un compteur ?**
- Démontre React hooks (`useState`)
- Prouve que l'interactivité fonctionne avant de faire du vrai CRUD
- Point de référence pour les futures pages avec états complexes

**État initial :** `count = 0`  
**Au clic "Increase" :** `count = 1` → Re-render automatique  
**Au clic "Decrease" :** `count = 0` → Re-render automatique

#### **NotFoundPage (`src/pages/NotFoundPage.tsx`)**

```typescript
export default function NotFoundPage() {
  return (
    <div className="...">
      <h1 className="text-6xl">404</h1>
      <p>Page not found</p>
      <Link to="/">Go back home</Link>
    </div>
  )
}
```

**Quand s'affiche-t-elle ?**  
URL : `http://localhost:5173/unknown`  
→ Aucune route ne match → `<Route path="*">` trigger  
→ Affiche 404

---

### 7️⃣ Styles CSS

#### **Global Styles (`src/index.css`)**

```css
@tailwind utilities;  /* Utility classes */

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html, body, #root {
  height: 100%;
  font-family: -apple-system, BlinkMacSystemFont,
  -webkit-font-smoothing: antialiased; /* Meilleur rendu de texte */
}

body {
  background-color: #f9fafb;
}
```

**Pourquoi ces modifications ?**
1. `* { margin: 0; padding: 0 }` = élimine les espacements par défaut
2. `box-sizing: border-box` = padding n'augmente pas la taille
3. `height: 100%` sur html/body/root = permet `min-height: 100vh` dans App
4. Font antialiasing = texte moins pixelisé sur macOS

#### **Layout Styles (`src/App.css`)**

```css
.app-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.app-content {
  flex: 1;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.fade-in {
  animation: fadeIn 0.3s ease-in-out;
}
```

---

## Explication architecturale

### Flux d'une requête utilisateur

```
1. Utilisateur clique sur <Link to="/tasks">
   ↓
2. React Router intercepte (pas de rechargement HTTP)
   ↓
3. Route matcher : GET "/" → aucune match
   GET "/tasks" → match Route avec path="tasks"
   ↓
4. React rend <Layout> + <TaskListPage />
   ↓
5. Layout affiche : <Header> + <Outlet /> + <Footer>
   <Outlet /> remplace par <TaskListPage />
   ↓
6. DOM mis à jour (Animation fade-in si défini)
   ↓
7. Utilisateur voit la nouvelle page sans rechargement ⚡
```

### States vs Props

**States** = données qui changent dans le composant
```typescript
const [count, setCount] = useState(0)  // État local
```

**Props** = données passées du parent au enfant
```typescript
<Header title="My App" />
```

**Pour Semaine 2 (CRUD) :**
- States : tasks list, loading, error
- Props : taskId, onDelete (callback)
- Context (futur) : user authentifié, theme dark/light

---

## Configuration ESLint + Prettier

### Workflow recommended

#### **Avant de committer :**
```bash
npm run format  # Format le code
npm run lint    # Fix ESLint violations
npm run type-check # Check TypeScript
```
---

## Comprendre React Router

### Pattern : Nested Routes

```typescript
<Route element={<Layout />}>
  <Route index element={<HomePage />} />
  <Route path="tasks" element={<TaskListPage />} />
</Route>
```

**Signification :**
- `/` → Layout + HomePage (index)
- `/tasks` → Layout + TaskListPage
- Layout s'affiche **toujours** (Header/Footer constants)

### Ajout futur : Authentification

```typescript
<Route element={<Layout />}>
  <Route element={<ProtectedRoute />}>  {/* Vérifie auth */}
    <Route index element={<HomePage />} />
    <Route path="tasks" element={<TaskListPage />} />
  </Route>
  
  <Route path="login" element={<LoginPage />} />
  <Route path="signup" element={<SignupPage />} />
</Route>
```

---

## Structure des composants

### Convention de nommage

```
src/
├── components/          # Composants réutilisables
│   ├── Layout.tsx       # Conteneur général
│   ├── Header.tsx       # Header
│   ├── Footer.tsx       # Footer
│   └── TaskCard.tsx     # (Futur) Carte d'une tâche
├── pages/              # Composants "page-level"
│   ├── HomePage.tsx    # Page d'accueil
│   ├── TaskListPage.tsx # (Futur) Liste des tâches
│   ├── LoginPage.tsx    # (Futur) Login
│   └── NotFoundPage.tsx # 404
├── lib/                # Utilities / hooks custom
│   ├── api.ts          # (Futur) Appels API
│   └── auth.ts         # (Futur) Logique authentification
└── types/              # (Futur) TypeScript interfaces
    └── Task.ts
```

### Taille recommandée des fichiers

- **< 200 lignes** : Composant simple (Header, Footer, Button)
- **200-500 lignes** : Composant moyen (HomePage, TaskCard)
- **> 500 lignes** : Découper en sous-composants

---

## Sécurité et CVE

### Audit des dépendances

```bash
npm audit
# Output: 0 vulnerabilities found
```

### Packages critiqués

**React 19.2.4** - ✅ No CVEs  
**React DOM 19.2.4** - ✅ No CVEs  
**React Router 7.13.2** - ✅ No CVEs  
**Vite 8.0.1** - ✅ No CVEs  
**TypeScript 5.9.3** - ✅ No CVEs

### Mise à jour des dépendances

```bash
# Check outdated packages
npm outdated

# Update safely
npm update

# Update major versions (be careful!)
npm install react@20.0.0  # If released
```

---

## Commandes utiles

### Développement
```bash
npm run dev          # Start dev server (localhost:5173)
npm run build        # Production build
npm run preview      # Preview build locally
```

### Qualité du code
```bash
npm run lint         # Fix ESLint violations
npm run format       # Format with Prettier
npm run type-check   # TypeScript type checking
```

### Debugging
```bash
# Watch for TypeScript errors
npx tsc --watch

# Watch for ESLint violations
npx eslint --watch src/
```

---

## 📋 Checklist pour prochianes étapes

- [ ] Implémenter les pages Login/Signup
- [ ] Intégrer Cognito (authentification)
- [ ] Ajouter TanStack Query pour la gestion des états serveur
- [ ] Créer les pages TaskList, TaskDetail
- [ ] Implémenter CRUD API calls
- [ ] Ajouter des tests unitaires

---

## 🎓 Points clés à retenir

1. **React Router** permet la navigation SPA sans rechargement
2. **Nested Routes** = partage de layouts (Header/Footer constants)
3. **useState** = state local, perfect pour counters/toggles
4. **Tailwind** = CSS utility-first, rapide et responsive
5. **ESLint + Prettier** = code professionnel et formaté
6. **TypeScript strict** = erreurs attrapées à la compilation
7. **CVE scanning** = zéro vulnérabilité = sécurité ✅

---

## Questions réccurrentes à savoir !

### Q: Pourquoi React Router et pas Next.js ?
A: React Router est plus léger et suffisant pour une SPA frontend. Next.js = utile si on besoin du server-side rendering.

### Q: Comment on ajoute une nouvelle page ?
1. Créer `src/pages/MyPage.tsx`
2. Importer dans `App.tsx`
3. Ajouter `<Route path="mypage" element={<MyPage />} />`

### Q: "Missing dependencies" sur un hook. C'est quoi ?
A: React hooks (useState, useEffect) ont des dépendances à déclarer. ESLint empêche les bugs en vous le rappelant.

```typescript
// ❌ Mauvais
useEffect(() => {
  console.log(count)  // count n'est pas dans les dépendances !
}, [])

// ✅ Correct
useEffect(() => {
  console.log(count)
}, [count])  // Déclarer les dépendances
```

### Q: Comment tester l'app localement ?
A:
```bash
npm run dev
```

---

**Statut :** Bootstrap Complet  
**Prochaine étape :** CRUD & Authentification Cognito

