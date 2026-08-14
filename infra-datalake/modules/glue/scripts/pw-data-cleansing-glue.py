import boto3
import pandas as pd
import re
import sys
import json
import logging
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from awsglue.dynamicframe import DynamicFrame
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.sql import functions as F
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, trim, regexp_replace
from datetime import datetime
from pyspark.sql import SparkSession
from botocore.exceptions import ClientError

# Set up logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)
log_handler = logging.StreamHandler(sys.stdout)
log_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
log_handler.setFormatter(log_formatter)
logger.addHandler(log_handler)

# Initialize GlueContext and SparkContext
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# Glue job arguments
args = getResolvedOptions(sys.argv, ['JOB_NAME','SCHEMA_NAME','DATA_SOURCE','SCHEMA_PATH','BUCKET_NAME', 'SNS_SUCCESS_TOPIC_ARN', 'SNS_FAILURE_TOPIC_ARN'])
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
schema_name = args['SCHEMA_NAME']
source = args['DATA_SOURCE']
schema_path = args['SCHEMA_PATH']
bucket_name = args['BUCKET_NAME']
data_source = source.lower()

logger.info(f"Starting Glue Job with schema: {schema_name} and data source: {data_source}")


def publish_sns_message(topic_arn, message):
    sns = boto3.client('sns')
    response = sns.publish(
        TopicArn=topic_arn,
        Message=json.dumps({'default': message}),
        MessageStructure='json'
    )
    return response


# Read the CSV file into a DynamicFrame
csv_path = f"s3://{bucket_name}/{data_source}/metadata/{schema_name}/"
logger.info(f"Reading data from: {csv_path}")
try:
    csv_dynamic_frame = glueContext.create_dynamic_frame.from_options(
        connection_type="s3", 
        connection_options={"paths": [csv_path]}, 
        format="csv",
        format_options={"withHeader": True}
    )
except Exception as e:
    logger.error(f"Error reading CSV from S3: {e}")
    sys.exit(1)

# Convert to DataFrame to handle CSV parsing
df = csv_dynamic_frame.toDF()

# Iterate over each row and get key-value pairs
s3_dict = {}
for row in df.rdd.collect():
    key, value = row
    s3_dict[key] = value
print('__dictionary__',s3_dict)

# S3 dictionary
#s3_dict = {"dimCustomer": "s3://pw-s3-dev-datalake-raw/amcs/schemas/common/dimCustomer/"}


def insert_item_to_dynamodb(table_name: str, item: dict):

    # Initialize DynamoDB client
    dynamodb = boto3.resource('dynamodb')
    
    # Reference to the DynamoDB table
    table = dynamodb.Table(table_name)
    
    try:
        # Insert the item into the table
        response = table.put_item(Item=item)
        print("Item successfully inserted:", response)
        return response
    except ClientError as e:
        print(f"Error inserting item: {e.response['Error']['Message']}")
        return None

#-----------------------------------------------------------------------------------------#

# Clean null columns
def clean_null_columns(read_df):
    try:
        columns_to_keep = [
            col for col in read_df.columns
            if read_df.filter(
                (F.col(col).isNotNull()) &         
                (F.col(col) != "") &                
                (F.col(col) != "null")             
            ).count() > 0
        ]
        df_nonulls = read_df.select(*columns_to_keep)
        print("clean_null_columns done__")
        return df_nonulls
    except Exception as e:
        logger.error(f"Error cleaning null columns: {e}")
        raise

#-----------------------------------------------------------------------------------------#

# Clean null rows
def clean_null_rows(df):
    try:
        row_has_valid_data = F.lit(False)
        for col_name in df.columns:
            valid_value = (
                F.col(col_name).isNotNull() &          
                (F.col(col_name) != "") &             
                (F.col(col_name).cast("string") != "null")  
            )
            row_has_valid_data = row_has_valid_data | valid_value
        
        df_nullrows_cleaned = df.filter(row_has_valid_data)
        print("df_nullrows_cleaned done__")
        return df_nullrows_cleaned
    except Exception as e:
        logger.error(f"Error cleaning null rows: {e}")
        raise

#-----------------------------------------------------------------------------------------#

'''def email_validation(df: DataFrame, email_columns: list) -> (DataFrame, DataFrame):
    email_regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    try:
        # Initialize empty DataFrames for valid and invalid emails
        valid_email_df = df
        incorrect_email_df = df
        #email_columns_list = [item.lower() for item in email_columns]
        
        for email_col in email_columns:
            valid_email_mask = col(email_col).rlike(email_regex)
            valid_email_df = valid_email_df.filter(valid_email_mask)
            incorrect_email_df = incorrect_email_df.filter(~valid_email_mask)
        
        return valid_email_df, incorrect_email_df
    
    except Exception as e:
        logger.error(f"Error validating emails: {e}")
        raise'''
    
