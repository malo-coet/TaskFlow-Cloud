# 🌍 Environment Setup Guide

**Last Updated :** 31 Mars 2026

---

## Development Environment (.env)

### Setup Instructions

1. **Copy the example file:**
```bash
cp .env.example .env
```

2. **Fill in your values:**
```bash
nano .env
```

3. **Or set it manually:**
```bash
echo "VITE_API_URL=https://your-api-gateway-url/health" > .env
```

---

## Environment Variables

### `VITE_API_URL` (Coming J7)

**Purpose :** Base URL for Lambda API calls  
**Format :** `https://{api-id}.execute-api.{region}.amazonaws.com/{stage}`  
**Example :** `https://abc123def.execute-api.eu-west-3.amazonaws.com/dev`

**Where to get it :**
1. Go to AWS API Gateway console
2. Find `taskflow-api`
3. Click **Stages** → **$default** (or your stage name)
4. Copy the **Invoke URL**

**Usage in code :**
```typescript
const API_URL = import.meta.env.VITE_API_URL;
// Will be: https://abc123def.execute-api.eu-west-3.amazonaws.com/dev
```

---

## Vite Environment Variables

Variables starting with `VITE_` are embedded in the build at compile time.

✅ **Use for :**
- API endpoints
- Feature flags
- Public configuration

❌ **Don't use for :**
- Secrets (API keys, tokens)
- Private credentials
- Database passwords

---

## Development vs Production

### Development (npm run dev)
- Reads from `.env` locally
- Hot reload changes
- No build cache

### Production (npm run build)
- Variables baked into dist/
- Use environment-specific `.env` files:
  - `.env.production` (for Netlify/Vercel)
  - `.env.staging` (for staging)

**Example :**
```bash
# .env.production
VITE_API_URL=https://api.taskflow.app/v1
```

Then deploy with:
```bash
npm run build  # Reads .env.production
```

---

## Security Best Practices

✅ **DO:**
- Keep `.env` in `.gitignore` (already set)
- Use `.env.example` as template
- Rotate credentials regularly
- Use AWS Secrets Manager for sensitive data

❌ **DON'T:**
- Commit `.env` to git
- Hardcode API URLs in code
- Share credentials in Slack/Email
- Commit API keys to repository

---

## Troubleshooting

### "VITE_API_URL is undefined"
```bash
# Make sure .env file exists
ls -la .env

# Should show:
# .env

# If not, copy it:
cp .env.example .env
```

### "API call returns 404"
```bash
# Check the URL is correct
cat .env | grep VITE_API_URL

# Should show:
# VITE_API_URL=https://your-url/dev
```

### "Localhost API not working"
```bash
# For local testing, use:
VITE_API_URL=http://localhost:3000
# (if running local Lambda with sam local)
```

---

## Setting up for J5-J7

When you deploy the Lambda in J5-J6:

1. **Get the API URL from API Gateway**
2. **Add to `.env`:**
   ```bash
   VITE_API_URL=https://xxxxxxx.execute-api.eu-west-3.amazonaws.com/dev
   ```
3. **Restart dev server:**
   ```bash
   npm run dev
   ```
4. **Test the integration:**
   ```bash
   # In browser, click "Check Backend" button
   # Should see API response
   ```

---

**For more details, see:** `NEXT_STEPS.md` (Step J7)

