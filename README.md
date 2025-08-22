# Lambda Test Python

A simple Python Lambda function for testing deployment workflows with modern Python development practices.

## 🚀 Features

- **Modern Python Development:** Uses `pyproject.toml` for project configuration
- **Version Management:** Semantic versioning with automatic detection
- **Quality Gates:** Optional linting and testing with pytest
- **Health Checks:** Deployment validation with configurable payloads
- **Auto-Rollback:** Optional automatic rollback on deployment failure

## 📁 Project Structure

```
lambda-test-python/
├── lambda_function.py                          # Main Lambda function
├── pyproject.toml                             # Modern Python project configuration
├── requirements.txt                           # Runtime dependencies (empty for this example)
├── dev-requirements.txt                       # Development dependencies (alternative approach)
├── tests/                                     # Test directory
│   ├── __init__.py
│   └── test_lambda_function.py               # Comprehensive test suite
├── lambda-deploy-config.yml                  # Simple deployment configuration
├── lambda-deploy-config-with-pyproject.yml   # Advanced configuration using pyproject.toml
├── lambda-deploy-config-with-testing.yml     # Configuration with quality gates
└── VERSION_MANAGEMENT_GUIDE.md               # Version management documentation
```

## 🔧 Version Management

This project demonstrates modern Python version management using `pyproject.toml`:

```toml
[project]
name = "lambda-test-python"
version = "1.0.0"  # ← Version automatically detected by deployment action
description = "Simple Python Lambda function"
```

### Version Detection Priority

The deployment action detects versions in this order:
1. **pyproject.toml** (current approach) ✅
2. `__version__.py`
3. `setup.py`
4. `version.txt`
5. `VERSION`
6. `package.json`
7. Git tags
8. Commit hash (fallback)

## 🛡️ Quality Gates

### Simple Approach (Current)
```yaml
build:
  commands:
    install: "pip install -r requirements.txt"
    build: "auto"
    # No lint or test commands = skip both
```

### With Quality Gates
```yaml
build:
  commands:
    install: "pip install -e .[dev]"  # Install with dev dependencies
    lint: "flake8 . && black --check . && isort --check-only ."
    test: "python -m pytest tests/ -v --cov=lambda_function"
    build: "auto"
```

## 🧪 Testing

### Run Tests Locally

```bash
# Install development dependencies
pip install -e .[dev]

# Run all tests
pytest

# Run with coverage
pytest --cov=lambda_function --cov-report=html

# Run specific test types
pytest -m unit          # Unit tests only
pytest -m integration   # Integration tests only
pytest -m "not slow"    # Skip slow tests
```

### Test Categories

- **Unit Tests:** Fast, isolated tests of individual functions
- **Integration Tests:** Tests that verify component interactions
- **Performance Tests:** Tests that verify acceptable performance

## 🔄 Deployment Configurations

### 1. Simple Configuration (Current)
**File:** `lambda-deploy-config.yml`
- No quality gates
- Manual rollback only
- Basic health checks

### 2. Modern Python Configuration
**File:** `lambda-deploy-config-with-pyproject.yml`
- Uses pyproject.toml for dependencies
- Full quality gates (lint + test)
- Development dependencies managed properly

### 3. Quality Gates Configuration
**File:** `lambda-deploy-config-with-testing.yml`
- Shows how to install and use linting/testing tools
- Demonstrates proper dependency management

## 📋 Development Dependencies

### Using pyproject.toml (Recommended)

```toml
[project.optional-dependencies]
dev = [
    "flake8>=5.0.0",      # Linting
    "black>=22.0.0",      # Code formatting
    "pytest>=7.0.0",      # Testing
    "pytest-cov>=4.0.0", # Coverage
]
```

Install with: `pip install -e .[dev]`

### Using dev-requirements.txt (Alternative)

```txt
flake8>=5.0.0
black>=22.0.0
pytest>=7.0.0
pytest-cov>=4.0.0
```

Install with: `pip install -r dev-requirements.txt`

## 🚀 Local Development

### Setup Development Environment

```bash
# Clone repository
git clone <repository-url>
cd lambda-test-python

# Install in development mode with dev dependencies
pip install -e .[dev]

# Run quality checks
flake8 .
black --check .
isort --check-only .

# Run tests
pytest -v

# Test the Lambda function locally
python -c "
import lambda_function
result = lambda_function.lambda_handler({'name': 'Local Test'}, None)
print(result)
"
```

### Code Quality Tools

```bash
# Format code
black .
isort .

# Lint code
flake8 .

# Type checking (if enabled)
mypy lambda_function.py

# Security scanning (if enabled)
bandit -r .
```

## 📊 Version Bumping

### Manual Version Bumping

```bash
# Edit pyproject.toml
vim pyproject.toml  # Change version = "1.0.0" to "1.0.1"

# Commit and tag
git add pyproject.toml
git commit -m "Bump version to 1.0.1"
git tag v1.0.1
git push origin main --tags
```

### Automated Version Bumping (Optional)

```bash
# Install bump2version
pip install bump2version

# Bump patch version (1.0.0 → 1.0.1)
bump2version patch

# Bump minor version (1.0.1 → 1.1.0)
bump2version minor

# Bump major version (1.1.0 → 2.0.0)
bump2version major
```

## 🏥 Health Check Testing

The Lambda function responds to health check payloads:

```python
# Test payload
{
    "name": "HealthCheck",
    "source": "deployment-validation"
}

# Expected response
{
    "statusCode": 200,
    "body": {
        "message": "Hello, HealthCheck!",
        "timestamp": "2025-08-22T10:30:00",
        "runtime": "Python 3.9",
        "function_name": "lambda-test-python",
        "request_id": "health-check-id"
    }
}
```

## 🔧 Configuration Examples

### Minimal (Hello World)
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
```

### Production Ready
```yaml
project:
  name: "lambda-test-python"
  runtime: "python"
  versions:
    python: "3.9"

build:
  commands:
    install: "pip install -e .[dev]"
    lint: "flake8 . && black --check ."
    test: "pytest tests/ -v --cov=lambda_function"
    build: "auto"

deployment:
  health_check:
    enabled: true
  auto_rollback:
    enabled: true
    strategy: "last_successful"
```

## 📚 Documentation

- **[VERSION_MANAGEMENT_GUIDE.md](VERSION_MANAGEMENT_GUIDE.md)** - Comprehensive version management guide
- **[lambda-deploy-config-with-pyproject.yml](lambda-deploy-config-with-pyproject.yml)** - Modern Python configuration
- **[lambda-deploy-config-with-testing.yml](lambda-deploy-config-with-testing.yml)** - Quality gates configuration

## 🎯 Best Practices Demonstrated

1. **Modern Python Standards:** Using pyproject.toml for project configuration
2. **Semantic Versioning:** Proper version management with automatic detection
3. **Quality Gates:** Optional but comprehensive linting and testing
4. **Test Organization:** Structured test suite with different test types
5. **Development Dependencies:** Proper separation of runtime and dev dependencies
6. **Configuration Flexibility:** Multiple deployment configuration examples
7. **Documentation:** Comprehensive guides and examples

This project serves as a reference implementation for modern Python Lambda development with enterprise-grade deployment workflows.
