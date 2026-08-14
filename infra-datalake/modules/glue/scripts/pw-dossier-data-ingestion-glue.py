import requests
import json
import boto3
import time
import traceback
import sys
import time
from datetime import datetime
from botocore.exceptions import ClientError
from requests.exceptions import RequestException
from awsglue.transforms import *
from pyspark.sql import functions as F
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql import SparkSession
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.types import StructType, StructField, StringType

# Constants
MAX_RETRIES = 3
INITIAL_BACKOFF_TIME = 1  # in seconds
TIMEOUT = 1800  # in seconds

def get_secret(secret_name):
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager')
    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = json.loads(response['SecretString'])
        return secret['client_id'], secret['client_secret'], secret['grant_type'], secret['scope'], secret['username'], secret['password']
    except ClientError as e:
        raise Exception(f'Error retrieving secret {secret_name}: {e}')

def publish_sns_message(topic_arn, message):
    sns = boto3.client('sns')
    response = sns.publish(
        TopicArn=topic_arn,
        Message=json.dumps({'default': message}),
        MessageStructure='json'
    )
    print('__response__', response)
    return response        

# Function to get the access token with retry logic and exponential backoff
def get_access_token(client_id, client_secret, grant_type, scope, username, password):
    tokenurl = token_url
    payload = {
        'client_id': client_id,
        'client_secret': client_secret,
        'grant_type': grant_type,
        'scope': scope,
        'username': username,
        'password': password
    }
    headers = {'Content-Type': content_type2}

    for attempt in range(MAX_RETRIES):
        try:
            # Make a POST request with timeout
            response = requests.post(tokenurl, data=payload, headers=headers, timeout=TIMEOUT)
            
            if response.status_code == 200:
                token_data = response.json()
                access_token = token_data.get('access_token')
                if access_token:
                    return access_token
                else:
                    raise Exception("Access token not found in response")
            else:
                error_message = f"Error processing token : {response.status_code}"
                publish_sns_message(args['SNS_FAILURE_TOPIC_ARN'], error_message)
                raise Exception(f"Failed to obtain access token. Status code: {response.status_code}, Response: {response.text}")
        except RequestException as e:
            if attempt < MAX_RETRIES - 1:
                backoff_time = INITIAL_BACKOFF_TIME * (2 ** attempt)  # Exponential backoff
                print(f"Error obtaining access token (Attempt {attempt + 1}/{MAX_RETRIES}). Retrying in {backoff_time} seconds...")
                time.sleep(backoff_time)
            else:
                error_message = f"Error processing token: {str(e)}"
                publish_sns_message(args['SNS_FAILURE_TOPIC_ARN'], error_message)
                traceback.print_exc()
                raise Exception(f"Error obtaining access token after {MAX_RETRIES} attempts: {str(e)}")

# Function to extract unique tags from the API response
def extract_unique_tags(data):
    tags_set = set()

    # Iterate over the paths in the response
    for path, path_data in data.get('paths', {}).items():
        if 'get' in path_data:  # Ensure there's a 'get' method
            # Check if the 'tags' key exists and is a list
            if 'tags' in path_data['get']:
                tags_set.update(path_data['get']['tags'])  # Add the tags to the set
    return tags_set

# Function to process schemas with retry logic and exponential backoff
def process_schemas(schema_name, headers):
    
    url = f"{dossier_url}/{schema_name}/swagger/v1/swagger.json"
    total_row_count = 0
    
    for attempt in range(MAX_RETRIES):
        try:
            # Fetch tables from the API
            table_set = fetch_tables(url, headers)
            print("tables:", table_set)
            for table in table_set:
                time.sleep(5)
                new_row_count = 0
                url2 = f"{dossier_url}/{schema_name}/{table}/"
                
                # Fetch data for each table with timeout
                tableresponse = requests.get(url2, headers=headers, timeout=TIMEOUT)
                
                if tableresponse.status_code == 200:
                    new_row_count = save_table(schema_name, table, tableresponse)
                    print('___new_row_count___ =', new_row_count)
                
                if isinstance(new_row_count, int):
                    total_row_count += new_row_count
                print('___total_row_count___ =', total_row_count)
            return total_row_count
        except RequestException as e:
            if attempt < MAX_RETRIES - 1:
                backoff_time = INITIAL_BACKOFF_TIME * (2 ** attempt)  # Exponential backoff
                print(f"Error processing schema (Attempt {attempt + 1}/{MAX_RETRIES}). Retrying in {backoff_time} seconds...")
                time.sleep(backoff_time)
            else:
                error_message = f"Error processing schema: {str(e)}"
                publish_sns_message(args['SNS_FAILURE_TOPIC_ARN'], error_message)
                traceback.print_exc()
                raise Exception(f"Error processing schema after {MAX_RETRIES} attempts: {str(e)}")

#------------------------------------------------------------------------------------------------------------#
def load_previous_hashes(schema_name,table_name):
    previous_hashes_path = f"{hashes_path}/{schema_name}/{table_name}/"
    schema = StructType([StructField("row_hash", StringType(), True)])

    try:
        previous_hashes_df = spark.read.parquet(previous_hashes_path, header=True).repartition(5)
        return previous_hashes_df
    except Exception as e:
        print(f"Could not load previous hashes for {table_name}: {str(e)}")
        return spark.createDataFrame([], schema)
#------------------------------------------------------------------------------------------------------------#
def save_current_hashes(current_hashes_df,schema_name, table_name):
    
    current_hashes_path = f"{hashes_path}/{schema_name}/{table_name}/"
    current_hashes_df.repartition(1).write.parquet(current_hashes_path, mode="append", compression="snappy")

