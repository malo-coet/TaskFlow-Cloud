# Schéma DynamoDB — TaskFlow Cloud

## Single-Table Design

TaskFlow Cloud utilise une **seule table DynamoDB** (`TaskFlow-Tasks`) avec le pattern Single-Table Design.

### Table principale : `TaskFlow-Tasks`

| Attribut | Type | Description |
|----------|------|-------------|
| `PK` (Partition Key) | `String` | `USER#<userId>` |
| `SK` (Sort Key) | `String` | `TASK#<taskId>` ou `PROFILE` |
| `taskId` | `String` | UUID unique de la tâche |
| `userId` | `String` | ID Cognito de l'utilisateur |
| `title` | `String` | Titre de la tâche (max 200 chars) |
| `description` | `String` | Description optionnelle |
| `status` | `String` | `TODO` \| `IN_PROGRESS` \| `DONE` \| `CANCELLED` |
| `dueDate` | `String` | Date ISO 8601 (ex : `2025-12-31`) |
| `tags` | `List<String>` | Étiquettes (ex : `["urgent", "work"]`) |
| `createdAt` | `String` | Timestamp ISO 8601 |
| `updatedAt` | `String` | Timestamp ISO 8601 |

### Patterns d'accès

| Opération | Clé d'accès |
|-----------|-------------|
| Lister toutes les tâches d'un utilisateur | `PK = USER#<userId>`, `SK begins_with TASK#` |
| Récupérer une tâche précise | `PK = USER#<userId>`, `SK = TASK#<taskId>` |
| Profil utilisateur | `PK = USER#<userId>`, `SK = PROFILE` |

### Index Secondaires Globaux (GSI)

| GSI | PK | SK | Cas d'usage |
|-----|----|----|-------------|
| `GSI-Status` | `userId` | `status` | Filtrer les tâches par status |
| `GSI-DueDate` | `userId` | `dueDate` | Trier par date d'échéance |

### Exemple d'item

```json
{
  "PK": "USER#cognito-sub-abc123",
  "SK": "TASK#018f1a2b-3c4d-7e8f-9a0b-c1d2e3f4a5b6",
  "taskId": "018f1a2b-3c4d-7e8f-9a0b-c1d2e3f4a5b6",
  "userId": "cognito-sub-abc123",
  "title": "Implémenter l'auth Cognito",
  "description": "Configurer le User Pool et l'Authorizer JWT sur API Gateway",
  "status": "IN_PROGRESS",
  "dueDate": "2025-04-15",
  "tags": ["backend", "auth", "urgent"],
  "createdAt": "2025-03-29T10:00:00.000Z",
  "updatedAt": "2025-03-29T14:30:00.000Z"
}
```

### Paramètres de la table

```hcl
# Terraform
resource "aws_dynamodb_table" "tasks" {
  name         = "TaskFlow-Tasks"
  billing_mode = "PAY_PER_REQUEST"  # On-demand, Free Tier compatible

  hash_key  = "PK"
  range_key = "SK"

  attribute {
    name = "PK"
    type = "S"
  }
  attribute {
    name = "SK"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Project     = "TaskFlow-Cloud"
    Environment = "production"
  }
}
```
