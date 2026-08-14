import boto3
import csv
import io
import json
import os
import time  # To add delay between retries
import random  # For exponential backoff

# Initialize the S3 client
s3_client = boto3.client('s3')

# Retry configuration (define MAX_RETRIES and RETRY_DELAY)
MAX_RETRIES = 3  # Set maximum number of retries
RETRY_DELAY = 5  # Set delay between retries (in seconds)
def publish_sns_message(topic_arn, message):
    sns = boto3.client('sns')
    response = sns.publish(
        TopicArn=topic_arn,
        Message=json.dumps({'default': message}),
        MessageStructure='json'
    )
    return response

def platform_schemas(event):
    # Define your S3 bucket and file path
    bucket_name = os.getenv('pf_bucket_name')
    file_key = os.getenv('pf_file_key')
    
    attempt = 0
    while attempt < MAX_RETRIES:
        try:
            # Retrieve the CSV file from S3
            response = s3_client.get_object(Bucket=bucket_name, Key=file_key)
            
            # Get the file content as a byte stream
            file_content = response['Body'].read()
            
            # Decode byte stream to string
            file_content_str = file_content.decode('utf-8')
            
            # Create a CSV reader object
            csv_reader = csv.reader(file_content_str.splitlines())
            
            # Skip the header row (first row)
            header = next(csv_reader)
            
            # Extract values from the first (and only) column and add to a list
            schema_list = [row[0] for row in csv_reader]
            
            # Print or return the list of values
            print(f"Extracted values: {schema_list}")
            success_message = f'Successfully retrieved DynamoDB tables: {schema_list}'
            publish_sns_message(os.getenv('SNS_SUCCESS_TOPIC_ARN_PF'), success_message)
            
            return schema_list
        
        except Exception as e:
            attempt += 1
            print(f"Attempt {attempt} failed with error: {str(e)}")
            error_message = f'Error retrieving AMCS schemas: {str(e)}'
            publish_sns_message(os.getenv('SNS_FAILURE_TOPIC_ARN_PF'), error_message)
            
            # If we've reached the max retries, return an error
            if attempt >= MAX_RETRIES:
                return {
                    'statusCode': 500,
                    'body': {
                        'message': 'Error processing the CSV file after multiple attempts',
                        'error': str(e)
                    }
                }
            
            # Implement exponential backoff
            backoff_time = RETRY_DELAY * (2 ** attempt) + random.randint(0, 5)
            print(f"Retrying in {backoff_time} seconds...")
            time.sleep(backoff_time)
