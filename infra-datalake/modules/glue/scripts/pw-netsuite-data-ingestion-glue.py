import json
import base64
import requests
import jwt
import datetime
import boto3
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.serialization import load_pem_private_key
from pyspark.sql.types import StructType, StructField, StringType, TimestampType
from pyspark.sql.functions import current_timestamp, lit
import requests
import time
import csv
import io
from datetime import timezone
from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
import sys

# NetSuite Credentials and URLs
CONSUMER_KEY = '45be9323c5d47f8052e398c3e5013ad4e0d2929478d27927a9ff334103f541eb'
OAUTH2_KID = 'G38serLt9Lw91EcGO-FdzrR2rQk511iH4e8dE6T4rRw'  # Kid (Key ID)
PRIVATE_KEY = '''-----BEGIN PRIVATE KEY-----
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
XruofZtbrCrfCRK+vHi/+WQ=
-----END PRIVATE KEY-----'''

TOKEN_URL = 'https://6731274-sb1.suitetalk.api.netsuite.com/services/rest/auth/oauth2/v1/token'
SUITEQL_URL = 'https://6731274-sb1.suitetalk.api.netsuite.com/services/rest/query/v1/suiteql'
config_bucket = 'pw-s3-dev-datalake-raw'
output_bucket = 'pw-s3-dev-datalake-raw'
control_table_bucket = 'pw-s3-dev-datalake-raw'
config_key = 'netsuite/misc/netsuite_table_control_config.csv'
control_table_key = 'netsuite/hashes/sync_timestamps/netsuite_table_sync_timestamps.csv'
# S3 Bucket and Folder where data will be saved
S3_BUCKET = 'pw-s3-dev-datalake-raw'
S3_PREFIX = 'netsuite/schemas/'

# JWT Scopes
SCOPES = ["restlets", "rest_webservices"]

# Configuration for pagination
BATCH_SIZE = 1000
MAX_RECORDS = 20000000  # Set a reasonable upper limit to prevent infinite loops

# Step 1: Load the private key
def load_private_key(private_key_str):
    # Clean up the private key string to remove any extra spaces or newlines
    private_key_str = private_key_str.strip()
    
    # Ensure the key is in PEM format by checking for BEGIN/END markers
    if not (private_key_str.startswith("-----BEGIN PRIVATE KEY-----") and private_key_str.endswith("-----END PRIVATE KEY-----")):
        raise ValueError("Private key is not in PEM format")
    
    # Decode the private key (just in case it's base64-encoded)
    private_key_bytes = private_key_str.encode()
    
    # Load the private key
    private_key = load_pem_private_key(private_key_bytes, password=None)
    return private_key

# Step 2: Create JWT
def create_jwt(private_key, kid):
    # JWT Claims
    current_time = datetime.datetime.utcnow()
    expiration_time = current_time + datetime.timedelta(hours=2)
    print('Creating JWT token')
    
    claims = {
        "iss": CONSUMER_KEY,
        "aud": TOKEN_URL,
        "iat": current_time,
        "exp": expiration_time,
        "scope": ' '.join(SCOPES)
    }

    # Create and sign the JWT
    token = jwt.encode(claims, private_key, algorithm="RS256", headers={"kid": kid})
    return token

# Step 3: Request Access Token from NetSuite using JWT
def get_access_token():
    try:
        # Load private key
        private_key_obj = load_private_key(PRIVATE_KEY)
        print('Private key loaded successfully')
        
        # Create JWT
        client_assertion = create_jwt(private_key_obj, OAUTH2_KID)
        print('JWT token created successfully')

        # Prepare the POST request
        form_data = {
            'grant_type': 'client_credentials',
            'client_assertion_type': 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
            'client_assertion': client_assertion
        }

        # Send the POST request to NetSuite token URL
        headers = {'Content-Type': 'application/x-www-form-urlencoded'}
        response = requests.post(TOKEN_URL, data=form_data, headers=headers)
        print(f'Token request response status: {response.status_code}')

        if response.status_code == 200:
            # Parse and return the access token
            token_data = response.json()
            print('Access token retrieved successfully')
            return token_data['access_token']
        else:
            print(f"Error fetching token: {response.status_code} - {response.text}")
            return None

    except Exception as e:
        print(f"An error occurred while fetching the token: {e}")
        return None
        
def read_control_table(bucket, key):
    """
    Reads or creates control table from S3
    Control table format: database_name,table_name,last_sync_timestamp
    """
    s3_client = boto3.client('s3')
    
    try:
        response = s3_client.get_object(Bucket=bucket, Key=key)
        csv_content = response['Body'].read().decode('utf-8')
        
        control_records = {}
        csv_reader = csv.DictReader(io.StringIO(csv_content))
        print('--inside read_control_table---')
        for row in csv_reader:
            table_key = f"{row['database_name']}.{row['table_name']}"
            control_records[table_key] = row['last_sync_timestamp']
            
        return control_records
        
    except s3_client.exceptions.NoSuchKey:
        # Control table doesn't exist yet
        print("Control table not found. Will create new one.")
        return {}
    except Exception as e:
        print(f"Error reading control table: {str(e)}")
        raise
    
