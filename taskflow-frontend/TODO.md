# 📋 TODO - Prochaines étapes TaskFlow

**Date:** 2 Avril 2026  
**Phase actuelle:** Semaine 2 (CRUD & Authentification AWS) — Phase 1 ✅ TERMINÉE  
**Prochaine phase:** Phase 2 (Cognito Auth + Frontend Integration) ⏳

---

## ✅ Semaine 2 Phase 1 — DynamoDB & Lambda CRUD (J8-J9)

- [x] Créer table DynamoDB (schema: Task, User)
- [x] Implémenter 5 Lambda functions (CREATE, READ, UPDATE, DELETE, LIST)
- [x] Configurer API Gateway HTTP API
- [x] Ajouter permissions IAM
- [x] TypeScript handlers pour chaque Lambda
- [x] Shared TaskService pour opérations DynamoDB
- [x] Documentation guide d'implémentation

**Livrables:** ✅ DynamoDB table opérationnelle, Lambda CRUD implémentées, API Gateway routes configurées

---

## 📅 Semaine 2 Phase 2 — Authentication (J10-J11)

**Objectifs:**
- [ ] Créer Cognito User Pool
- [ ] Configurer Cognito App Client
- [ ] Ajouter JWT authorizer à API Gateway
- [ ] Installer AWS Amplify Auth (ou amazon-cognito-identity-js)
- [ ] Créer pages Login et Signup dans React

**Livrables:**
- Cognito setup complet
- JWT token validation sur API GW
- Auth endpoints fonctionnels
- Frontend auth pages

---

## 📅 Semaine 2 - Planification (J8-J14)

### Phase 1: Backend CRUD (J8-J9)

**Objectifs:**
- [ ] Créer table DynamoDB (schema: Task, User)
- [ ] Implémenter 5 Lambda functions (CREATE, READ, UPDATE, DELETE, LIST)
- [ ] Configurer API Gateway HTTP API
- [ ] Ajouter permissions IAM

**Livrables:**
- Lambda functions CRUD
- API Gateway routes testées
- DynamoDB table opérationnelle

### Phase 2: Authentication (J10-J11)

**Objectifs:**
- [ ] Configurer Cognito User Pool
- [ ] Créer Cognito App Client
- [ ] Ajouter JWT authorizer à API Gateway
- [ ] Installer AWS Amplify

**Livrables:**
- Cognito setup complet
- JWT token validation
- Auth endpoints fonctionnels

### Phase 3: Frontend Integration (J12-J14)

**Objectifs:**
- [ ] Créer pages Login/Signup
- [ ] Créer pages TaskList, TaskDetail
- [ ] Intégrer API calls avec TanStack Query
- [ ] Ajouter error handling et loading states

**Livrables:**
- Working CRUD UI
- Auth flow end-to-end
- Error handling complet

---

## 🔧 Commandes à maîtriser

```bash
# Code quality (avant chaque commit)
npm run lint         # Fix ESLint violations
npm run format       # Format with Prettier
npm run type-check   # Check TypeScript
npm run build        # Test production build

# Development
npm run dev          # Start dev server
npm run preview      # Preview production build
```

---

## 📚 Documentation de référence

- **README.md** - Point d'entrée principal
- **DOCS/BOOTSTRAP_GUIDE_FR.md** - Guide complet de l'architecture
- **DOCS/CHANGELOG.md** - Détails techniques des changements
- **DOCS/PROJECT_STRUCTURE.md** - Arborescence du projet

---

## 💡 Tips importants

✅ **À faire :**
- Committer après chaque feature fonctionnelle
- Tester dans le navigateur après changement
- Exécuter les quality checks avant commit
- Lire la documentation AWS avant de coder

❌ **À éviter :**
- Committer sans tester `npm run build`
- Ignorer les erreurs TypeScript
- Oublier les types React (props, state)
- Hardcoder les secrets ou URLs

---

## 🚀 Commandes rapides

```bash
# Démarrer le développement
npm run dev

# Avant de committer
npm run format && npm run lint && npm run type-check && npm run build

# Si erreurs
npm run type-check      # Voir erreurs TypeScript
npm run lint            # Voir violations ESLint
npm run build           # Voir erreurs de build
```

---

## 📞 Ressources utiles

- **React Router Docs:** https://reactrouter.com/
- **AWS Lambda:** https://docs.aws.amazon.com/lambda/
- **DynamoDB:** https://docs.aws.amazon.com/dynamodb/
- **Cognito:** https://docs.aws.amazon.com/cognito/
- **TanStack Query:** https://tanstack.com/query/

---

**Status:** Ready for Semaine 2  
**Confidence:** HIGH ✅

