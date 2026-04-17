# Commandes de test (courtes)

Ces commandes sont volontairement petites/copier-coller pour valider rapidement l'etat backend.

## 0) Variables utiles

```bash
cd /Users/malo/Projects/TaskFlow/infra
API_URL="$(terraform output -raw api_endpoint)"
USER_POOL_ID="$(terraform output -raw cognito_user_pool_id 2>/dev/null || true)"
CLIENT_ID="$(terraform output -raw cognito_client_id 2>/dev/null || true)"
echo "$API_URL"
```

## 1) Smoke tests HTTP

```bash
curl -i "$API_URL/health"
curl -i "$API_URL/tasks"
```

## 2) Recuperer un JWT (si Cognito actif)

```bash
JWT="$(aws cognito-idp admin-initiate-auth \
  --user-pool-id "$USER_POOL_ID" \
  --client-id "$CLIENT_ID" \
  --auth-flow ADMIN_USER_PASSWORD_AUTH \
  --auth-parameters USERNAME=testuser@example.com,PASSWORD=TestPassword123! \
  --query 'AuthenticationResult.IdToken' --output text)"

echo "JWT length: ${#JWT}"
```

## 3) CRUD minimal

```bash
CREATE_RESP="$(curl -sS -X POST "$API_URL/tasks" \
  -H "Authorization: Bearer $JWT" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test rapide","description":"smoke","status":"TODO"}')"

echo "$CREATE_RESP"
TASK_ID="$(echo "$CREATE_RESP" | jq -r '.taskId')"

echo "$TASK_ID"

curl -sS -X GET "$API_URL/tasks" -H "Authorization: Bearer $JWT" | jq
curl -sS -X PUT "$API_URL/tasks/$TASK_ID" -H "Authorization: Bearer $JWT" -H "Content-Type: application/json" -d '{"status":"DONE"}' | jq
curl -i -X DELETE "$API_URL/tasks/$TASK_ID" -H "Authorization: Bearer $JWT"
```

## 4) Debug rapide

```bash
aws logs tail /aws/lambda/taskflow-list-tasks --follow --since 30m
aws logs tail /aws/lambda/taskflow-create-task --follow --since 30m
```

## 5) Cas frequents

- `403 MissingAuthenticationToken`: mauvaise route/stage (`/dev` vs `/prod`) ou route absente.
- `401 Unauthorized`: JWT manquant/expire.
- `502 Internal server error`: verifier CloudWatch logs Lambda.
- `409 Function already exist`: importer la ressource Terraform ou supprimer la fonction existante.

