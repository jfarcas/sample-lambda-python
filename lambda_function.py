import json
import logging
import os
import uuid
from datetime import datetime
from typing import Any, Dict, Optional

# Configure simple logging for Lambda
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Version information
__version__ = "1.1.0"


def lambda_handler(event: Dict[str, Any], context: Optional[Any]) -> Dict[str, Any]:
    """
    Simple Lambda function for testing deployment workflows
    """
    request_id = context.aws_request_id if context else str(uuid.uuid4())
    
    # Log the incoming event
    logger.info(f"Lambda invocation started - Request ID: {request_id}")
    logger.info(f"Received event: {json.dumps(event)}")

    try:
        # Extract name from event or use default
        name = event.get("name", "World")
        
        # Get current timestamp
        current_time = datetime.now().isoformat()
        
        # Create response body
        response_body = {
            "message": f"Hello, {name}!",
            "timestamp": current_time,
            "version": __version__,
            "function_name": context.function_name if context else "lambda-test-python",
            "request_id": request_id,
            "environment": event.get("environment", "unknown"),
            "source": event.get("source", "unknown")
        }

        # Create response
        response = {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps(response_body, indent=2)
        }

        logger.info(f"Lambda invocation completed successfully - Request ID: {request_id}")
        
        return response

    except Exception as e:
        logger.error(f"Lambda invocation failed - Request ID: {request_id}, Error: {str(e)}")
        
        # Return error response
        error_response = {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "error": "Internal server error",
                "message": str(e),
                "request_id": request_id,
                "version": __version__
            })
        }
        
        return error_response
