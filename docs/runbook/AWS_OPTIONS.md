# AWS Options - deploy, auth et exploitation

## Option A: Terraform first (recommande)

Utilise `infra/*.tf` pour provisionner API Gateway, Lambda, DynamoDB, Cognito.

```bash
cd /Users/malo/Projects/TaskFlow/infra
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"
terraform output
```

Avantages:
- Infra reproducible
- Diff auditable via `terraform plan`
- Moins d'actions manuelles en console

## Option B: Setup Cognito manuel (debug ou bootstrap)

Utilise `docs/archive/AWS_MANUAL_STEPS.md` si tu veux verifier Cognito avant IaC complet.

Quand l'infra Terraform est prete, evite de maintenir une configuration manuelle parallele.

## Option C: Mix Terraform + import (si ressources existent deja)

Cas typique: `ResourceConflictException` sur Lambda/Cognito deja crees.

Exemple pour importer une Lambda deja existante:

```bash
cd /Users/malo/Projects/TaskFlow/infra
terraform import aws_lambda_function.health_check taskflow-health-check
```

Puis:

```bash
terraform plan -out=tfplan
terraform apply "tfplan"
```

## Decision rapide

- Nouveau compte/projet propre -> Option A
- Ressources creees a la main -> Option C
- Besoin de demo rapide Cognito sans tout redeployer -> Option B

## Options AWS importantes a surveiller

- Region unique (ex: `eu-west-3`) sur tous les services
- API stage (`/dev` ou `/prod`) coherent avec l'URL testee
- Cognito callback/logout URL pour frontend local et prod
- CORS API Gateway limite aux domaines frontend legitimes
- IAM Lambda au minimum necessaire (DynamoDB table cible)

