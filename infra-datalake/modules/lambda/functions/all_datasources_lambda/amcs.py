import pymssql
import logging
import os
import boto3
import json
from botocore.exceptions import ClientError

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_secret(amcs_secret_name):
    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager')
    
    try:
        response = client.get_secret_value(SecretId=amcs_secret_name)
        secret = json.loads(response['SecretString'])
        return secret['user_name'], secret['password'], secret['server_name']
    except ClientError as e:
        logger.error(f'Error retrieving secret {amcs_secret_name}: {e}')
        raise e

def publish_sns_message(topic_arn, message):
    sns = boto3.client('sns')
    response = sns.publish(
        TopicArn=topic_arn,
        Message=json.dumps({'default': message}),
        MessageStructure='json'
    )
    return response
    


def amcs_schemas(event):
    # Retrieve the database name from the environment variable
    database = os.getenv('db_name')
    if not database:
        logger.error('Database name environment variable not set.')
        return {
            'statusCode': 400,
            'body': 'Error: Database name environment variable not set.'
        }

    # Secret name from AWS Secrets Manager
    amcs_secret_name = os.getenv('amcs_secret_name')
    schema_env = os.getenv('excluded_schema_list')
    if schema_env:
        ex_schema_list = [schema.strip().strip("'") for schema in schema_env.split(',')]
    else:
        logger.error('Schema names environment variable not set.')
        return {
            'statusCode': 400,
            'body': 'Error: Schema names environment variable not set.'
        }

    try:
        # Get username and password from Secrets Manager
        username, password, server = get_secret(amcs_secret_name)

        # Establish a connection to the database
        conn = pymssql.connect(server=server, user=username, password=password, database=database)
        cursor = conn.cursor()

        # Prepare the excluded schemas string
        excluded_schemas_str = ', '.join(f"'{schema}'" for schema in ex_schema_list)
        sql_query = f"SELECT name FROM sys.schemas WHERE name NOT IN ({excluded_schemas_str})"
        
        # Execute the query
        cursor.execute(sql_query)

        # Fetch and log the results
        schemas = cursor.fetchall()
        schema_list = [schema[0] for schema in schemas]
        
        logger.info(f'Retrieved {len(schema_list)} schemas')

        # Publish success notification
        success_message = f'Successfully retrieved AMCS schemas: {schema_list}'
        publish_sns_message(os.getenv('SNS_SUCCESS_TOPIC_ARN_AMCS'), success_message)

        return schema_list
    except Exception as e:
        logger.error(f'Error: {e}')
        error_message = f'Error retrieving AMCS schemas: {str(e)}'
        publish_sns_message(os.getenv('SNS_FAILURE_TOPIC_ARN_AMCS'), error_message)
        return {
            'statusCode': 500,
            'body': f'Error: {e}'
        }
    finally:
        if 'conn' in locals():
            conn.close()
