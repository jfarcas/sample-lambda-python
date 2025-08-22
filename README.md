# Lambda Test Python - Consumer Example

A sample Python Lambda function that demonstrates the usage of the [Lambda Deploy Action](https://github.com/jfarcas/lambda-deploy-action) from the GitHub Actions Collection.

## 🎯 Purpose

This repository serves as a **consumer example** to demonstrate how to use the Lambda Deploy Action in real-world scenarios. It showcases both usage patterns:

1. **Direct Action Usage** - Maximum flexibility and control
2. **Reusable Workflow Usage** - Simplified setup and standardized patterns

## 🚀 Quick Start

### View the Demonstrations
- **[Direct Action Workflow](.github/workflows/lambda-deploy.yml)** - Shows direct action usage
- **[Reusable Workflow](.github/workflows/lambda-deploy-reusable.yml)** - Shows reusable workflow usage
- **[Usage Examples](USAGE_EXAMPLES.md)** - Comprehensive comparison and guide

### Test the Deployments
1. Go to the **Actions** tab
2. Choose either workflow:
   - "Deploy Python Lambda (Direct Action)"
   - "Deploy Python Lambda (Reusable Workflow)"
3. Click "Run workflow" and select your environment

## 📋 What's Included

### Lambda Function
- **[lambda_function.py](lambda_function.py)** - Simple Python Lambda function
- **[requirements.txt](requirements.txt)** - Python dependencies
- **[pyproject.toml](pyproject.toml)** - Project configuration with version

### Configuration
- **[.github/config/lambda-deploy-config.yml](.github/config/lambda-deploy-config.yml)** - Lambda Deploy Action configuration
- **[version.txt](version.txt)** - Version file for deployment tracking

### Workflows
- **Direct Action Usage** - Custom workflow with full control
- **Reusable Workflow Usage** - Simplified workflow using pre-built patterns

### Documentation
- **[USAGE_EXAMPLES.md](USAGE_EXAMPLES.md)** - Detailed usage guide and comparison
- **[ENVIRONMENT_VARIABLES_SETUP.md](ENVIRONMENT_VARIABLES_SETUP.md)** - Setup guide

## 📁 Project Organization

### Clean Structure
```
lambda-test-python/
├── .github/
│   ├── config/
│   │   └── lambda-deploy-config.yml      # ✅ CI/CD configuration
│   └── workflows/
│       ├── lambda-deploy.yml             # Direct action usage
│       └── lambda-deploy-reusable.yml    # Reusable workflow usage
├── lambda_function.py                    # Lambda function code
├── requirements.txt                      # Python dependencies
├── pyproject.toml                        # Project configuration
├── version.txt                           # Version tracking
├── USAGE_EXAMPLES.md                     # Usage guide
└── README.md                             # This file
```

**Benefits:**
- ✅ Clean root directory
- ✅ CI/CD configurations grouped together
- ✅ Easy to navigate and maintain
- ✅ Follows GitHub Actions conventions

## 🔧 Configuration Highlights

### Multi-Environment Support
```yaml
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
```

### Health Checks
```yaml
deployment:
  health_check:
    enabled: true
    test_payload_object:
      name: "Test"
      source: "deployment-validation"
    expected_status_code: 200
    expected_response_contains: "success"
```

### Version Management
- **Dev:** Timestamp-based deployments for rapid iteration
- **Pre:** Version-based with overwrite warnings for staging flexibility
- **Prod:** Strict version checking with conflict prevention

## 🎯 Usage Patterns Demonstrated

### Pattern 1: Direct Action Usage
```yaml
- name: Deploy Lambda Function
  uses: jfarcas/lambda-deploy-action/actions/lambda-deploy@main
  env:
    S3_BUCKET_NAME: ${{ vars.S3_BUCKET_NAME }}
    LAMBDA_FUNCTION_NAME: ${{ vars.LAMBDA_FUNCTION_NAME }}
    AWS_REGION: ${{ vars.AWS_REGION }}
  with:
    config-file: '.github/config/lambda-deploy-config.yml'
    environment: ${{ inputs.environment }}
```

### Pattern 2: Reusable Workflow Usage
```yaml
jobs:
  deploy:
    uses: jfarcas/lambda-deploy-action/.github/workflows/lambda-deploy-reusable.yml@main
    with:
      config-file: '.github/config/lambda-deploy-config.yml'
      environment: ${{ inputs.environment }}
    secrets:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      S3_BUCKET_NAME: ${{ vars.S3_BUCKET_NAME }}
```

## 🔍 Dynamic Workflow Names

Both patterns demonstrate dynamic workflow names that provide rich context:

- `🚀 Manual Deploy | john.doe → prod`
- `📦 Auto Deploy | main`
- `🔄 Lambda Deploy | feature/new-feature`

## 📊 Comparison

| Feature | Direct Action | Reusable Workflow |
|---------|---------------|-------------------|
| **Setup** | Medium complexity | Simple |
| **Control** | Full control | Standardized |
| **Customization** | High | Medium |
| **Maintenance** | Self-managed | Action-managed |

## 🔐 Required Setup

### Repository Secrets
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_ROLE_ARN` (optional)
- `TEAMS_WEBHOOK_URL` (optional)

### Repository Variables
- `S3_BUCKET_NAME`
- `LAMBDA_FUNCTION_NAME`
- `AWS_REGION`

## 📚 Learning Resources

### Main Action Repository
- [Lambda Deploy Action](https://github.com/jfarcas/lambda-deploy-action)
- [Complete Documentation](https://github.com/jfarcas/lambda-deploy-action/tree/main/actions/lambda-deploy/docs)
- [Configuration Examples](https://github.com/jfarcas/lambda-deploy-action/tree/main/actions/lambda-deploy/examples)

### This Repository
- [Usage Examples](USAGE_EXAMPLES.md) - Detailed comparison and guide
- [Environment Setup](ENVIRONMENT_VARIABLES_SETUP.md) - Configuration guide

## 🎯 For Your Own Projects

1. **Choose your pattern** based on your needs:
   - **Direct Action** for custom workflows
   - **Reusable Workflow** for standard deployments

2. **Choose your config organization**:
   - **`.github/config/`** for organized projects (recommended)
   - **Root directory** for simple projects
   - **Custom directory** for specific needs

3. **Copy the relevant workflow** from this repository

4. **Adapt the configuration** for your specific requirements

5. **Set up your secrets and variables**

6. **Test in your dev environment**

## 🤝 Contributing

### To This Consumer Example
- Open issues for example improvements
- Submit PRs for better demonstrations
- Request additional usage patterns

### To the Main Action
- Contribute to [jfarcas/lambda-deploy-action](https://github.com/jfarcas/lambda-deploy-action)
- Follow the action's contributing guidelines

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**This repository demonstrates real-world usage of the Lambda Deploy Action.** Use it as a reference for implementing the action in your own projects! 🚀
