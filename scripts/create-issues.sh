#!/usr/bin/env bash
# =============================================================================
# scripts/create-issues.sh
# Crée automatiquement labels, milestones et issues GitHub pour TaskFlow Cloud.
#
# Prérequis :
#   - gh CLI installé : https://cli.github.com/
#   - Être authentifié : gh auth login
#   - Être dans le répertoire du repo OU passer REPO en variable d'env
#
# Usage :
#   chmod +x scripts/create-issues.sh
#   ./scripts/create-issues.sh
#
#   # Ou sur un fork :
#   REPO="votre-user/TaskFlow-Cloud" ./scripts/create-issues.sh
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
REPO="${REPO:-malo-coet/TaskFlow-Cloud}"

# Dates de milestone (ajustez selon votre date de démarrage)
START_DATE="${START_DATE:-$(date +%Y-%m-%d)}"
add_days() {
  # GNU date (Linux) or BSD date (macOS)
  date -d "${START_DATE} +${1} days" +%Y-%m-%d 2>/dev/null \
    || date -v+${1}d -j -f "%Y-%m-%d" "${START_DATE}" +%Y-%m-%d 2>/dev/null \
    || { echo "❌ Erreur : commande 'date' non compatible. Installez GNU coreutils (macOS: brew install coreutils)." >&2; exit 1; }
}

MS1_DUE=$(add_days 7)
MS2_DUE=$(add_days 14)
MS3_DUE=$(add_days 21)
MS4_DUE=$(add_days 30)

echo "🚀 Création des labels, milestones et issues pour : ${REPO}"
echo "📅 Date de démarrage : ${START_DATE}"
echo ""

# ---------------------------------------------------------------------------
# 1. Labels
# ---------------------------------------------------------------------------
echo "🏷️  Création des labels..."

create_label() {
  local name="$1" color="$2" description="$3"
  gh label create "${name}" --color "${color}" --description "${description}" \
    --repo "${REPO}" --force 2>/dev/null && echo "  ✓ ${name}" || echo "  ⚠ ${name} (déjà existant ou erreur)"
}

create_label "semaine-1"     "0075ca" "Semaine 1 — Setup & Squelette"
create_label "semaine-2"     "e4e669" "Semaine 2 — CRUD & Authentification"
create_label "semaine-3"     "d93f0b" "Semaine 3 — IaC, CI/CD, Observabilité"
create_label "semaine-4"     "0e8a16" "Semaine 4 — Finition & Pitch"
create_label "frontend"      "bfd4f2" "Composants React/Vite"
create_label "backend"       "fef2c0" "Lambda, API Gateway"
create_label "infrastructure" "e99695" "Terraform/SAM, ressources AWS"
create_label "ci-cd"         "c5def5" "GitHub Actions, déploiement"
create_label "auth"          "f9d0c4" "Cognito, JWT, sécurité auth"
create_label "observabilite" "d4c5f9" "CloudWatch, monitoring, alertes"
create_label "documentation" "cfd3d7" "README, docs, architecture"
create_label "securite"      "b60205" "IAM, throttling, sécurité"
create_label "bug"           "d73a4a" "Quelque chose ne fonctionne pas"
create_label "enhancement"   "a2eeef" "Nouvelle fonctionnalité"

echo ""

# ---------------------------------------------------------------------------
# 2. Milestones
# ---------------------------------------------------------------------------
echo "🎯 Création des milestones..."

create_milestone() {
  local title="$1" due="$2" description="$3"
  gh api --method POST "/repos/${REPO}/milestones" \
    -f title="${title}" \
    -f due_on="${due}T23:59:59Z" \
    -f description="${description}" \
    --silent 2>/dev/null && echo "  ✓ ${title}" || echo "  ⚠ ${title} (déjà existant ou erreur)"
}

create_milestone "Semaine 1 — Setup & Squelette"         "${MS1_DUE}" "Frontend minimal + backend hello world déployé"
create_milestone "Semaine 2 — CRUD & Auth"                "${MS2_DUE}" "CRUD complet + authentification fonctionnelle"
create_milestone "Semaine 3 — IaC, CI/CD, Observabilité" "${MS3_DUE}" "git push main → build + tests + déploiement automatique"
create_milestone "Semaine 4 — Finition & Pitch"           "${MS4_DUE}" "Projet 100% recruiter-friendly + pitch prêt"

echo ""