def email_validation(df: DataFrame, email_columns: list) -> (DataFrame, DataFrame):
    email_regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    try:
        # Initialize empty DataFrames for valid and invalid emails
        valid_email_df = df
        incorrect_email_df = df
        
        for email_col in email_columns:
            # Check for valid emails using regex, and allow null/empty to be valid
            valid_email_mask = (F.col(email_col).isNotNull()) & (F.col(email_col) != '') & F.col(email_col).rlike(email_regex)
            
            # Filter rows where email is valid (non-null, non-empty, and matches regex)
            valid_email_df = valid_email_df.filter(valid_email_mask | F.col(email_col).isNull() | (F.col(email_col) == ''))
            
            # Filter rows where email is invalid (doesn't match regex)
            incorrect_email_df = incorrect_email_df.filter(~valid_email_mask & (F.col(email_col).isNotNull()) & (F.col(email_col) != ''))
            print('__email done__')
        
        return valid_email_df, incorrect_email_df
    
    except Exception as e:
        logger.error(f"Error validating emails: {e}")
        raise

#-----------------------------------------------------------------------------------------#

'''def contact_validation(df: DataFrame, phone_columns: list) -> (DataFrame, DataFrame):
    contact_regex = r'^\+(\d{1,4})[\s\-]?\d{1,4}[\s\-]?\d{1,4}[\s\-]?\d{1,4}$'
    
    try:
        
        # Initialize empty DataFrames for valid and invalid emails
        valid_contact_df = df
        incorrect_contact_df = df
        #phone_columns_list = [item.lower() for item in phone_columns]
        for phone_col in phone_columns:
            valid_phone_mask = col(phone_col).rlike(contact_regex)
            valid_contact_df = valid_contact_df.filter(valid_phone_mask)
            incorrect_contact_df = incorrect_contact_df.filter(~valid_phone_mask)
        
        return valid_phone_df, incorrect_contact_df
    
    except Exception as e:
        logger.error(f"Error validating contacts: {e}")
        raise'''
        
def contact_validation(df: DataFrame, phone_columns: list) -> (DataFrame, DataFrame):
    contact_regex = r'^\+(\d{1,4})[\s\-]?\d{1,4}[\s\-]?\d{1,4}[\s\-]?\d{1,4}$'
    
    try:
        # Initialize empty DataFrames for valid and invalid contacts
        valid_contact_df = df
        incorrect_contact_df = df
        
        for phone_col in phone_columns:
            # Check for valid phone numbers using regex, and allow null/empty to be valid
            valid_phone_mask = (F.col(phone_col).isNotNull()) & (F.col(phone_col) != '') & F.col(phone_col).rlike(contact_regex)
            
            # Filter rows where phone number is valid (non-null, non-empty, and matches regex)
            valid_contact_df = valid_contact_df.filter(valid_phone_mask | F.col(phone_col).isNull() | (F.col(phone_col) == ''))
            
            # Filter rows where phone number is invalid (doesn't match regex)
            incorrect_contact_df = incorrect_contact_df.filter(~valid_phone_mask & (F.col(phone_col).isNotNull()) & (F.col(phone_col) != ''))
            print('__contact done__')
        
        return df, incorrect_contact_df
    
    except Exception as e:
        logger.error(f"Error validating contacts: {e}")
        raise

#-----------------------------------------------------------------------------------------#
        
def remove_duplicate_pk(df, pk_column):
    try:
        df.createOrReplaceTempView("input_table")

        # Step 1: Assign a row number based on the primary key column
        query = f"""
        SELECT *, ROW_NUMBER() OVER (PARTITION BY {pk_column} ORDER BY {pk_column}) as row_num
        FROM input_table
        """
        df_unique = glueContext.spark_session.sql(query)

        # Step 2: Get the unique records (where row_num = 1)
        df_uniqueness = glueContext.spark_session.sql(query).filter("row_num = 1")

        # Step 3: Get the duplicate records (where row_num > 1)
        duplicate_pk_df = glueContext.spark_session.sql(query).filter("row_num > 1")
        
        # Step 4: Drop the 'row_num' column from both DataFrames
        df_uniqueness = df_uniqueness.drop('row_num')
        duplicate_pk_df = duplicate_pk_df.drop('row_num')
        
        print('__pk done__')

        # Return both DataFrames: unique rows and duplicate rows
        return df_unique, duplicate_pk_df

    except Exception as e:
        logger.error(f"Error removing duplicates by primary key: {e}")
        raise
