import json
import csv
import boto3
import os
import logging
from datetime import datetime

# S3 Client Initialization
s3_client = boto3.client('s3')

# Set up logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)
log_handler = logging.StreamHandler()
log_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
log_handler.setFormatter(log_formatter)
logger.addHandler(log_handler)
c_bucket_name = os.getenv('cleanced_bucket_name')
r_bucket_name = os.getenv('raw_bucket_name')
#data_source = event.get("data_source")


              
def publish_sns_message(topic_arn, message):
    sns = boto3.client('sns')
    response = sns.publish(
        TopicArn=topic_arn,
        Message=json.dumps({'default': message}),
        MessageStructure='json'
    )
    return response

def fetch_folders(base_path):
    try:
        if base_path.startswith("s3://"):
            base_path = base_path[5:]  # Remove 's3://'

        path_parts = base_path.split("/", 1)

        if len(path_parts) < 2:
            raise ValueError(f"Base path {base_path} is not valid. It should contain both a bucket name and a prefix.")
        
        bucket = path_parts[0]
        prefix = path_parts[1]

        logger.info(f"Listing folders under {base_path}")
        response = s3_client.list_objects_v2(Bucket=bucket, Prefix=prefix, Delimiter='/')

        if 'CommonPrefixes' not in response:
            logger.warning(f"No folders found under {base_path}")
            return []

        folder_list = [prefix['Prefix'].split('/')[-2] for prefix in response['CommonPrefixes']]
        logger.info(f"Found {len(folder_list)} folders under {base_path}")
        return folder_list
    
    except Exception as e:
        logger.error(f"Error fetching folders from S3: {e}")
        raise

def generate_folder_dict(data_source):
    try:
        # Based on the data source, pick the appropriate base path
        source = data_source.lower()
        base_path = f's3://{r_bucket_name}/{source}/schemas/'
        # Get all folder names (schemas) under the selected base path
        schema_names = fetch_folders(base_path)
        logger.info(f"Fetched {len(schema_names)} schemas for data source {data_source}")

        folder_dict = {}
        current_date = datetime.now().strftime('%Y-%m-%d')

        # Iterate over each schema
        for schema in schema_names:
            schema_dict = {}
            logger.info(f"Processing schema: {schema}")
            
            # Fetch table folders for the current schema
            table_folders = fetch_folders(f"{base_path}{schema}/")
            logger.info(f"Found {len(table_folders)} tables in schema {schema}")
            
            # For each table in the schema, create the dictionary mapping to the S3 path
            for table in table_folders:
                schema_dict[table] = f"{base_path}{schema}/{table}/"
            
            folder_dict[schema] = schema_dict
        
        logger.info(f"Generated folder dictionary for {data_source}")
        return folder_dict

    except Exception as e:
        logger.error(f"Error generating folder dictionary for data source {data_source}: {e}")
        raise

def save_to_csv(data_source, schema_name, folder_dict):
    try:
        # Convert folder_dict to CSV format and save it to S3
        csv_data = []
        source = data_source.lower()
        for schema, tables in folder_dict.items():
            for table, path in tables.items():
                csv_data.append([table, path])
        
        # Write to a temporary file
        logger.info(f"Saving {schema_name} folder data to CSV")
        tmp_file_path = f"/tmp/{schema_name}.csv"
        with open(tmp_file_path, "w", newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerows(csv_data)
        
        # Upload to S3 in the respective location
        s3_client.upload_file(tmp_file_path, c_bucket_name, f"{source}/metadata/{schema_name}/{schema_name}.csv")
        logger.info(f"CSV for {schema_name} saved to S3 successfully")

    except Exception as e:
        logger.error(f"Error saving {schema_name} folder data to CSV: {e}")
        raise

def lambda_handler(event, context):
    try:
        # Extract data_source from event
        data_source = event.get("data_source")
        #data_source = 'amcs'

        if not data_source:
            logger.error("data_source is required in the event object")
            raise ValueError("data_source is required in the event object")
        
        logger.info(f"Processing data source: {data_source}")

        # Generate the folder dictionary for the given data source
        folder_dict = generate_folder_dict(data_source)
        
        schema_list = []

        # For each schema in the folder dict, save the schema to CSV
        for schema_name, schema_data in folder_dict.items():
            save_to_csv(data_source, schema_name, {schema_name: schema_data})
            schema_list.append(schema_name)
            
        logger.info('CSV files created and saved to S3 successfully.')
        success_message = f'retrived s3 paths successfully for the DATA_SOURCE: {data_source}'
        publish_sns_message(os.getenv('SNS_SUCCESS_TOPIC_ARN'), success_message)

        return {
            'statusCode': 200,
            'body': {
                'schemas': schema_list
            }
        }

    except Exception as e:
        logger.error(f"Error in lambda_handler: {e}")
        error_message = f'retrived s3 paths successfully for the DATA_SOURCE: {data_source}'
        publish_sns_message(os.getenv('SNS_FAILURE_TOPIC_ARN'), error_message)
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }
