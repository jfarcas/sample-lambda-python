# Lambda Deploy Action - Usage Examples

This repository demonstrates both usage patterns for the Lambda Deploy Action from the [GitHub Actions Collection](https://github.com/jfarcas/lambda-deploy-action).

## 🎯 Purpose

This consumer repository serves as a **sample project** to demonstrate the functionality of the Lambda Deploy Action repository. It shows real-world usage patterns that users can copy and adapt for their own projects.

## 📋 Available Workflows

### 1. Direct Action Usage (Recommended)
**File:** [`.github/workflows/lambda-deploy.yml`](.github/workflows/lambda-deploy.yml)

Uses the action directly in the workflow for maximum flexibility and control.

```yaml
- name: Deploy or Rollback Lambda Function
  uses: jfarcas/lambda-deploy-action/actions/lambda-deploy@main
  env:
    S3_BUCKET_NAME: ${{ vars.S3_BUCKET_NAME }}
    LAMBDA_FUNCTION_NAME: ${{ vars.LAMBDA_FUNCTION_NAME }}
    AWS_REGION: ${{ vars.AWS_REGION }}
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  with:
    config-file: 'lambda-deploy-config.yml'
    environment: ${{ inputs.environment || 'auto' }}
```

**Benefits:**
- ✅ Full control over workflow structure
- ✅ Custom steps before/after deployment
- ✅ Flexible error handling
- ✅ Custom deployment summaries

### 2. Reusable Workflow Usage
**File:** [`.github/workflows/lambda-deploy-reusable.yml`](.github/workflows/lambda-deploy-reusable.yml)

Uses the pre-built reusable workflow for simplified setup.

```yaml
jobs:
  deploy:
    uses: jfarcas/lambda-deploy-action/actions/lambda-deploy/workflows/workflow.yml@main
    with:
      config-file: 'lambda-deploy-config.yml'
      environment: ${{ inputs.environment || 'auto' }}
    secrets:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      S3_BUCKET_NAME: ${{ vars.S3_BUCKET_NAME }}
      LAMBDA_FUNCTION_NAME: ${{ vars.LAMBDA_FUNCTION_NAME }}
      AWS_REGION: ${{ vars.AWS_REGION }}
```

**Benefits:**
- ✅ Simplified configuration
- ✅ Pre-configured dynamic run names
- ✅ Built-in error handling
- ✅ Consistent deployment patterns

## 🔄 Testing Both Patterns

### Manual Testing
1. **Direct Action:** Go to Actions → "Deploy Python Lambda (Direct Action)" → Run workflow
2. **Reusable Workflow:** Go to Actions → "Deploy Python Lambda (Reusable Workflow)" → Run workflow

### Automatic Testing
Both workflows trigger on:
- Push to `main` or `feature/**` branches
- Pull requests to `main`

## 📊 Comparison

| Feature | Direct Action | Reusable Workflow |
|---------|---------------|-------------------|
| **Setup Complexity** | Medium | Simple |
| **Customization** | High | Medium |
| **Maintenance** | Self-managed | Managed by action |
| **Dynamic Run Names** | Custom | Pre-configured |
| **Error Handling** | Custom | Built-in |
| **Best For** | Custom workflows | Standard deployments |

## 🎯 When to Use Each Pattern

### Use Direct Action When:
- You need custom steps before/after deployment
- You want full control over error handling
- You have complex workflow requirements
- You need custom deployment summaries

### Use Reusable Workflow When:
- You want quick setup with minimal configuration
- You prefer standardized deployment patterns
- You want automatic updates to workflow improvements
- You have straightforward deployment needs

## 🔧 Configuration

Both workflows use the same configuration file: [`lambda-deploy-config.yml`](lambda-deploy-config.yml)

```yaml
project:
  name: "lambda-test-python"
  runtime: "python"
  versions:
    python: "3.9"

build:
  commands:
    install: "pip install -r requirements.txt"
    build: "auto"

environments:
  dev:
    trigger_branches: ["main", "feature/**"]
    aws:
      auth_type: "access_key"
  
  pre:
    trigger_branches: ["main"]
    aws:
      auth_type: "access_key"
  
  prod:
    aws:
      auth_type: "access_key"

deployment:
  health_check:
    enabled: true
    test_payload_object:
      name: "Test"
      source: "deployment-validation"
    expected_status_code: 200
    expected_response_contains: "success"
```

## 🔐 Required Secrets and Variables

### Repository Secrets
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `AWS_ROLE_ARN` - AWS role ARN (optional)
- `TEAMS_WEBHOOK_URL` - Teams webhook URL (optional)

### Repository Variables
- `S3_BUCKET_NAME` - S3 bucket for deployment artifacts
- `LAMBDA_FUNCTION_NAME` - Lambda function name
- `AWS_REGION` - AWS region

## 🚀 Dynamic Run Names

Both workflows demonstrate dynamic run names that show deployment context:

### Direct Action Examples:
- `🚀 Manual Deploy | john.doe → prod`
- `📦 Auto Deploy | main`
- `🔄 Lambda Deploy | feature/new-feature`

### Reusable Workflow Examples:
- `🚀 Manual Deploy to prod | v1.0.1 | Add new feature`
- `📦 Push Deploy | main | Fix critical bug`
- `🔍 PR Deploy | #123 | Update documentation`

## 📚 Learning Resources

### Action Repository
- [Lambda Deploy Action](https://github.com/jfarcas/lambda-deploy-action)
- [Complete Documentation](https://github.com/jfarcas/lambda-deploy-action/tree/main/actions/lambda-deploy/docs)
- [Configuration Examples](https://github.com/jfarcas/lambda-deploy-action/tree/main/actions/lambda-deploy/examples)

### This Consumer Repository
- [lambda-deploy-config.yml](lambda-deploy-config.yml) - Configuration file
- [pyproject.toml](pyproject.toml) - Version detection
- [lambda_function.py](lambda_function.py) - Sample Lambda function

## 🎯 Next Steps

1. **Choose your pattern** based on your needs
2. **Copy the workflow** that matches your requirements
3. **Adapt the configuration** for your specific use case
4. **Set up secrets and variables** in your repository
5. **Test the deployment** in your dev environment

## 🤝 Contributing

This consumer repository demonstrates the Lambda Deploy Action functionality. For:
- **Action improvements:** Contribute to the [main action repository](https://github.com/jfarcas/lambda-deploy-action)
- **Example improvements:** Open issues or PRs in this repository

---

**This repository serves as a living example of how to use the Lambda Deploy Action in real-world scenarios.** 🚀
