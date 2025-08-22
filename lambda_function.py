import json
import logging
from datetime import datetime
from typing import Any, Dict, Optional

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Version information
__version__ = "1.0.0"


def lambda_handler(event: Dict[str, Any], context: Optional[Any]) -> Dict[str, Any]:
    """
    Simple Lambda function that returns a hello world message
    """
    logger.info(f"Received event: {json.dumps(event)}")

    # Extract name from event or use default
    name = event.get("name", "World")

    # Create response
    response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
        "body": json.dumps(
            {
                "message": f"Hello, {name}!",
                "timestamp": datetime.now().isoformat(),
                "runtime": "Python 3.9",
                "version": __version__,
                "function_name": (
                    context.function_name if context else "lambda-test-python"
                ),
                "request_id": (
                    context.aws_request_id if context else "local-test"
                ),
            }
        ),
    }

    logger.info(f"Response: {json.dumps(response)}")
    return response