# ---------------------------------------------------------------------------
# Utilitaire : récupérer le numéro d'un milestone par son titre
# ---------------------------------------------------------------------------
get_milestone_number() {
  gh api "/repos/${REPO}/milestones" --jq ".[] | select(.title == \"$1\") | .number" 2>/dev/null || echo ""
}

# ---------------------------------------------------------------------------
# 3. Issues — Semaine 1
# ---------------------------------------------------------------------------
echo "📋 Création des issues — Semaine 1..."

MS1=$(get_milestone_number "Semaine 1 — Setup & Squelette")

gh issue create \
  --repo "${REPO}" \
  --title "[S1-J1/J2] Setup initial — Compte AWS, CLI, MFA, repo GitHub" \
  --label "semaine-1,infrastructure,documentation" \
  --milestone "${MS1}" \
  --body "## 📋 Description
Configuration initiale de l'environnement de développement et du compte AWS.

## ✅ Critères d'acceptation
- [ ] Compte AWS créé avec MFA activé
- [ ] AWS CLI v2 installé et configuré (\`aws configure\`)
- [ ] Terraform ou AWS SAM CLI installé et fonctionnel (\`terraform version\`)
- [ ] Repo GitHub créé, GitHub Copilot activé sur le compte
- [ ] Labels, milestones et issues créés via \`scripts/create-issues.sh\`

## 📎 Ressources
- [Installer AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Installer Terraform](https://developer.hashicorp.com/terraform/downloads)
- [GitHub Copilot](https://github.com/features/copilot)

## 🤖 IA
Copilot : génération de scripts de configuration. ChatGPT : clarification des bonnes pratiques IAM initiales." \
  --silent && echo "  ✓ [S1] Setup initial" || echo "  ⚠ [S1] Setup initial (erreur)"

gh issue create \
  --repo "${REPO}" \
  --title "[S1-J3/J4] Bootstrap SPA React/Vite — Page Hello TaskFlow" \
  --label "semaine-1,frontend" \
  --milestone "${MS1}" \
  --body "## 📋 Description
Créer le squelette de l'application frontend SPA avec React et Vite.

## ✅ Critères d'acceptation
- [ ] SPA créée avec \`npm create vite@latest frontend -- --template react-ts\`
- [ ] Page \"/\" affiche \"Hello TaskFlow\" avec un style minimal
- [ ] React Router configuré (routes : \`/\`, \`/login\`, \`/tasks\`)
- [ ] ESLint + Prettier configurés et passants (\`npm run lint\`)
- [ ] Copilot utilisé pour générer le squelette des composants principaux

## 📎 Ressources
- [Vite](https://vitejs.dev/guide/)
- [React Router v6](https://reactrouter.com/en/main/start/tutorial)
- [Tailwind CSS](https://tailwindcss.com/docs/installation) (optionnel)

## 🤖 IA
Copilot : génération du squelette des composants React (Layout, TaskList, TaskCard). Revue manuelle de chaque composant généré." \
  --silent && echo "  ✓ [S1] Bootstrap SPA" || echo "  ⚠ [S1] Bootstrap SPA (erreur)"

gh issue create \
  --repo "${REPO}" \
  --title "[S1-J5/J7] Lambda health-check + API Gateway HTTP API + Schéma DynamoDB" \
  --label "semaine-1,backend,infrastructure" \
  --milestone "${MS1}" \
  --body "## 📋 Description
Première Lambda déployée, connectée à un API Gateway HTTP API. Définition du schéma DynamoDB.

## ✅ Critères d'acceptation
- [ ] Lambda Node.js \`health-check\` déployée (GET \`/health\` → \`{ status: \"ok\", version: \"1.0.0\" }\`)
- [ ] API Gateway HTTP API créé avec la route \`GET /health\`
- [ ] Frontend appelle \`/health\` et affiche la réponse à l'écran
- [ ] Schéma DynamoDB documenté dans \`docs/dynamodb-schema.md\` :
  - Table \`Tasks\` : PK \`userId\`, SK \`taskId\`, attributs \`title\`, \`status\`, \`dueDate\`, \`tags\`, \`createdAt\`
- [ ] Test manuel de l'endpoint avec Hoppscotch ou Insomnia

## 📎 Ressources
- [AWS Lambda Node.js](https://docs.aws.amazon.com/lambda/latest/dg/lambda-nodejs.html)
- [API Gateway HTTP API](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api.html)
- [DynamoDB Single-Table Design](https://www.alexdebrie.com/posts/dynamodb-single-table/)

## 🤖 IA
Copilot : génération du handler Lambda et du schéma DynamoDB initial. Décision finale sur la modélisation des données : revue manuelle." \
  --silent && echo "  ✓ [S1] Lambda + API GW + DynamoDB schema" || echo "  ⚠ [S1] Lambda + API GW (erreur)"

echo ""

# ---------------------------------------------------------------------------
# 4. Issues — Semaine 2
# ---------------------------------------------------------------------------
echo "📋 Création des issues — Semaine 2..."

MS2=$(get_milestone_number "Semaine 2 — CRUD & Auth")

gh issue create \
  --repo "${REPO}" \
  --title "[S2-J8/J9] DynamoDB Tasks + Lambda CRUD (createTask, listTasks, updateTask, deleteTask)" \
  --label "semaine-2,backend" \
  --milestone "${MS2}" \
  --body "## 📋 Description
Implémentation complète du CRUD sur les tâches via Lambda + DynamoDB.

## ✅ Critères d'acceptation
- [ ] Table DynamoDB \`Tasks\` créée (PK: \`userId\`, SK: \`taskId\`)
- [ ] Lambda \`POST /tasks\` — crée une tâche (validation des champs obligatoires)
- [ ] Lambda \`GET /tasks\` — liste les tâches de l'utilisateur connecté (scan par userId)
- [ ] Lambda \`PUT /tasks/{taskId}\` — met à jour une tâche (titre, status, dueDate, tags)
- [ ] Lambda \`DELETE /tasks/{taskId}\` — supprime une tâche
- [ ] Codes HTTP corrects : 201, 200, 404, 400, 500
- [ ] Types TypeScript définis pour \`Task\`, \`CreateTaskDTO\`, \`UpdateTaskDTO\`

## 📎 Ressources
- [AWS SDK v3 — DynamoDB](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/client/dynamodb/)
- [Middy middleware](https://middy.js.org/)
- [DynamoDB Toolbox](https://github.com/jeremydaly/dynamodb-toolbox)

## 🤖 IA
Copilot : génération des handlers et des types TypeScript. Revue manuelle des requêtes DynamoDB (PK/SK, conditions d'appartenance par userId)." \
  --silent && echo "  ✓ [S2] DynamoDB CRUD" || echo "  ⚠ [S2] DynamoDB CRUD (erreur)"

gh issue create \
  --repo "${REPO}" \
  --title "[S2-J10/J11] Cognito User Pool + Authorizer JWT sur API Gateway" \
  --label "semaine-2,auth,backend,securite" \
  --milestone "${MS2}" \
  --body "## 📋 Description
Mise en place de l'authentification avec AWS Cognito et protection de toutes les routes API.

## ✅ Critères d'acceptation
- [ ] Cognito User Pool créé (signup/login par email + mot de passe)
- [ ] App Client Cognito configuré pour le frontend (SRP auth flow)
- [ ] Authorizer JWT Cognito ajouté sur API Gateway (toutes routes sauf \`/health\`)
- [ ] Une requête sans token valide reçoit 401
- [ ] Frontend : page Login fonctionnelle (email + mot de passe)
- [ ] Frontend : page Signup fonctionnelle avec confirmation par email
- [ ] Token JWT stocké de façon sécurisée (pas dans localStorage)

## 📎 Ressources
- [Cognito User Pools](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html)
- [API Gateway JWT Authorizer](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-jwt-authorizer.html)
- [amazon-cognito-identity-js](https://github.com/aws-amplify/amplify-js/tree/main/packages/amazon-cognito-identity-js)

## 🔒 Sécurité
- Tokens stockés en mémoire ou httpOnly cookie (jamais localStorage pour les refresh tokens)
- Forcer HTTPS uniquement (CloudFront)

## 🤖 IA
Copilot : génération des hooks React pour l'auth. Architecture auth (choix du storage des tokens) : décision manuelle après revue des bonnes pratiques OWASP." \
  --silent && echo "  ✓ [S2] Cognito + JWT" || echo "  ⚠ [S2] Cognito + JWT (erreur)"

gh issue create \
  --repo "${REPO}" \
  --title "[S2-J12/J14] Intégration CRUD frontend + tests unitaires Lambda" \
  --label "semaine-2,frontend,backend" \
  --milestone "${MS2}" \
  --body "## 📋 Description
Relier le frontend au backend CRUD, ajouter des tests unitaires et documenter l'auth.

## ✅ Critères d'acceptation
- [ ] Page \`/tasks\` : liste des tâches de l'utilisateur connecté
- [ ] Formulaire d'ajout de tâche (titre, date d'échéance, tags)
- [ ] Édition inline ou via modal
- [ ] Suppression avec confirmation
- [ ] Gestion des états loading/error dans l'UI (ex : spinner, message d'erreur)
- [ ] Au moins 5 tests unitaires sur les Lambdas (Jest ou Vitest) :
  - \`createTask\` : validation des champs, réponse 201
  - \`listTasks\` : retourne un tableau vide si aucune tâche
  - \`deleteTask\` : retourne 404 si tâche inexistante
- [ ] Section \"Authentification\" ajoutée au README

## 📎 Ressources
- [TanStack Query (React Query)](https://tanstack.com/query/latest)
- [Vitest](https://vitest.dev/)
- [aws-sdk-mock](https://github.com/dwyl/aws-sdk-mock)

## 🤖 IA
Copilot : génération des cas de tests. Règles métier (qui peut voir/modifier les tâches des autres) : décision manuelle." \
  --silent && echo "  ✓ [S2] Intégration CRUD + tests" || echo "  ⚠ [S2] Intégration CRUD (erreur)"

echo ""

# ---------------------------------------------------------------------------
# 5. Issues — Semaine 3
# ---------------------------------------------------------------------------
echo "📋 Création des issues — Semaine 3..."

MS3=$(get_milestone_number "Semaine 3 — IaC, CI/CD, Observabilité")

gh issue create \
  --repo "${REPO}" \
  --title "[S3-J15/J17] Infrastructure as Code — Terraform/SAM (S3, CloudFront, Lambda, API GW, DynamoDB, Cognito)" \
  --label "semaine-3,infrastructure" \
  --milestone "${MS3}" \
  --body "## 📋 Description
Décrire toute l'infrastructure AWS en code Terraform ou AWS SAM.

## ✅ Critères d'acceptation
- [ ] Module Terraform \`s3-cloudfront\` : bucket S3 + distribution CloudFront (OAC)
- [ ] Module \`lambda-api\` : fonctions Lambda + rôles IAM granulaires (least privilege)
- [ ] Module \`api-gateway\` : HTTP API + routes + authorizer JWT
- [ ] Module \`dynamodb\` : table Tasks avec billing mode PAY_PER_REQUEST
- [ ] Module \`cognito\` : User Pool + App Client
- [ ] State Terraform dans un S3 bucket dédié avec DynamoDB lock table
- [ ] \`terraform plan\` ne crée aucune ressource non prévue
- [ ] \`terraform apply\` déploie l'infra complète from scratch en < 5 min

## 📎 Ressources
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [tfsec — scanner sécurité IaC](https://aquasecurity.github.io/tfsec/)
- [Infracost — estimation des coûts](https://www.infracost.io/)

## 🤖 IA
Copilot : génération des blocs de ressources Terraform. Revue manuelle de chaque bloc pour les politiques IAM (permissions minimales) et les configurations de sécurité S3/CloudFront." \
  --silent && echo "  ✓ [S3] IaC Terraform/SAM" || echo "  ⚠ [S3] IaC Terraform/SAM (erreur)"

gh issue create \
  --repo "${REPO}" \
  --title "[S3-J18/J19] Pipeline CI/CD GitHub Actions — build, test, deploy" \
  --label "semaine-3,ci-cd,infrastructure" \
  --milestone "${MS3}" \
  --body "## 📋 Description
Automatiser le build, les tests et le déploiement via GitHub Actions.

## ✅ Critères d'acceptation
- [ ] Job \`build-and-test\` :
  - Lint ESLint (\`npm run lint\`)
  - Build Vite (\`npm run build\`)
  - Tests Jest/Vitest (\`npm run test\`)
- [ ] Job \`deploy\` (uniquement sur push \`main\`) :
  - \`terraform plan\` + \`terraform apply\`
  - Upload du build frontend vers S3
  - Invalidation du cache CloudFront
- [ ] Authentification AWS via OIDC (pas de secrets long-lived)
- [ ] Badge CI dans le README
- [ ] Le pipeline passe au vert de bout en bout

## 📎 Ressources
- [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
- [OIDC pour AWS GitHub Actions](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [hashicorp/setup-terraform](https://github.com/hashicorp/setup-terraform)

## 🤖 IA
Copilot : génération du fichier workflow YAML. Revue manuelle des permissions IAM OIDC (scope minimal)." \
  --silent && echo "  ✓ [S3] CI/CD GitHub Actions" || echo "  ⚠ [S3] CI/CD GitHub Actions (erreur)"

gh issue create \
  --repo "${REPO}" \
  --title "[S3-J20/J21] CloudWatch Logs + Métriques + Throttling API Gateway" \
  --label "semaine-3,observabilite,securite" \
  --milestone "${MS3}" \
  --body "## 📋 Description
Configurer l'observabilité avec CloudWatch et sécuriser l'API Gateway avec du throttling.

## ✅ Critères d'acceptation
- [ ] CloudWatch Log Groups pour chaque Lambda (rétention : 7 jours)
- [ ] Access logs activés sur API Gateway
- [ ] Tableau de bord CloudWatch : taux d'erreur 5xx, latence P50/P99, throttles
- [ ] Alarme CloudWatch : taux d'erreur > 5% → notification par email (SNS)
- [ ] Throttling API Gateway : 100 req/s par route, burst 50
- [ ] Test de l'alarme : vérifier qu'elle se déclenche correctement

## 📎 Ressources
- [CloudWatch Metrics pour Lambda](https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics.html)
- [API Gateway throttling](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-throttling.html)
- [CloudWatch Alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html)

## 🤖 IA
ChatGPT : aide à la définition des seuils d'alarme pertinents. Configuration finale des quotas : décision manuelle selon les besoins du projet." \
  --silent && echo "  ✓ [S3] CloudWatch + Throttling" || echo "  ⚠ [S3] CloudWatch + Throttling (erreur)"

echo ""

# ---------------------------------------------------------------------------
# 6. Issues — Semaine 4
# ---------------------------------------------------------------------------
echo "📋 Création des issues — Semaine 4..."

MS4=$(get_milestone_number "Semaine 4 — Finition & Pitch")

gh issue create \
  --repo "${REPO}" \
  --title "[S4-J22/J23] Schéma d'architecture — diagramme Excalidraw/draw.io" \
  --label "semaine-4,documentation" \
  --milestone "${MS4}" \
  --body "## 📋 Description
Créer un diagramme d'architecture clair et professionnel pour le README.

## ✅ Critères d'acceptation
- [ ] Diagramme créé sur Excalidraw ou draw.io incluant :
  - User → CloudFront → S3 (SPA)
  - User → API Gateway → Lambda → DynamoDB
  - Cognito (côté auth)
  - CloudWatch (côté observabilité)
  - Annotations : \"HTTP API (coût réduit)\", \"Serverless\", \"Always Free Tier\"
- [ ] Fichier source sauvegardé (\`docs/architecture.excalidraw\` ou \`docs/architecture.drawio\`)
- [ ] Export PNG dans \`docs/architecture.png\`
- [ ] Diagramme intégré dans le README avec un titre et une légende

## 📎 Ressources
- [Excalidraw](https://excalidraw.com/)
- [AWS Architecture Icons](https://aws.amazon.com/architecture/icons/)
- [draw.io](https://app.diagrams.net/)

## 🤖 IA
ChatGPT : suggestions sur les éléments à inclure dans le diagramme. Dessin final : manuel." \
  --silent && echo "  ✓ [S4] Schéma architecture" || echo "  ⚠ [S4] Schéma architecture (erreur)"

gh issue create \
  --repo "${REPO}" \
  --title "[S4-J24/J25] README niveau professionnel" \
  --label "semaine-4,documentation" \
  --milestone "${MS4}" \
  --body "## 📋 Description
Rédiger un README complet, clair et recruiter-friendly.

## ✅ Critères d'acceptation
- [ ] Section : Résumé du projet (2 paragraphes max)
- [ ] Section : Architecture (diagramme + explication simple)
- [ ] Section : Stack technique (React, AWS, Terraform, GitHub Actions)
- [ ] Section : Décisions de sécurité (IAM, JWT, HTTPS, throttling)
- [ ] Section : Coûts estimés (tableau Free Tier)
- [ ] Section : Comment déployer (étapes numérotées)
- [ ] Section : Utilisation des outils IA (Copilot + ChatGPT)
- [ ] Badges : CI status, licence, Node.js version
- [ ] Lien vers la démo (URL CloudFront) + compte de test
- [ ] Tout est compréhensible sans connaissance préalable du projet

## 🤖 IA
Copilot : suggestions de formulations. Contenu final (architecture, décisions) : rédigé et validé manuellement." \
  --silent && echo "  ✓ [S4] README pro" || echo "  ⚠ [S4] README pro (erreur)"

gh issue create \
  --repo "${REPO}" \
  --title "[S4-J26/J27] Captures d'écran de l'application" \
  --label "semaine-4,documentation,frontend" \
  --milestone "${MS4}" \
  --body "## 📋 Description
Ajouter des captures d'écran de l'application pour montrer l'UX et les fonctionnalités clés.

## ✅ Critères d'acceptation
- [ ] Capture : page Login / Signup
- [ ] Capture : liste des tâches (avec au moins 3 tâches de statuts différents)
- [ ] Capture : formulaire d'ajout/édition de tâche
- [ ] Capture : message d'erreur géré proprement (ex : 401 non authentifié)
- [ ] Capture : pipeline GitHub Actions passé au vert ✅
- [ ] Captures placées dans \`docs/screenshots/\`
- [ ] Toutes les captures référencées dans le README

## 📎 Outils
- macOS : Cmd+Shift+4 pour capture de zone
- Windows : Win+Shift+S
- [CleanShot X](https://cleanshot.com/) pour des captures annotées (optionnel)" \
  --silent && echo "  ✓ [S4] Screenshots" || echo "  ⚠ [S4] Screenshots (erreur)"

gh issue create \
  --repo "${REPO}" \
  --title "[S4-J28/J29] Script de déploiement + documentation How to Run" \
  --label "semaine-4,documentation,infrastructure,ci-cd" \
  --milestone "${MS4}" \
  --body "## 📋 Description
Documenter et automatiser le déploiement pour qu'un développeur externe puisse tout lancer facilement.

## ✅ Critères d'acceptation
- [ ] Section \"How to Run\" dans le README avec étapes numérotées :
  1. Créer un compte AWS, configurer credentials
  2. Cloner le repo
  3. \`terraform init && terraform apply\`
  4. \`npm install && npm run build\` (frontend)
  5. Récupérer l'URL CloudFront dans les outputs Terraform
- [ ] Script \`scripts/deploy.sh\` ou \`Makefile\` qui automatise les étapes
- [ ] Variables d'environnement nécessaires documentées dans \`.env.example\`
- [ ] Mode lecture seule : URL démo + compte de test fourni dans le README

## 🤖 IA
Copilot : génération du script deploy.sh. Revue manuelle pour la gestion des erreurs et des pré-requis." \
  --silent && echo "  ✓ [S4] Deploy script + How to Run" || echo "  ⚠ [S4] Deploy script (erreur)"

gh issue create \
  --repo "${REPO}" \
  --title "[S4-J30] Nettoyage final + préparation du pitch" \
  --label "semaine-4,documentation" \
  --milestone "${MS4}" \
  --body "## 📋 Description
Vérification finale que tout fonctionne et préparation du pitch pour les recruteurs.

## ✅ Critères d'acceptation
- [ ] Déploiement from scratch sur un compte AWS vierge réussi (< 10 min)
- [ ] Toutes les ressources AWS de test supprimées (\`terraform destroy\` sur l'env de dev)
- [ ] README lisible et compréhensible sans contexte préalable
- [ ] Pitch de 2–3 min préparé : problème → solution → stack → coûts → sécurité → IA
- [ ] Lien de démo fonctionnel ajouté dans la description du repo GitHub
- [ ] Tout le code est dans la branche \`main\`, pas de branches abandonnées

## 📌 Checklist finale
- [ ] \`terraform apply\` déploie sans erreur
- [ ] Pipeline GitHub Actions passe au vert
- [ ] L'URL CloudFront est accessible en HTTPS
- [ ] Un utilisateur peut s'inscrire, se connecter, créer/modifier/supprimer des tâches
- [ ] Les logs CloudWatch montrent les requêtes en temps réel" \
  --silent && echo "  ✓ [S4] Nettoyage + Pitch" || echo "  ⚠ [S4] Nettoyage + Pitch (erreur)"

echo ""
echo "✅ Terminé ! Vérifiez les issues créées sur :"
echo "   https://github.com/${REPO}/issues"
echo ""
echo "📌 Prochaine étape :"
echo "   Créez un GitHub Project (Board ou Roadmap) sur :"
echo "   https://github.com/${REPO}/projects"
echo "   → Cliquez sur 'New project' → 'Board' ou 'Roadmap'"
echo "   → Liez le repo pour voir apparaître toutes les issues automatiquement"
