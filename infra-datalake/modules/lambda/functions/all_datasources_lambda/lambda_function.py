import json
import time
from amcs import amcs_schemas
from dossier import dossier_schemas
from pw import platform_schemas
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

MAX_RETRIES = 3  # Maximum number of retries
RETRY_DELAY = 2  # Initial delay in seconds before retrying (for exponential backoff)

def lambda_handler(event, context):
    datasource = event.get('source_system')
    
    logger.info(f"source system is {datasource}")
    
    # Retry logic with exponential backoff
    attempt = 0
    while attempt < MAX_RETRIES:
        try:
            # Process based on the 'source_system'
            if datasource == 'AMCS':
                return amcs_schemas(event)
            elif datasource == 'Dossier':
                return dossier_schemas(event)
            elif datasource == 'PW':
                return platform_schemas(event)
            else:
                raise ValueError(f"Unsupported data source: {datasource}")
        
        except ValueError as e:
            # Handling specific errors like unsupported data source
            logger.info(f"Error: {str(e)}")
            raise e  # Re-raise the error so AWS Lambda can process it
        except Exception as e:
            # Handling other unexpected errors
            logger.info(f"Error in attempt {attempt + 1}: {str(e)}")
            
            # Exponential backoff logic: Increase the delay after each attempt
            attempt += 1
            if attempt < MAX_RETRIES:
                wait_time = RETRY_DELAY * (2 ** attempt)  # Exponential backoff
                logger.info(f"Retrying in {wait_time} seconds...")
                time.sleep(wait_time)
            else:
                logger.info("Max retries reached. Raising the error.")
                raise e  # After max retries, re-raise the error to fail the Lambda function