def update_control_table(bucket, key, control_records):
    """
    Updates control table in S3 with latest sync timestamps
    """
    s3_client = boto3.client('s3')
    
    # Prepare CSV content
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(['database_name', 'table_name', 'last_sync_timestamp'])
    
    for table_key, timestamp in control_records.items():
        db_name, table_name = table_key.split('.')
        writer.writerow([db_name, table_name, timestamp])
    
    # Upload to S3
    s3_client.put_object(
        Bucket=bucket,
        Key=key,
        Body=output.getvalue().encode('utf-8')
    )

def read_table_config_from_s3(bucket, key):
    """
    Reads table configuration from S3 CSV file
    """
    s3_client = boto3.client('s3')
    
    response = s3_client.get_object(Bucket=bucket, Key=key)
    csv_content = response['Body'].read().decode('utf-8')
    
    tables_config = []
    csv_reader = csv.DictReader(io.StringIO(csv_content))
    
    for row in csv_reader:
        tables_config.append({
            'database_name': row['database_name'],
            'table_name': row['table_name']
        })
    print('--inside read_table_config_from_s3---',tables_config)
    return tables_config

# Step 4: Fetch data from NetSuite using the access token with pagination
def fetch_all_data_from_netsuite(access_token, table_name,last_sync_timestamp):
    try:
        all_records = []
        offset = 0
        has_more = True
        total_fetched = 0
        
        print(f"Starting to fetch data from NetSuite table: {table_name}")
        if last_sync_timestamp:
            query = f"""SELECT * FROM {table_name} WHERE lastmodifieddate > '{last_sync_timestamp}'"""
            print('--inside fetch_netsuite_records()1---',last_sync_timestamp)
        else:
            query = f'SELECT * FROM {table_name}'
        # Continue fetching until we have all records or hit our max limit
        while has_more and total_fetched < MAX_RECORDS:
            batch = fetch_data_batch(access_token, query, offset, BATCH_SIZE)
            
            if not batch or 'items' not in batch or not batch['items']:
                print(f"No more records to fetch or empty response at offset {offset}")
                has_more = False
                return datetime.datetime.now().strftime('%m-%d-%Y')
                
            records_count = len(batch['items'])
            all_records.extend(batch['items'])
            total_fetched += records_count
            
            print(f"Fetched {records_count} records. Total: {total_fetched}. Offset: {offset}")
            
            # If we got fewer records than the batch size, we've reached the end
            if records_count < BATCH_SIZE:
                has_more = False
            
            offset += BATCH_SIZE
        
        print(f"Completed fetching {total_fetched} records from {table_name}")
        
        # Return both the combined records and metadata
        return {"items": all_records},datetime.datetime.now().strftime('%m-%d-%Y')
        

    except Exception as e:
        print(f"An error occurred while fetching all data: {e}")
        return None

# Helper function to fetch a single batch of data
def fetch_data_batch(access_token, query, offset, limit):
    try:
        # Define params and payload for this specific batch
        params = {"limit": limit, "offset": offset}
        payload = {"q": query}
        
        headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/json',
            'Prefer': 'transient'
        }
        
        response = requests.post(SUITEQL_URL, params=params, json=payload, headers=headers)
        print('inside bactch ()*****')

        if response.status_code == 200:
            data = response.json()
            return data
        else:
            print(f"Error fetching data batch: {response.status_code} - {response.text}")
            return None

    except Exception as e:
        print(f"An error occurred while fetching data batch: {e}")
        return None

# Step 5: Save data to S3
def save_data_to_s3(data, bucket, prefix, table_name):
    try:
        # Initialize the S3 client
        s3_client = boto3.client('s3')
        print('inside save s3 ()*****')
        # Create a timestamp for the filename
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        file_name = f'{prefix}{table_name}_{timestamp}.parquet'

        # Convert the data to JSON and upload to S3
        s3_client.put_object(
            Bucket=bucket,
            Key=file_name,
            Body=json.dumps(data),
            ContentType='application/json'
        )
        print(f"Data successfully saved to S3 at {file_name}")
        return file_name

    except Exception as e:
        print(f"An error occurred while saving data to S3: {e}")
        return None

# AWS Glue Script Execution
def glue_job():
    # Step 1: Get the access token
    access_token = get_access_token()
    tables_config = read_table_config_from_s3(config_bucket, config_key)
    control_records = read_control_table(control_table_bucket, control_table_key)

    if access_token:
        # Process each table
        for table_config in tables_config:
            db_name = table_config['database_name']
            table_name = table_config['table_name']
            table_key = f"{db_name}.{table_name}"
            last_sync_timestamp = control_records.get(table_key)

            # Step 2: Fetch all data from NetSuite using pagination
            records,new_sync_timestamp = fetch_all_data_from_netsuite(access_token, table_name,last_sync_timestamp)
            control_records[table_key] = new_sync_timestamp
       
            if records:
                # Step 3: Save the data to S3
                file_path = save_data_to_s3(records, S3_BUCKET, S3_PREFIX, table_name)
                
                print(f"Table {table_name} successfully processed and saved to {file_path}")
            
            else:
                print(f"Error fetching data for table {table_name}.")
        if new_sync_timestamp:
                update_control_table(control_table_bucket, control_table_key, control_records)    
    else:
        print("Failed to get access token.")

# Trigger the Glue job function
if __name__ == "__main__":
    glue_job()