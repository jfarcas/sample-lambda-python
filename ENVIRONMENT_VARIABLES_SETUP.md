# Environment Variables Setup Guide

## 🚨 Error Fixed

**Error Message:**
```
Error: Missing required environment variables: S3_BUCKET_NAME LAMBDA_FUNCTION_NAME AWS_REGION
Error: Please ensure these are set as repository variables or environment variables
```

**Root Cause:** The workflow was using `${{ vars.VARIABLE_NAME }}` syntax but the repository variables weren't configured.

## ✅ Solution Options

### Option 1: Hardcoded Values (Recommended for Testing)

```yaml
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  S3_BUCKET_NAME: "lambda-deploy-action"
  LAMBDA_FUNCTION_NAME: "lambda-deploy-python"
  AWS_REGION: "eu-west-1"
```

**Pros:**
- ✅ Works immediately
- ✅ No additional setup required
- ✅ Good for testing and simple setups

**Cons:**
- ⚠️ Values are visible in workflow file
- ⚠️ Need to update workflow file to change values

### Option 2: Repository Variables (Recommended for Production)

```yaml
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  S3_BUCKET_NAME: ${{ vars.S3_BUCKET_NAME }}
  LAMBDA_FUNCTION_NAME: ${{ vars.LAMBDA_FUNCTION_NAME }}
  AWS_REGION: ${{ vars.AWS_REGION }}
```

**Setup Steps:**
1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click the **Variables** tab
4. Add these variables:
   - `S3_BUCKET_NAME`: `lambda-deploy-action`
   - `LAMBDA_FUNCTION_NAME`: `lambda-deploy-python`
   - `AWS_REGION`: `eu-west-1`

**Pros:**
- ✅ Values not visible in workflow file
- ✅ Easy to change without updating workflow
- ✅ Can be different per environment
- ✅ Better security practice

**Cons:**
- ⚠️ Requires initial setup
- ⚠️ Need repository admin access

## 🔧 Current Working Configuration

The fixed workflows now use **hardcoded values** for immediate functionality:

### lambda-deploy.yml (Fixed)
```yaml
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  S3_BUCKET_NAME: "lambda-deploy-action"
  LAMBDA_FUNCTION_NAME: "lambda-deploy-python"
  AWS_REGION: "eu-west-1"
```

### lambda-deploy-advanced.yml (Fixed)
```yaml
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  S3_BUCKET_NAME: "lambda-deploy-action"
  LAMBDA_FUNCTION_NAME: "lambda-deploy-python"
  AWS_REGION: "eu-west-1"
```

### lambda-deploy-with-vars.yml (Example)
Shows both approaches with instructions for setting up repository variables.

## 📋 Required Environment Variables

### Always Required
- `AWS_ACCESS_KEY_ID` (secret)
- `AWS_SECRET_ACCESS_KEY` (secret)
- `S3_BUCKET_NAME` (variable)
- `LAMBDA_FUNCTION_NAME` (variable)
- `AWS_REGION` (variable)

### Optional
- `TEAMS_WEBHOOK_URL` (secret) - for notifications
- `AWS_ROLE_ARN` (secret) - for OIDC authentication

## 🔐 Secrets vs Variables

### Secrets (Encrypted)
```yaml
${{ secrets.SECRET_NAME }}
```
- Used for sensitive data (API keys, passwords)
- Encrypted and not visible in logs
- Examples: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

### Variables (Plain Text)
```yaml
${{ vars.VARIABLE_NAME }}
```
- Used for non-sensitive configuration
- Visible in workflow runs
- Examples: `S3_BUCKET_NAME`, `LAMBDA_FUNCTION_NAME`, `AWS_REGION`

## 🚀 Quick Fix for Current Error

If you're getting the environment variables error, use this configuration:

```yaml
- name: Deploy Lambda
  uses: jfarcas/lambda-deploy-action/.github/actions/lambda-deploy@main
  with:
    config-file: "lambda-deploy-config.yml"
    environment: ${{ inputs.environment || 'auto' }}
    force-deploy: ${{ inputs.force-deploy || false }}
    version: ${{ inputs.version || '' }}
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    S3_BUCKET_NAME: "lambda-deploy-action"           # ← Your S3 bucket name
    LAMBDA_FUNCTION_NAME: "lambda-deploy-python"     # ← Your Lambda function name
    AWS_REGION: "eu-west-1"                          # ← Your AWS region
```

## 🔧 Setting Up Repository Variables (Optional)

### Step-by-Step Guide

1. **Navigate to Repository Settings**
   - Go to your repository on GitHub
   - Click the **Settings** tab

2. **Access Secrets and Variables**
   - In the left sidebar, click **Secrets and variables**
   - Click **Actions**

3. **Add Variables**
   - Click the **Variables** tab
   - Click **New repository variable**
   - Add each variable:

   | Name | Value |
   |------|-------|
   | `S3_BUCKET_NAME` | `lambda-deploy-action` |
   | `LAMBDA_FUNCTION_NAME` | `lambda-deploy-python` |
   | `AWS_REGION` | `eu-west-1` |

4. **Update Workflow**
   - Change hardcoded values to `${{ vars.VARIABLE_NAME }}`
   - Commit and push changes

### Verification
```yaml
- name: Debug Variables
  run: |
    echo "S3 Bucket: $S3_BUCKET_NAME"
    echo "Function: $LAMBDA_FUNCTION_NAME"
    echo "Region: $AWS_REGION"
  env:
    S3_BUCKET_NAME: ${{ vars.S3_BUCKET_NAME }}
    LAMBDA_FUNCTION_NAME: ${{ vars.LAMBDA_FUNCTION_NAME }}
    AWS_REGION: ${{ vars.AWS_REGION }}
```

## 🎯 Recommendation

For immediate testing and development:
- ✅ Use **hardcoded values** (lambda-deploy.yml)

For production and team environments:
- ✅ Set up **repository variables** (lambda-deploy-with-vars.yml)

The workflows are now fixed and should work immediately with the hardcoded approach! 🚀
