# Lambda Test Python - Consumer Example

A sample Python Lambda function that demonstrates the usage of the [Lambda Deploy Action](https://github.com/jfarcas/lambda-deploy-action) from the GitHub Actions Collection.

## 🎯 Purpose

This repository serves as a **consumer example** to demonstrate how to use the Lambda Deploy Action in real-world scenarios. It showcases the **direct action usage pattern** which provides maximum flexibility and control.

## 🚀 Quick Start

### View the Demonstration
- **[Direct Action Workflow](.github/workflows/lambda-deploy.yml)** - Shows direct action usage
- **[Usage Examples](USAGE_EXAMPLES.md)** - Comprehensive guide and best practices

### Test the Deployment
1. Go to the **Actions** tab
2. Choose "Deploy Python Lambda (Direct Action)"
3. Click "Run workflow" and select your environment

## 📋 What's Included

### Lambda Function
- **[lambda_function.py](lambda_function.py)** - Simple Python Lambda function
- **[requirements.txt](requirements.txt)** - Python dependencies
- **[pyproject.toml](pyproject.toml)** - Project configuration with version

### Configuration
- **[.github/config/lambda-deploy-config.yml](.github/config/lambda-deploy-config.yml)** - Lambda Deploy Action configuration
- **[version.txt](version.txt)** - Version file for deployment tracking

### Workflow
- **Direct Action Usage** - Clean, flexible workflow with full control

### Documentation
- **[USAGE_EXAMPLES.md](USAGE_EXAMPLES.md)** - Detailed usage guide and best practices
- **[ENVIRONMENT_VARIABLES_SETUP.md](ENVIRONMENT_VARIABLES_SETUP.md)** - Setup guide

## 📁 Project Organization

### Clean Structure
```
lambda-test-python/
├── .github/
│   ├── config/
│   │   └── lambda-deploy-config.yml      # ✅ CI/CD configuration
│   └── workflows/
│       └── lambda-deploy.yml             # Direct action usage
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
- ✅ Simple and straightforward structure

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

## 🎯 Direct Action Usage Pattern

```yaml
- name: Deploy Lambda Function
  uses: jfarcas/lambda-deploy-action/actions/lambda-deploy@main
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    S3_BUCKET_NAME: ${{ vars.S3_BUCKET_NAME }}
    LAMBDA_FUNCTION_NAME: ${{ vars.LAMBDA_FUNCTION_NAME }}
    AWS_REGION: ${{ vars.AWS_REGION }}
  with:
    config-file: '.github/config/lambda-deploy-config.yml'
    environment: ${{ inputs.environment }}
    force-deploy: ${{ inputs.force_deploy || false }}
    rollback-to-version: ${{ inputs.rollback_version }}
    debug: ${{ inputs.debug || false }}
```

## 🔍 Dynamic Workflow Names

The workflow demonstrates dynamic workflow names that provide rich context:

- `🚀 Manual Deploy | john.doe → prod`
- `📦 Auto Deploy | main`
- `🔄 Lambda Deploy | feature/new-feature`

## 🎯 Why Direct Action Usage?

### **Simplicity:**
- ✅ Single action call - no complex workflow nesting
- ✅ Direct control over all parameters
- ✅ Easy to understand and debug

### **Flexibility:**
- ✅ Custom steps before/after deployment
- ✅ Custom error handling and retry logic
- ✅ Full control over workflow structure

### **Reliability:**
- ✅ No cross-repository dependencies
- ✅ No permission inheritance issues
- ✅ Straightforward troubleshooting

### **Maintainability:**
- ✅ Self-contained workflow
- ✅ Easy to customize and extend
- ✅ Clear action parameters and environment variables

## 🔐 Required Setup

### Repository Secrets
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `AWS_ROLE_ARN` - AWS role ARN (optional)
- `TEAMS_WEBHOOK_URL` - Teams webhook URL (optional)

### Repository Variables
- `S3_BUCKET_NAME` - S3 bucket for deployment artifacts
- `LAMBDA_FUNCTION_NAME` - Lambda function name
- `AWS_REGION` - AWS region

## 📚 Learning Resources

### Main Action Repository
- [Lambda Deploy Action](https://github.com/jfarcas/lambda-deploy-action)
- [Complete Documentation](https://github.com/jfarcas/lambda-deploy-action/tree/main/actions/lambda-deploy/docs)
- [Configuration Examples](https://github.com/jfarcas/lambda-deploy-action/tree/main/actions/lambda-deploy/examples)

### This Repository
- [Usage Examples](USAGE_EXAMPLES.md) - Detailed guide and best practices
- [Environment Setup](ENVIRONMENT_VARIABLES_SETUP.md) - Configuration guide

## 🎯 For Your Own Projects

1. **Copy the workflow** from [`.github/workflows/lambda-deploy.yml`](.github/workflows/lambda-deploy.yml)

2. **Copy the configuration** from [`.github/config/lambda-deploy-config.yml`](.github/config/lambda-deploy-config.yml)

3. **Adapt for your needs:**
   - Update project name and runtime version
   - Configure environments and trigger branches
   - Set up health checks and notifications
   - Add custom build commands

4. **Set up your secrets and variables** in repository settings

5. **Test in your dev environment** first

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

**This repository demonstrates real-world usage of the Lambda Deploy Action with the recommended direct action pattern.** Use it as a reference for implementing the action in your own projects! 🚀
