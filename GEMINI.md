# GEMINI.md - Project Context

This file provides context for the Gemini AI assistant.

## Project Overview

This is a simple Python project that defines a "hello world" AWS Lambda function. Its primary purpose is to test the `jfarcas/lambda-deploy-action` reusable GitHub Action, which automates the deployment of Lambda functions.

The project uses Python 3.9 and has no external runtime dependencies. Development dependencies like `pytest` for testing and `flake8` for linting are managed in `pyproject.toml`.

### Key Technologies

*   **Language:** Python 3.9
*   **Cloud Provider:** AWS (for Lambda)
*   **CI/CD:** GitHub Actions

### Architecture

The core logic is contained in a single file, `lambda_function.py`. The deployment process is configured in `.github/config/lambda-deploy-config.yml` and orchestrated by the GitHub Actions workflow defined in `.github/workflows/lambda-deploy.yml`.

## Building and Running

### Building

The project is built and packaged automatically by the GitHub Actions workflow. The build process installs dependencies from `requirements.txt` and creates a zip archive for deployment.

To build manually, you can run the following command:

```bash
# TODO: Add manual build command if necessary
```

### Running Locally

To run the Lambda function locally, you can use a tool like AWS SAM CLI or a simple Python script that invokes the `lambda_handler` function.

### Testing

The project uses `pytest` for testing. Tests are located in the `tests/` directory.

To run the tests, use the following command:

```bash
python -m pytest tests/
```

## Development Conventions

### Coding Style

The project follows standard Python conventions (PEP 8). The `pyproject.toml` file includes configurations for `black` and `isort` to enforce a consistent code style.

### Testing Practices

The project includes unit tests for the Lambda function. The tests are located in `tests/test_lambda_function.py`. The GitHub Actions workflow is configured to run these tests before deployment.

### Versioning

The project version is managed in the `pyproject.toml` file under the `[project]` section. The version is automatically detected and used by the deployment action.
