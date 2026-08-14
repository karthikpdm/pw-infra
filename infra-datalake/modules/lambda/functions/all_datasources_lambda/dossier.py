import json
import boto3
import os
import time
from botocore.exceptions import ClientError, EndpointConnectionError
from botocore.config import Config

# Set up a custom retry configuration to handle timeouts and retries
RETRY_CONFIG = Config(
    retries={
        'max_attempts': 5,  # Max number of retries
        'mode': 'standard',  # Standard retry mode
    }
)

# Initialize clients with the custom retry config
s3 = boto3.client('s3', config=RETRY_CONFIG)
sns = boto3.client('sns', config=RETRY_CONFIG)

def process_url(url):
    # Dynamically create schema name from URL
    url_path = url.replace("https://", "").replace("/", "_").replace(":", "_")  # Making the URL path safe for filenames
    schema_name = url.split("/")[4] 
    return schema_name

def publish_sns_message(topic_arn, message):
    try:
        response = sns.publish(
            TopicArn=topic_arn,
            Message=json.dumps({'default': message}),
            MessageStructure='json'
        )
        return response
    except (ClientError, EndpointConnectionError) as e:
        raise Exception(f"Failed to publish SNS message: {str(e)}")

def get_s3_object_with_retry(bucket_name, file_key):
    retries = 3
    backoff_time = 60  # Exponential backoff starting at 1 second

    for attempt in range(retries):
        try:
            s3_object = s3.get_object(Bucket=bucket_name, Key=file_key)
            return s3_object
        except (ClientError, EndpointConnectionError) as e:
            # Handle retryable errors
            if attempt < retries - 1:
                print(f"Attempt {attempt + 1} failed: {str(e)}, retrying in {backoff_time} seconds...")
                time.sleep(backoff_time)
                backoff_time *= 2  # Exponential backoff
            else:
                raise Exception(f"Failed to retrieve S3 object after {retries} attempts: {str(e)}")

# Lambda handler function
def dossier_schemas(event):
    bucket_name = os.getenv('dossier_bucket_name')
    file_key = os.getenv('dossier_file_key')

    try:
        # Get the file from S3 with retry logic
        s3_object = get_s3_object_with_retry(bucket_name, file_key)
        file_content = s3_object['Body'].read().decode('utf-8')
        
        # Split file content into a list of URLs
        urls = file_content.splitlines()
        
        schemas = []
        
        # Process each URL in the list
        for url in urls:
            print(f"Processing URL: {url}")
            schema = process_url(url)
            schemas.append(schema)
        
        # Publish success notification
        print('....', os.getenv('SNS_SUCCESS_TOPIC_ARN'))
        success_message = f'Successfully retrieved Dossier schemas: {schemas}'
        publish_sns_message(os.getenv('SNS_SUCCESS_TOPIC_ARN_DOSSIER'), success_message)

        return schemas
    
    except Exception as e:
        error_message = f'Error retrieving DOSSIER schemas: {str(e)}'
        publish_sns_message(os.getenv('SNS_FAILURE_TOPIC_ARN_DOSSIER'), error_message)
        return {
            'statusCode': 500,
            'body': f'Error: {e}'
        }
