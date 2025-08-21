# Python Lambda Test Project

Simple Python Lambda function for testing the GitHub Actions lambda-deploy action.

## 🐍 Function Description

This is a basic "Hello World" Lambda function that:
- Returns a greeting message with optional custom name
- Includes timestamp and runtime information
- Demonstrates proper Lambda response structure
- Has comprehensive unit tests

## 🚀 Local Testing

```bash
# Run tests
python -m unittest test_lambda.py -v

# Test function locally
python3 -c "
from lambda_function import lambda_handler
from unittest.mock import Mock

context = Mock()
context.function_name = 'lambda-test-python'
context.aws_request_id = 'local-test'

# Test with default name
result = lambda_handler({}, context)
print('Default:', result)

# Test with custom name
result = lambda_handler({'name': 'Developer'}, context)
print('Custom:', result)
"
```

## 📋 Expected Response

```json
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{
    \"message\": \"Hello, World!\",
    \"timestamp\": \"2025-08-21T...\",
    \"runtime\": \"Python 3.9\",
    \"function_name\": \"lambda-test-python\",
    \"request_id\": \"...\"
  }"
}
```

## 🔧 Deployment

This project uses the centralized lambda-deploy action. Configure these GitHub secrets:

- `AWS_ACCESS_KEY_ID` - AWS access key for development
- `AWS_SECRET_ACCESS_KEY` - AWS secret key for development  
- `S3_BUCKET_NAME` - S3 bucket for deployment artifacts
- `LAMBDA_FUNCTION_NAME` - Target Lambda function name (defaults to `lambda-test-python`)

## ⚡ Quick Deploy

1. Push to `main` branch for automatic dev deployment
2. Use `workflow_dispatch` for manual deployment to specific environments