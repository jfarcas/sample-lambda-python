import json
import os
import uuid
from datetime import datetime
from typing import Any, Dict, Optional

import boto3
import requests
import structlog
from pydantic import BaseModel, Field
from dateutil import tz
import pytz

# Configure structured logging
structlog.configure(
    processors=[
        structlog.processors.JSONRenderer()
    ],
    wrapper_class=structlog.make_filtering_bound_logger(20),  # INFO level
    context_class=dict,
    logger_factory=structlog.WriteLoggerFactory(),
)
logger = structlog.get_logger()

# Version information
__version__ = "1.1.0"

# AWS clients (initialized lazily)
s3_client = None
ssm_client = None


class LambdaEvent(BaseModel):
    """Pydantic model for Lambda event validation"""
    name: Optional[str] = Field(default="World", description="Name to greet")
    operation: Optional[str] = Field(default="greeting", description="Operation to perform")
    metadata: Optional[Dict[str, Any]] = Field(default_factory=dict)


class LambdaResponse(BaseModel):
    """Pydantic model for Lambda response"""
    statusCode: int = Field(default=200)
    headers: Dict[str, str] = Field(default_factory=lambda: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
    })
    body: str


def get_aws_clients():
    """Initialize AWS clients lazily"""
    global s3_client, ssm_client
    if s3_client is None:
        s3_client = boto3.client('s3')
    if ssm_client is None:
        ssm_client = boto3.client('ssm')
    return s3_client, ssm_client


def get_system_info() -> Dict[str, Any]:
    """Get system and AWS environment information"""
    try:
        # Get timezone-aware timestamp
        utc_now = datetime.now(tz=pytz.UTC)
        local_tz = tz.gettz()
        local_time = utc_now.astimezone(local_tz)
        
        system_info = {
            "timestamp_utc": utc_now.isoformat(),
            "timestamp_local": local_time.isoformat(),
            "python_version": f"Python {os.sys.version.split()[0]}",
            "aws_region": os.environ.get("AWS_REGION", "unknown"),
            "lambda_runtime": os.environ.get("AWS_EXECUTION_ENV", "unknown"),
            "memory_size": os.environ.get("AWS_LAMBDA_FUNCTION_MEMORY_SIZE", "unknown"),
            "request_id": str(uuid.uuid4()),
        }
        
        return system_info
    except Exception as e:
        logger.warning("Failed to get system info", error=str(e))
        return {"error": "Failed to retrieve system information"}


def perform_health_check() -> Dict[str, Any]:
    """Perform basic health checks"""
    health_status = {
        "healthy": True,
        "checks": {}
    }
    
    try:
        # Check AWS connectivity
        s3, ssm = get_aws_clients()
        
        # Simple S3 list buckets check (will work with basic permissions)
        try:
            s3.list_buckets()
            health_status["checks"]["aws_s3"] = "healthy"
        except Exception as e:
            health_status["checks"]["aws_s3"] = f"error: {str(e)}"
            health_status["healthy"] = False
            
        # Check external connectivity
        try:
            response = requests.get("https://httpbin.org/status/200", timeout=5)
            if response.status_code == 200:
                health_status["checks"]["external_connectivity"] = "healthy"
            else:
                health_status["checks"]["external_connectivity"] = f"http_error: {response.status_code}"
        except requests.RequestException as e:
            health_status["checks"]["external_connectivity"] = f"network_error: {str(e)}"
            
    except Exception as e:
        logger.error("Health check failed", error=str(e))
        health_status["healthy"] = False
        health_status["error"] = str(e)
    
    return health_status


def lambda_handler(event: Dict[str, Any], context: Optional[Any]) -> Dict[str, Any]:
    """
    Enhanced Lambda function with realistic dependencies and functionality
    """
    request_id = context.aws_request_id if context else str(uuid.uuid4())
    
    # Log the incoming event with structured logging
    logger.info("Lambda invocation started", 
                request_id=request_id,
                event_keys=list(event.keys()) if event else [],
                function_name=context.function_name if context else "local-test")

    try:
        # Validate event using Pydantic
        validated_event = LambdaEvent(**event)
        
        # Get system information
        system_info = get_system_info()
        
        # Determine operation
        operation = validated_event.operation
        
        if operation == "health":
            # Perform health check
            health_status = perform_health_check()
            response_body = {
                "message": "Health check completed",
                "health": health_status,
                "system": system_info,
                "version": __version__
            }
        else:
            # Default greeting operation
            response_body = {
                "message": f"Hello, {validated_event.name}!",
                "operation": operation,
                "system": system_info,
                "version": __version__,
                "function_name": (
                    context.function_name if context else "lambda-test-python"
                ),
                "request_id": request_id,
                "metadata": validated_event.metadata
            }

        # Create response using Pydantic model
        response = LambdaResponse(
            statusCode=200,
            body=json.dumps(response_body, indent=2)
        )

        logger.info("Lambda invocation completed successfully", 
                   request_id=request_id,
                   response_size=len(response.body))
        
        return response.model_dump()

    except Exception as e:
        logger.error("Lambda invocation failed", 
                    request_id=request_id,
                    error=str(e),
                    error_type=type(e).__name__)
        
        # Return error response
        error_response = LambdaResponse(
            statusCode=500,
            body=json.dumps({
                "error": "Internal server error",
                "message": str(e),
                "request_id": request_id,
                "version": __version__
            })
        )
        
        return error_response.model_dump()
