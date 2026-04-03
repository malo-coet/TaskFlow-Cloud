#!/bin/bash

# ============================================================================
# TaskFlow Lambda CRUD Deployment Script
# Builds, packages, and deploys CRUD Lambda functions to AWS via Terraform
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LAMBDA_DIR="$PROJECT_ROOT/lambda/functions"
INFRA_DIR="$PROJECT_ROOT/infra"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

print_section() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_section "TaskFlow Lambda CRUD Deployment"

# Step 1: Check dependencies
print_info "Checking dependencies..."
if ! command -v node &> /dev/null; then
  print_error "Node.js is not installed"
  exit 1
fi
if ! command -v npm &> /dev/null; then
  print_error "npm is not installed"
  exit 1
fi
if ! command -v terraform &> /dev/null; then
  print_warning "Terraform is not installed. Skipping terraform validation."
fi
print_success "Dependencies OK"

# Step 2: Install dependencies
print_section "Installing dependencies"
cd "$LAMBDA_DIR"
print_info "Running npm install in $LAMBDA_DIR"
npm install
print_success "Dependencies installed"

# Step 3: Compile TypeScript
print_section "Compiling TypeScript"
print_info "Running TypeScript compiler..."
npm run build
print_success "TypeScript compilation completed"

# Step 4: Package Lambda functions
print_section "Packaging Lambda functions"
cd "$LAMBDA_DIR/dist"

# Clean old zip files
rm -f *.zip
print_info "Cleaned old zip files"

# Create zip files for each Lambda function
for ts_file in ../createTask.ts ../listTasks.ts ../updateTask.ts ../deleteTask.ts; do
  funcname=$(basename "$ts_file" .ts)
  js_file="$funcname.js"
  zip_file="$funcname.zip"

  if [ -f "$js_file" ]; then
    print_info "Packaging $funcname..."
    zip "$zip_file" "$js_file"
    print_success "Created $zip_file"
  else
    print_error "Compiled JS file not found: $js_file"
    exit 1
  fi
done

print_success "All Lambda functions packaged"

# Step 5: Terraform validation
print_section "Terraform validation"
cd "$INFRA_DIR"

if command -v terraform &> /dev/null; then
  print_info "Validating Terraform..."
  terraform validate
  print_success "Terraform validation passed"

  # Show Terraform plan
  print_info "Showing Terraform plan..."
  terraform plan -out=tfplan
  print_success "Review the plan above and run: terraform apply tfplan"
else
  print_warning "Terraform not found. Skipping validation."
fi

print_section "✅ Lambda deployment preparation completed"
echo ""
echo "Next steps:"
echo "  1. Review the Terraform plan above"
echo "  2. Run: cd infra && terraform apply tfplan"
echo "  3. Test endpoints:"
echo "     - POST   https://<api-endpoint>/tasks (create)"
echo "     - GET    https://<api-endpoint>/tasks (list)"
echo "     - PUT    https://<api-endpoint>/tasks/{taskId} (update)"
echo "     - DELETE https://<api-endpoint>/tasks/{taskId} (delete)"
echo ""
        --runtime nodejs20.x \
        --role "$ROLE_ARN" \
        --handler handler.handler \
        --zip-file fileb://function.zip \
        --region "$REGION" > /dev/null
fi

echo "   ✅ Lambda déployée"

# Étape 5: Nettoyer
echo ""
echo "5️⃣  Nettoyer les fichiers temporaires..."
rm -f function.zip
echo "   ✅ Fichiers temporaires supprimés"

# Étape 6: Afficher l'info de la Lambda
echo ""
echo "✅ Déploiement réussi !"
echo ""
echo "📋 Infos de la Lambda:"
aws lambda get-function \
    --function-name "$FUNCTION_NAME" \
    --region "$REGION" \
    --query 'Configuration.[FunctionName,FunctionArn,Runtime,Handler,Role]' \
    --output table

echo ""
echo "🔗 Prochaine étape: Configurer API Gateway"
echo "   Voir: DOCS/NEXT_STEPS.md - Étape 3"

