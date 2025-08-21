import json
import logging
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Simple Lambda function that returns a hello world message
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Extract name from event or use default
    name = event.get('name', 'World')
    
    # Create response
    response = {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'message': f'Hello, {name}!',
            'timestamp': datetime.now().isoformat(),
            'runtime': 'Python 3.9',
            'function_name': context.function_name if context else 'lambda-test-python',
            'request_id': context.aws_request_id if context else 'local-test'
        })
    }
    
    logger.info(f"Response: {json.dumps(response)}")
    return response