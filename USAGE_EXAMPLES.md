# Lambda Deploy Action - Usage Examples

This repository demonstrates the **direct action usage pattern** for the Lambda Deploy Action from the [GitHub Actions Collection](https://github.com/jfarcas/lambda-deploy-action).

## 🎯 Purpose

This consumer repository serves as a **sample project** to demonstrate the functionality of the Lambda Deploy Action repository. It shows the **recommended direct action usage pattern** that provides maximum flexibility and control.

## 📋 Direct Action Usage

**File:** [`.github/workflows/lambda-deploy.yml`](.github/workflows/lambda-deploy.yml)

Uses the action directly in the workflow for maximum flexibility and control.

```yaml
- name: Deploy or Rollback Lambda Function
  uses: jfarcas/lambda-deploy-action/actions/lambda-deploy@main
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    S3_BUCKET_NAME: ${{ vars.S3_BUCKET_NAME }}
    LAMBDA_FUNCTION_NAME: ${{ vars.LAMBDA_FUNCTION_NAME }}
    AWS_REGION: ${{ vars.AWS_REGION }}
    TEAMS_WEBHOOK_URL: ${{ secrets.TEAMS_WEBHOOK_URL }}
  with:
    config-file: '.github/config/lambda-deploy-config.yml'
    environment: ${{ inputs.environment || 'auto' }}
    force-deploy: ${{ inputs.force_deploy || false }}
    rollback-to-version: ${{ inputs.rollback_version }}
    debug: ${{ inputs.debug || false }}
```

## 🎯 Why Direct Action Usage?

### **Simplicity:**
- ✅ Single action call - no complex workflow nesting
- ✅ Direct control over all parameters
- ✅ Easy to understand and debug
- ✅ No cross-repository dependencies

### **Flexibility:**
- ✅ Custom steps before/after deployment
- ✅ Custom error handling and retry logic
- ✅ Full control over workflow structure
- ✅ Easy to customize deployment summaries

### **Reliability:**
- ✅ No permission inheritance issues
- ✅ Straightforward troubleshooting
- ✅ Self-contained workflow
- ✅ Clear action parameters and environment variables

### **Maintainability:**
- ✅ Easy to customize and extend
- ✅ No complex workflow dependencies
- ✅ Direct parameter control
- ✅ Simple debugging process

## 📁 Configuration File Organization

### Recommended Organization
**File:** [`.github/config/lambda-deploy-config.yml`](.github/config/lambda-deploy-config.yml)

```
project-root/
├── .github/
│   ├── config/
│   │   └── lambda-deploy-config.yml      # ✅ Organized with other CI/CD configs
│   └── workflows/
│       └── lambda-deploy.yml             # Direct action workflow
├── src/
│   └── lambda_function.py
├── pyproject.toml
└── README.md
```

**Benefits:**
- ✅ Keeps root directory clean
- ✅ Groups CI/CD configurations together
- ✅ Follows GitHub Actions conventions
- ✅ Easy to find and maintain

### Alternative Organizations

#### Option 1: Root Directory (Simple Projects)
```yaml
# In workflows:
config-file: "lambda-deploy-config.yml"
```

#### Option 2: Config Directory (Medium Projects)
```yaml
# In workflows:
config-file: "config/lambda-deploy-config.yml"
```

#### Option 3: Deploy Directory (Large Projects)
```yaml
# In workflows:
config-file: "deploy/lambda-config.yml"
```

## 🔄 Testing the Deployment

### Manual Testing
1. Go to Actions → "Deploy Python Lambda (Direct Action)"
2. Click "Run workflow"
3. Select your environment (dev/pre/prod)
4. Configure optional parameters:
   - Force deployment
   - Rollback version
   - Debug mode

### Automatic Testing
The workflow triggers on:
- Push to `main` or `feature/**` branches
- Pull requests to `main`

## 🔧 Configuration

The workflow uses the configuration file: [`.github/config/lambda-deploy-config.yml`](.github/config/lambda-deploy-config.yml)

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

### Repository Secrets (Sensitive Data)
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `AWS_ROLE_ARN` - AWS role ARN (optional)
- `TEAMS_WEBHOOK_URL` - Teams webhook URL (optional)

### Repository Variables (Configuration)
- `S3_BUCKET_NAME` - S3 bucket for deployment artifacts
- `LAMBDA_FUNCTION_NAME` - Lambda function name
- `AWS_REGION` - AWS region

## 🚀 Dynamic Run Names

The workflow demonstrates dynamic run names that show deployment context:

### Examples:
- `🚀 Manual Deploy | john.doe → prod`
- `📦 Auto Deploy | main`
- `🔄 Lambda Deploy | feature/new-feature`

### Implementation:
```yaml
run-name: >-
  ${{
    github.event_name == 'workflow_dispatch' && 
    format('🚀 Manual Deploy | {0} → {1}', 
      github.actor,
      inputs.environment
    ) ||
    github.event_name == 'push' &&
    format('📦 Auto Deploy | {0}',
      github.ref_name
    ) ||
    format('🔄 Lambda Deploy | {0}',
      github.ref_name
    )
  }}
```

## 🎯 Advanced Features

### Rollback Capability
```yaml
# Manual rollback via workflow dispatch
rollback_version:
  description: 'Version to rollback to (leave empty for normal deployment)'
  required: false
  type: string
```

### Force Deployment
```yaml
# Bypass version conflicts
force_deploy:
  description: 'Force deployment'
  required: false
  default: false
  type: boolean
```

### Debug Mode
```yaml
# Enable detailed logging
debug:
  description: 'Enable debug output'
  required: false
  default: false
  type: boolean
```

### Custom Deployment Summary
```yaml
- name: Deployment Summary
  if: success()
  run: |
    echo "## 🚀 Deployment Summary (Direct Action)" >> $GITHUB_STEP_SUMMARY
    echo "- **Method:** Direct Action Usage" >> $GITHUB_STEP_SUMMARY
    echo "- **Environment:** ${{ inputs.environment || 'auto' }}" >> $GITHUB_STEP_SUMMARY
    # ... custom summary content
```

## 📚 Learning Resources

### Action Repository
- [Lambda Deploy Action](https://github.com/jfarcas/lambda-deploy-action)
- [Complete Documentation](https://github.com/jfarcas/lambda-deploy-action/tree/main/actions/lambda-deploy/docs)
- [Configuration Examples](https://github.com/jfarcas/lambda-deploy-action/tree/main/actions/lambda-deploy/examples)

### This Consumer Repository
- [lambda-deploy-config.yml](.github/config/lambda-deploy-config.yml) - Configuration file
- [pyproject.toml](pyproject.toml) - Version detection
- [lambda_function.py](lambda_function.py) - Sample Lambda function

## 🎯 Implementation Steps

### 1. Copy the Workflow
Copy [`.github/workflows/lambda-deploy.yml`](.github/workflows/lambda-deploy.yml) to your repository.

### 2. Copy the Configuration
Copy [`.github/config/lambda-deploy-config.yml`](.github/config/lambda-deploy-config.yml) and adapt for your needs.

### 3. Set Up Repository
1. **Secrets:** Add AWS credentials and optional webhook URLs
2. **Variables:** Add S3 bucket, Lambda function name, and AWS region
3. **Environments:** Configure GitHub environments if needed

### 4. Customize
- Update project name and runtime version
- Configure environments and trigger branches
- Set up health checks and notifications
- Add custom build commands

### 5. Test
- Test with dev environment first
- Verify all features work as expected
- Gradually roll out to staging and production

## 🤝 Contributing

This consumer repository demonstrates the Lambda Deploy Action functionality. For:
- **Action improvements:** Contribute to the [main action repository](https://github.com/jfarcas/lambda-deploy-action)
- **Example improvements:** Open issues or PRs in this repository

---

**This repository serves as a living example of how to use the Lambda Deploy Action with the recommended direct action pattern.** 🚀
