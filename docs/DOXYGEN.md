# Doxygen / TypeDoc Guide

Ce projet est en TypeScript + Terraform.
Pour une doc API "type doxygen" cote code, on utilise TypeDoc (plus fiable pour TS).

## 1) Installer dependances doc

```bash
cd /Users/malo/Projects/TaskFlow/lambda
npm install
```

## 2) Generer la reference API

Depuis la racine:

```bash
cd /Users/malo/Projects/TaskFlow
npm run docs:all
```

Sortie generee:

- `docs/reference/api/index.html`

## 3) Regeneration en mode watch

```bash
cd /Users/malo/Projects/TaskFlow
npm run docs:api:watch
```

Si tu veux uniquement la sortie TypeDoc sans Doxygen:

```bash
npm run docs:api
```

## 4) Ce qui est documente

- `lambda/shared/taskService.ts`
- `lambda/shared/authHelper.ts`
- `lambda/functions/createTask.ts`
- `lambda/functions/listTasks.ts`
- `lambda/functions/updateTask.ts`
- `lambda/functions/deleteTask.ts`

Config TypeDoc:

- `lambda/typedoc.json`

## 5) Check-list doc d'exploitation

- Commandes de test rapides: `docs/runbook/COMMANDS.md`
- Choix AWS/Terraform: `docs/runbook/AWS_OPTIONS.md`
- Hub principal: `docs/README.md`