#-----------------------------------------------------------------------------------------#

# Remove duplicate rows
def remove_duplicate_rows(df):
    try:
        df_deduplicated = df.drop_duplicates(['row_hash'])
        print("remove_duplicate_rows done__")
        return df_deduplicated
    except Exception as e:
        logger.error(f"Error removing duplicate rows: {e}")
        raise
#-----------------------------------------------------------------------------------------#
# Remove whitespaces
def remove_whitespaces(df):
    try:
        for column in df.columns:
            df = df.withColumn(column, regexp_replace(col(column), r'^\s+|\s+$', ''))
        return df
    except Exception as e:
        logger.error(f"Error removing whitespaces: {e}")
        raise
    
#-----------------------------------------------------------------------------------------#

def filter_dynamodb_data(dynamodb_table, schema,table,type):

    # DynamoDB Connection Options
    dynamodb_options = {
        "dynamodb.input.tableName": dynamodb_table,
        "dynamodb.input.region": "us-east-1"
    }

    # Read DynamoDB table into Glue DynamicFrame
    dynamic_frame = glueContext.create_dynamic_frame.from_options(
        connection_type="dynamodb", 
        connection_options=dynamodb_options
    )

    # Convert DynamicFrame to DataFrame for easy filtering
    df = dynamic_frame.toDF()

    filtered_df = df.filter(
        (df['schema_name'] == schema) &
        (df['table_name'] == table) &
        (df['type'] == type)
    )

    # Select only the 'columnname' column and convert to a list
    columnnames_list = [row['column_name'] for row in filtered_df.select('column_name').collect()]
    

    # Return the filtered list
    return columnnames_list

