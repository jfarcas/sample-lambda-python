# Lambda Test Python

Test repository for the [Lambda Deploy Action](https://github.com/jfarcas/lambda-deploy-action) reusable GitHub action.

## Purpose

This repository tests the `jfarcas/lambda-deploy-action` reusable action with a simple Python Lambda function.

## Usage

1. Go to the **Actions** tab
2. Run "Deploy Lambda " workflow
3. Select your environment (dev/pre/prod)

## Files

- **[lambda_function.py](lambda_function.py)** - Simple Python Lambda function
- **[requirements.txt](requirements.txt)** - Python dependencies  
- **[pyproject.toml](pyproject.toml)** - Project configuration
- **[.github/config/lambda-deploy-config.yml](.github/config/lambda-deploy-config.yml)** - Deploy action configuration
- **[version.txt](version.txt)** - Version tracking

## Setup

### Required Secrets
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key  
- `AWS_ROLE_ARN` - AWS role ARN (optional)
- `TEAMS_WEBHOOK_URL` - Teams notifications (optional)

### Required Variables
- `S3_BUCKET_NAME` - S3 bucket for artifacts
- `LAMBDA_FUNCTION_NAME` - Lambda function name
- `AWS_REGION` - AWS region

## Action Repository

[jfarcas/lambda-deploy-action](https://github.com/jfarcas/lambda-deploy-action) - Main action repository with full documentation.
