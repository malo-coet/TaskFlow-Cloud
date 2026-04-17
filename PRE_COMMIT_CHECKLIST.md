# ✅ Pre-Commit Verification Checklist

Run these checks before `git add .`

---

## Code Quality

- [ ] No hardcoded secrets in files
  ```bash
  grep -r "password\|secret\|token" infra/ lambda/ taskflow-frontend/ \
    | grep -v ".md" | grep -v "PASSWORD_AUTH" || echo "✅ Clean"
  ```

- [ ] Terraform files are valid
  ```bash
  cd infra/
  terraform fmt -recursive -check || terraform fmt -recursive
  terraform validate
  ```

- [ ] No uncommitted changes outside of new files
  ```bash
  git status --short | grep -v "^??"
  ```

---

## File Verification

- [ ] All new files exist
  ```bash
  ls -la infra/cognito.tf
  ls -la infra/api_gateway_v2.tf
  ls -la lambda/shared/authHelper.ts
  ls -la taskflow-frontend/src/lib/auth.ts
  ls -la docs/archive/TESTING_GUIDE.md
  ls -la docs/archive/AWS_MANUAL_STEPS.md
  ```

- [ ] Documentation files are readable
  ```bash
  head -5 docs/archive/TESTING_GUIDE.md
  head -5 docs/archive/AWS_MANUAL_STEPS.md
  head -5 docs/archive/DOCS.md
  ```

- [ ] No .env files committed (only .env.example)
  ```bash
  git ls-files | grep "\.env$" && echo "❌ .env is staged!" || echo "✅ Clean"
  ```

- [ ] No node_modules committed
  ```bash
  git ls-files | grep "node_modules" | wc -l  # Should be 0
  ```

---

## Documentation

- [ ] README.md mentions v0.3.0
  ```bash
  grep -i "v0.3" README.md && echo "✅ Found" || echo "❌ Missing"
  ```

- [ ] CHANGELOG.md has v0.3.0 entry
  ```bash
  grep -A 5 "\[v0.3" CHANGELOG.md && echo "✅ Found" || echo "❌ Missing"
  ```

- [ ] TESTING_GUIDE.md has JWT examples
  ```bash
  grep -i "jwt\|bearer" docs/archive/TESTING_GUIDE.md && echo "✅ Found" || echo "❌ Missing"
  ```

- [ ] AWS_MANUAL_STEPS.md has Cognito setup
  ```bash
  grep -i "cognito\|user pool" docs/archive/AWS_MANUAL_STEPS.md && echo "✅ Found" || echo "❌ Missing"
  ```

---

## Git Status

- [ ] See what you're committing
  ```bash
  git status
  ```

- [ ] Count files (should be ~15-20 new)
  ```bash
  git status --short | grep "^??" | wc -l
  ```

- [ ] No sensitive files
  ```bash
  git status | grep -i "secret\|password\|key" && echo "❌ Found!" || echo "✅ Clean"
  ```

---

## Ready to Commit?

If all checks pass ✅:

```bash
# 1. Stage
git add .

# 2. Review
git diff --cached --stat | head -20

# 3. Commit
git commit -m "feat(auth): Cognito JWT + API protection (v0.3.0 - J10-J11)

- infra/cognito.tf: User Pool + App Client
- infra/api_gateway_v2.tf: HTTP API v2 with JWT Authorizer  
- lambda/shared/authHelper.ts: JWT extraction
- taskflow-frontend/src/lib/auth.ts: Amplify integration
- docs/archive/TESTING_GUIDE.md: Complete test instructions
- docs/archive/AWS_MANUAL_STEPS.md: Step-by-step setup
- Updated README.md + CHANGELOG.md

All CRUD routes now require JWT token.
/health remains public for monitoring."

# 4. Push
git push origin dev

# 5. Verify
git log --oneline -5
```

---

## After Commit

```bash
# Verify on remote
git log --oneline origin/dev -5

# You should see your commit in the list
```

---

**Checklist Status:** 🟢 READY  
**Estimated Files:** 15-20 new + 2 modified  
**Commit Size:** ~2000 lines added  
**Ready?** YES ✅