#-----------------------------------------------------------------------------------------#
# Loop over the dictionary and process each key-value pair
table_counts = {}
start_time = datetime.now()
for table, s3_path in s3_dict.items():
    logger.info(f"Processing {table} from {s3_path}")
    # Example usage
    dynamodb_table_name = "pw-cleansing-metadata"
    pk_column = next(iter(set(filter_dynamodb_data(dynamodb_table_name, schema_name,table,'pk'))))
    email_columns = set(filter_dynamodb_data(dynamodb_table_name, schema_name,table,'email'))
    contact_columns = set(filter_dynamodb_data(dynamodb_table_name, schema_name,table,'contact'))

    try:
        # Read data from S3
        read_dynamic_frame = glueContext.create_dynamic_frame.from_options(
            connection_type="s3", 
            connection_options={"paths": [s3_path]}, 
            format="parquet", 
            format_options={"withHeader": True}
        )
        duplicate_pk_count = 0
        invalidEmails_count = 0
        invalidContacts_count = 0
        print('__1__')

        read_df = read_dynamic_frame.toDF()
        df_nullcolumns_cleaned = clean_null_columns(read_df)
        df_nullrows_cleaned = clean_null_rows(df_nullcolumns_cleaned)
        df_whitespace_cleaned = remove_whitespaces(df_nullrows_cleaned)
        #if all(col in df.columns for col in email_columns):
        print('__2__')
        if 'row_hash' in df_whitespace_cleaned.columns:
            df_no_duplicates = remove_duplicate_rows(df_whitespace_cleaned)
            print('__dup rows__')
        else:
            df_no_duplicates = df_whitespace_cleaned
            print('__no dup rows__')
        if pk_column and pk_column in df_no_duplicates.columns:
            unique_pk_df, duplicate_pk_df = remove_duplicate_pk(df_no_duplicates,pk_column)
            duplicate_pk_count = duplicate_pk_df.count()
            print('__dup pk__')
        else:
            pk_bool = 0
            unique_pk_df = df_no_duplicates
            print('__no dup pk__')
        valid_email_columns = [col for col in email_columns if col in unique_pk_df.columns]
        if valid_email_columns:
            valid_email_df, invalid_email_df = email_validation(unique_pk_df,valid_email_columns)
            invalidEmails_count = invalid_email_df.count()
            print('__dup emails__')
        else:
            email_bool = 0
            valid_email_df = unique_pk_df
            print('__no dup emails__')
        valid_contact_columns = [col for col in contact_columns if col in valid_email_df.columns]
        if valid_contact_columns:
            valid_contact_df, invalid_contact_df = contact_validation(valid_email_df,valid_contact_columns)
            invalidContacts_count = invalid_contact_df.count()
            print('__dup contacts__')
        else:
            contact_bool = 0
            valid_contact_df = valid_email_df
            print('__no dup contacts__')
        
        
        current_timestamp = datetime.now().strftime('%Y-%m-%d:%H:%M:%S')
        anomalies_str = f'[duplicate_pk_count={duplicate_pk_count}],[invalidEmails_count={invalidEmails_count}],[invalidContacts_count={invalidContacts_count}]'
        item = {
            'timestamp': current_timestamp ,
            'schema_name': schema_name,
            'table_name': table,
            'data_source': data_source,
            'anomalies': anomalies_str
            
        }
        # Insert the item into DynamoDB table
        response = insert_item_to_dynamodb('pw-cleansing-metrics', item)
        print("__dynamoDB__",response)
        # Count rows
        row_count = valid_contact_df.count()
        print("___cleaned__",row_count)
        #df_whitespace_cleaned.show(5)
        table_counts[schema_name] = table_counts.get(schema_name, 0) + row_count
        logger.info(f"Processed {table}, row count: {row_count}")

        # Convert back to DynamicFrame
        cleaned_dynamic_frame = DynamicFrame.fromDF(valid_contact_df.repartition(1), glueContext, table)
        current_date_str = datetime.now().strftime('%Y-%m-%d')
        
        # Write cleaned data back to S3
        output_path = f"s3://{bucket_name}/{data_source}/schemas/{schema_name}/{table}/{current_date_str}/"
        glueContext.write_dynamic_frame.from_options(
            cleaned_dynamic_frame, 
            connection_type="s3", 
            connection_options={"path": output_path}, 
            format="parquet"
        )
        if pk_bool != 0:
            dyf_pk = DynamicFrame.fromDF(duplicate_pk_df.repartition(1), glueContext, table)
            invalid_data_path = f"s3://{bucket_name}/{data_source}/invalid-data/{schema_name}/{table}/duplicate_pk/{current_date_str}/"
            glueContext.write_dynamic_frame.from_options(
                   frame=dyf_pk, 
                   connection_type="s3", 
                   connection_options={"path": invalid_data_path, "partitionKeys": []}, 
                   format="parquet"
            )
        if contact_bool != 0:
            dyf_contact = DynamicFrame.fromDF(invalid_contact_df.repartition(1), glueContext, table)
            invalid_data_path = f"s3://{bucket_name}/{data_source}/invalid-data/{schema_name}/{table}/duplicate_contacts/{current_date_str}/"
            glueContext.write_dynamic_frame.from_options(
                   frame=dyf_contact, 
                   connection_type="s3", 
                   connection_options={"path": invalid_data_path, "partitionKeys": []}, 
                   format="parquet"
            )
        if email_bool != 0:
            dyf_email = DynamicFrame.fromDF(invalid_email_df.repartition(1), glueContext, table)
            invalid_data_path = f"s3://{bucket_name}/{data_source}/invalid-data/{schema_name}/{table}/duplicate_emails/{current_date_str}/"
            glueContext.write_dynamic_frame.from_options(
                   frame=dyf_email, 
                   connection_type="s3", 
                   connection_options={"path": invalid_data_path, "partitionKeys": []}, 
                   format="parquet"
            )
        
        #send_dataframe_as_email(duplicate_pk_df,table)
        logger.info(f"Cleaned data for {table} written to {output_path}")

    except Exception as e:
        logger.error(f"Error processing {table}: {e}")
        error_message = f'ERROR while cleaning the data for {data_source} schema : {schema_name}'
        publish_sns_message(args['SNS_FAILURE_TOPIC_ARN'], error_message)
        

# Final execution time
end_time = datetime.now()
execution_time = (end_time - start_time).total_seconds() / 60  # in minutes
execution_time_rounded = round(execution_time, 2)
execution_time_min = f"{execution_time_rounded} min"
table_counts['execution_time'] = execution_time_min
current_date_str = datetime.now().strftime('%Y-%m-%d')
# Write execution details to S3
try:
    if len(table_counts) == 2:
        s3 = boto3.client('s3')
        s3.put_object(
            Bucket= bucket_name,
            Key=f'{data_source}/counts/{schema_name}/{schema_name}.json',
            Body=json.dumps(table_counts)
        )
    logger.info(f"Execution details saved to S3: {table_counts}")
    success_message = f'Cleaned the data successfully for  {data_source} SCHEMA : {schema_name}'
    publish_sns_message(args['SNS_SUCCESS_TOPIC_ARN'], success_message)
except Exception as e:
    logger.error(f"Error saving execution details to S3: {e}")

# Commit job
job.commit()
