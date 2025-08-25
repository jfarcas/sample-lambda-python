import json
import unittest
from unittest.mock import Mock
from lambda_function import lambda_handler


class TestLambdaFunction(unittest.TestCase):

    def test_hello_world_default(self):
        """Test lambda function with default name"""
        event = {}
        context = Mock()
        context.function_name = "lambda-test-python"
        context.aws_request_id = "test-request-123"

        response = lambda_handler(event, context)

        self.assertEqual(response["statusCode"], 200)

        body = json.loads(response["body"])
        self.assertIn("Hello, World!", body["message"])

    def test_hello_world_with_name(self):
        """Test lambda function with custom name"""
        event = {"name": "Alice"}
        context = Mock()
        context.function_name = "lambda-test-python"
        context.aws_request_id = "test-request-456"

        response = lambda_handler(event, context)

        self.assertEqual(response["statusCode"], 200)

        body = json.loads(response["body"])
        self.assertIn("Hello, Alice!", body["message"])

    def test_response_structure(self):
        """Test response has correct structure"""
        event = {}
        context = None

        response = lambda_handler(event, context)

        self.assertIn("statusCode", response)
        self.assertIn("headers", response)
        self.assertIn("body", response)

        body = json.loads(response["body"])
        self.assertIn("message", body)


if __name__ == "__main__":
    unittest.main()