#------------------------------------------------------------------------------------------------------------#

def get_md5_hash(df):
    # Handle NULLs and trim whitespace
    hash_col = F.concat_ws("", *[
        F.trim(F.coalesce(F.col(column).cast("string"), F.lit("NULL"))) 
        for column in sorted(df.columns)  # Sort columns to ensure consistent order
    ])
    return df.withColumn("row_hash", F.md5(hash_col))

#------------------------------------------------------------------------------------------------------------#
# Fetch tables from the API with retry logic and exponential backoff
def fetch_tables(url, headers):
    for attempt in range(MAX_RETRIES):
        try:
            response = requests.get(url, headers=headers, timeout=TIMEOUT)
            if response.status_code == 200:
                data = response.json()
                table_set = extract_unique_tags(data)
                return table_set
            else:
                raise Exception(f"Failed to fetch tables. Status code: {response.status_code}, Response: {response.text}")
        except RequestException as e:
            if attempt < MAX_RETRIES - 1:
                backoff_time = INITIAL_BACKOFF_TIME * (2 ** attempt)  # Exponential backoff
                print(f"Error fetching tables (Attempt {attempt + 1}/{MAX_RETRIES}). Retrying in {backoff_time} seconds...")
                time.sleep(backoff_time)
            else:
                error_message = f"Error fetching tables: {str(e)}"
                publish_sns_message(args['SNS_FAILURE_TOPIC_ARN'], error_message)
                traceback.print_exc()
                raise Exception(f"Error fetching tables after {MAX_RETRIES} attempts: {str(e)}")

# Function to save table data to S3
def save_table(schema_name, table_name, tableresponse):
    if tableresponse.status_code == 200:
        data = tableresponse.json()
        if data:
            df = spark.read.json(spark.sparkContext.parallelize([json.dumps(record) for record in data]))
            df = df.repartition(5)  
            previous_hashes_df = load_previous_hashes(schema_name,table_name)
            df = get_md5_hash(df)
            new_rows_df = df.join(previous_hashes_df, on="row_hash", how="left_anti")
            row_count = new_rows_df.count()
            
            # Convert DataFrame to Glue DynamicFrame
            new_rows_df = new_rows_df.repartition(1)
            
            print("df count:", row_count)
            if not new_rows_df.rdd.isEmpty():
                save_current_hashes(new_rows_df.select("row_hash"), schema_name, table_name)
            new_rows_df = new_rows_df.withColumn('pwIngestionTime', F.date_format(F.current_timestamp(), "dd-MM-yyyy:HH:mm"))
            dynamic_frame = DynamicFrame.fromDF(new_rows_df, glueContext, "dynamic_frame")

            # Define the S3 output path
            s3_output_path = schemas_path
            current_date_str = datetime.now().strftime('%Y-%m-%d')
            output_path = f"{s3_output_path}/{schema_name}/{table_name}/{current_date_str}/"
            glueContext.write_dynamic_frame.from_options(
                dynamic_frame,
                connection_type="s3",
                connection_options={"path": output_path},
                format="parquet",
                format_options={"compression": "SNAPPY"}
            )

            print("Data successfully saved to S3.")
            return row_count
        else:
            print("No data found in the API response.")
    else:
        print(f"Failed to fetch data from API. Status code: {tableresponse.status_code}, Response: {tableresponse.text}")

# Start of the main execution
start_time = datetime.now()
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'SCHEMA_NAME', 'SECRET_NAME', 'SNS_SUCCESS_TOPIC_ARN', 'SNS_FAILURE_TOPIC_ARN','dossier_url', 'schemas_path', 'hashes_path', 
    'token_url', 'content_type', 'content_type2'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "LEGACY")
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
secret_name = args['SECRET_NAME']
schema_name = args['SCHEMA_NAME']
dossier_url = args['dossier_url']
schemas_path = args['schemas_path']
hashes_path = args['hashes_path']
token_url = args['token_url']
content_type = args['content_type']
content_type2 = args['content_type2']
schema_results = {}

# Retrieve secrets
client_id, client_secret, grant_type, scope, username, password = get_secret(secret_name)

# Get access token
access_token = get_access_token(client_id, client_secret, grant_type, scope, username, password)
headers = {
    'Authorization': f'Bearer {access_token}',
    'Content-Type': content_type
}

# Process schemas
row_count = process_schemas(schema_name, headers)
print('####row_count####')
schema_results[schema_name] = row_count

end_time = datetime.now()

# Calculate the execution time in minutes
execution_time = (end_time - start_time).total_seconds() / 60  # in minutes
execution_time_rounded = round(execution_time, 2)
execution_time_min = f"{execution_time_rounded} min"

# Add execution time to the results
schema_results['execution_time'] = execution_time_min

# Upload results to S3 if valid
if len(schema_results) == 2:
    s3 = boto3.client('s3')
    s3.put_object(
        Bucket='dossier-layer',
        Key=f'data/counts/{schema_name}/{schema_name}.json',
        Body=json.dumps(schema_results)
    )
    print("S3 object successfully uploaded.")
else:
    print("The dictionary does not have exactly 2 keys. Skipping S3 upload.")

# Notify success for the entire schema processing
success_message = f"Successfully processed schema: {schema_name}"
print(success_message)
publish_sns_message(args['SNS_SUCCESS_TOPIC_ARN'], success_message)
