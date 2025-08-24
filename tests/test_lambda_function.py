"""
Tests for lambda_function.py

This demonstrates how to test Lambda functions with unittest.
"""

import json
import time
import unittest
from unittest.mock import Mock

# Import the Lambda function
import lambda_function


class TestLambdaFunction(unittest.TestCase):
    """Test cases for the Lambda handler function."""

    def test_lambda_handler_with_name(self):
        """Test Lambda handler with a name in the event."""
        # Arrange
        event = {"name": "World"}
        context = Mock()
        context.function_name = "lambda-test-python"
        context.aws_request_id = "test-request-id"

        # Act
        response = lambda_function.lambda_handler(event, context)

        # Assert
        self.assertEqual(response["statusCode"], 200)
        self.assertIn("headers", response)
        self.assertIn("body", response)

        body = json.loads(response["body"])
        self.assertEqual(body["message"], "Hello, World!")
        self.assertEqual(body["function_name"], "lambda-test-python")
        self.assertEqual(body["request_id"], "test-request-id")
        self.assertEqual(body["runtime"], "Python 3.9")

    def test_lambda_handler_without_name(self):
        """Test Lambda handler without a name in the event (default)."""
        # Arrange
        event = {}
        context = Mock()
        context.function_name = "lambda-test-python"
        context.aws_request_id = "test-request-id"

        # Act
        response = lambda_function.lambda_handler(event, context)

        # Assert
        self.assertEqual(response["statusCode"], 200)
        body = json.loads(response["body"])
        self.assertEqual(body["message"], "Hello, World!")  # Default name

    def test_lambda_handler_with_custom_name(self):
        """Test Lambda handler with a custom name."""
        # Arrange
        event = {"name": "DevOps Team"}
        context = Mock()
        context.function_name = "lambda-test-python"
        context.aws_request_id = "test-request-id"

        # Act
        response = lambda_function.lambda_handler(event, context)

        # Assert
        self.assertEqual(response["statusCode"], 200)
        body = json.loads(response["body"])
        self.assertEqual(body["message"], "Hello, DevOps Team!")

    def test_lambda_handler_response_structure(self):
        """Test that the response has the correct structure."""
        # Arrange
        event = {"name": "Test"}
        context = Mock()
        context.function_name = "test-function"
        context.aws_request_id = "test-id"

        # Act
        response = lambda_function.lambda_handler(event, context)

        # Assert
        # Check response structure
        self.assertIsInstance(response, dict)
        self.assertIn("statusCode", response)
        self.assertIn("headers", response)
        self.assertIn("body", response)

        # Check headers
        headers = response["headers"]
        self.assertEqual(headers["Content-Type"], "application/json")
        self.assertEqual(headers["Access-Control-Allow-Origin"], "*")

        # Check body structure
        body = json.loads(response["body"])
        required_fields = [
            "message",
            "timestamp",
            "runtime",
            "function_name",
            "request_id",
        ]
        for field in required_fields:
            self.assertIn(field, body)

    def test_lambda_handler_with_none_context(self):
        """Test Lambda handler with None context (local testing scenario)."""
        # Arrange
        event = {"name": "Local Test"}
        context = None

        # Act
        response = lambda_function.lambda_handler(event, context)

        # Assert
        self.assertEqual(response["statusCode"], 200)
        body = json.loads(response["body"])
        self.assertEqual(body["message"], "Hello, Local Test!")
        self.assertEqual(body["function_name"], "lambda-test-python")  # Default value
        self.assertEqual(body["request_id"], "local-test")  # Default value

    def test_lambda_handler_with_various_names(self):
        """Test Lambda handler with various name inputs."""
        test_cases = [
            ("Alice", "Hello, Alice!"),
            ("Bob", "Hello, Bob!"),
            ("", "Hello, !"),
            ("123", "Hello, 123!"),
            ("Special-Name_123", "Hello, Special-Name_123!"),
        ]
        
        for name, expected in test_cases:
            with self.subTest(name=name):
                # Arrange
                event = {"name": name}
                context = Mock()
                context.function_name = "test"
                context.aws_request_id = "test"

                # Act
                response = lambda_function.lambda_handler(event, context)

                # Assert
                body = json.loads(response["body"])
                self.assertEqual(body["message"], expected)


class TestLambdaIntegration(unittest.TestCase):
    """Integration tests for the Lambda function."""

    def test_lambda_handler_full_flow(self):
        """Test the complete Lambda handler flow."""
        # This could test with actual AWS services in a real scenario
        event = {
            "name": "Integration Test",
            "source": "unittest",
            "timestamp": "2025-08-22",
        }
        context = Mock()
        context.function_name = "lambda-test-python"
        context.aws_request_id = "integration-test-id"

        response = lambda_function.lambda_handler(event, context)

        self.assertEqual(response["statusCode"], 200)
        body = json.loads(response["body"])
        self.assertIn("timestamp", body)
        self.assertEqual(body["message"], "Hello, Integration Test!")


class TestLambdaPerformance(unittest.TestCase):
    """Performance tests for the Lambda function."""

    def test_lambda_handler_performance(self):
        """Test Lambda handler performance with multiple calls."""
        event = {"name": "Performance Test"}
        context = Mock()
        context.function_name = "test"
        context.aws_request_id = "perf-test"

        # Measure execution time
        start_time = time.time()

        # Run multiple times
        for _ in range(100):
            response = lambda_function.lambda_handler(event, context)
            self.assertEqual(response["statusCode"], 200)

        end_time = time.time()
        execution_time = end_time - start_time

        # Assert reasonable performance (adjust threshold as needed)
        self.assertLess(execution_time, 1.0)  # Should complete 100 calls in under 1s


if __name__ == "__main__":
    unittest.main()
