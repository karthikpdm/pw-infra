import sys
import traceback
import hashlib
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
import os
import boto3
import json
import csv
from botocore.exceptions import ClientError
from pyspark.sql import functions as F
from datetime import datetime
import time

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'SCHEMA_NAME','SCHEMA_PATH','HASH_PATH','BUCKET_NAME', 'SECRET_NAME', 'SNS_SUCCESS_TOPIC_ARN', 'SNS_FAILURE_TOPIC_ARN'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "LEGACY")
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

def get_secret(secret_name):
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager')
    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = json.loads(response['SecretString'])
        return secret['user_name'], secret['password'], secret['server_name'], secret['database_name'], secret['driver_class']
    except ClientError as e:
        raise Exception(f'Error retrieving secret {secret_name}: {e}')

def publish_sns_message(topic_arn, message):
    sns = boto3.client('sns')
    response = sns.publish(
        TopicArn=topic_arn,
        Message=json.dumps({'default': message}),
        MessageStructure='json'
    )
    return response


def get_md5_hash(df):
    # Handle NULLs and trim whitespace
    hash_col = F.concat_ws("", *[
        F.trim(F.coalesce(F.col(column).cast("string"), F.lit("NULL"))) 
        for column in sorted(df.columns)  # Sort columns to ensure consistent order
    ])
    df=df.withColumn("row_hash", F.md5(hash_col))
    return df

# Define constants
schema_name = args['SCHEMA_NAME']
#schema_name = 'common'
secret_name = args['SECRET_NAME']
S3_OUTPUT_PATH = args['SCHEMA_PATH']
hash_path = args['HASH_PATH']
bucket_name =  args['BUCKET_NAME']
username, password, server, database, driver_class = get_secret(secret_name)

#tables = ['dimContactSource','factCommunicationFollowup','factContact','factCustomerActivityCharge','factCustomerSite']
#tables = ['dimPriceBook','dimPriceSource','factPrice','factServiceAgreementCostAgreement','factSiteOrder']

'''def get_tables_in_schema(schema_name):
    query = f"""
    SELECT TABLE_NAME 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA = '{schema_name}'
    """
    try:
        start_time = datetime.now()
        tables_df = spark.read \
            .format("jdbc") \
            .option("url", f"jdbc:sqlserver://{server}:1433;databaseName={database}") \
            .option("query", query) \
            .option("user", username) \
            .option("password", password) \
            .option("driver", driver_class) \
            .load()
        end_time = datetime.now()
        execution_time = (end_time - start_time).total_seconds() / 60  # in minutes
        execution_time_rounded = round(execution_time, 2)
        execution_time_min = f"{execution_time_rounded} min"
        print('__fetch table list__',execution_time_min)
        return [row.TABLE_NAME for row in tables_df.collect()]
        #return ['dimAction']
    except Exception as e:
        error_message = f"Error processing schema {schema_name}: {str(e)}"
        print(error_message)
        publish_sns_message(args['SNS_FAILURE_TOPIC_ARN'], error_message)
        traceback.print_exc()
        return [] '''
        

def get_tables_in_schema(schema_name):
    # Define your S3 bucket and file path
    file_key = f"amcs/metadata/{schema_name}.csv"
    s3_client = boto3.client('s3')
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
        table_list = [row[0] for row in csv_reader]
        
        # Print or return the list of values
        print(f"Extracted table_list: {table_list}")
    except Exception as e:
        print(f"Attempt failed with error: {str(e)}")
    
    return ['dimActivityStatus']  # You can adjust this as needed


def load_previous_hashes(table_name):
    previous_hashes_path = f"{hash_path}{schema_name}/{table_name}/"
    schema = StructType([StructField("row_hash", StringType(), True)])

    try:
        previous_hashes_df = spark.read.parquet(previous_hashes_path, header=True).repartition(20)
        return previous_hashes_df
    except Exception as e:
        print(f"Could not load previous hashes for {table_name}: {str(e)}")
        return spark.createDataFrame([], schema)

def save_current_hashes(current_hashes_df, table_name):
    current_hashes_path = f"{hash_path}{schema_name}/{table_name}/"
    current_hashes_df.repartition(1).write.parquet(current_hashes_path, mode="append", compression="snappy")

def process_table(table_name, max_retries=2, delay=5):
    if table_name.startswith("V_"):
        print(f"Skipping table {table_name} due to prefix 'V_'.")
        return 0  # Return 0 for skipped tables
    start_time_table = datetime.now()
    total_row_count = 0  # Initialize count for this schema

    for attempt in range(max_retries):
        try:
            dynamic_frame = glueContext.create_dynamic_frame.from_options(
                connection_type="sqlserver",
                connection_options={
                    "useConnectionProperties": "true",
                    "dbtable": f"{args['SCHEMA_NAME']}.{table_name}",
                    "connectionName": "glue-amcs-connection",
                },
                transformation_ctx=f"{schema_name}_{table_name}_source",
            )
           
            dataframe = dynamic_frame.toDF()
            schema_names_list = ['customer', 'sales', 'finance']
            if schema_name in schema_names_list:
                print("<<schename>>",schema_name)
                df = dataframe.repartition(70)
            else:
                df = dataframe.repartition(20)
                

            # Cast date columns as before
            date_columns = ['CreatedTimestamp', 'UpdatedTimestamp']
            for column in date_columns:
                if column in df.columns:
                    df = df.withColumn(column, df[column].cast('string'))

            # Use MD5 hashing for tables without primary keys
            previous_hashes_df = load_previous_hashes(table_name)
            df = get_md5_hash(df)
            #-------------------------------------------------------------------------#
            start_time = datetime.now()
            new_rows_df = df.join(previous_hashes_df, on="row_hash", how="left_anti")
            end_time = datetime.now()
            execution_time = (end_time - start_time).total_seconds() / 60  # in minutes
            execution_time_rounded = round(execution_time, 2)
            execution_time_min = f"{execution_time_rounded} min"
            print('__join__',execution_time_min)
            #--------------------------------------------------------------------------#
            new_rows_df = new_rows_df.repartition(20)

            start_time = datetime.now()
            new_row_count = new_rows_df.count()
            end_time = datetime.now()
            execution_time = (end_time - start_time).total_seconds() / 60  # in minutes
            execution_time_rounded = round(execution_time, 2)
            execution_time_min = f"{execution_time_rounded} min"
            print('__count__',execution_time_min)
            print(f"New rows for {table_name}: {new_row_count}")
            #--------------------------------------------------------------------------#
           
            total_row_count += new_row_count  # Accumulate count
            
            
            new_rows_df = new_rows_df.withColumn('pwIngestionTime', F.date_format(F.current_timestamp(), "dd-MM-yyyy:HH:mm"))
            #--------------------------------------------------------------------------------#
            start_time = datetime.now()
            # Write to S3
            dynamic_frame_back = DynamicFrame.fromDF(new_rows_df, glueContext, f"dynamic_frame_{table_name}_new")
            current_date_str = datetime.now().strftime('%Y-%m-%d')
            output_path = f"{S3_OUTPUT_PATH}/{schema_name}/{table_name}/{current_date_str}/"
            glueContext.write_dynamic_frame.from_options(
                frame=dynamic_frame_back,
                connection_type="s3",
                format="parquet",
                format_options={"withHeader": True},
                connection_options={"path": output_path, "partitionKeys": []},
                transformation_ctx=f"s3_write_{table_name}"
            )
            # Save current hashes and write to S3
            if not new_rows_df.rdd.isEmpty():
                save_current_hashes(new_rows_df.select("row_hash"), table_name)
            end_time = datetime.now()
            execution_time = (end_time - start_time).total_seconds() / 60  # in minutes
            execution_time_rounded = round(execution_time, 2)
            execution_time_min = f"{execution_time_rounded} min"
            print('__load into s3__',execution_time_min)
           
            print(f"Processed {schema_name}.{table_name} ..",total_row_count)
            return total_row_count  # Return the total count for this schema

        except Exception as e:
            if "GLUE_JOB_BOOKMARK_VERSION_MISMATCH_ERROR" in str(e) or "VersionMismatchException" in str(e):
                print(f"Attempt {attempt + 1} failed due to VersionMismatchException. Retrying in {delay} seconds...")
                time.sleep(delay)
                delay *= 2  # Exponential backoff
            else:
                error_message = f"Error processing table {table_name}: {str(e)}"
                print(error_message)
                publish_sns_message(args['SNS_FAILURE_TOPIC_ARN'], error_message)
                traceback.print_exc()
                break

    print(f"Max retries reached for table {schema_name}.{table_name}. Job failed.")
    publish_sns_message(args['SNS_FAILURE_TOPIC_ARN'], f"Job failed after maximum retries for table {table_name}.")
    raise Exception(f"Job failed after maximum retries for table {schema_name}.{table_name}.")

# Main processing logic
schema_results = {}  # Dictionary to store results for each schema
start_time = datetime.now()
# Get list of tables in the schema
tables = get_tables_in_schema(schema_name)

# Process each table in the schema
if len(tables) != 0:
 for table in tables:
    row_count = process_table(table)
    schema_name_key = schema_name  # Update this to reflect the actual schema name if needed
    if schema_name_key not in schema_results:
        schema_results[schema_name_key] = 0
    schema_results[schema_name_key] += row_count
else:
    print("No tables available")    
end_time = datetime.now()

# Calculate the execution time in minutes
execution_time = (end_time - start_time).total_seconds() / 60  # in minutes
execution_time_rounded = round(execution_time, 2)
execution_time_min = f"{execution_time_rounded} min"

# Add execution time to the results
schema_results['execution_time'] = execution_time_min
# Check if the length of the dictionary is 2
if len(schema_results) == 2:
    # Create an S3 client
    s3 = boto3.client('s3')
    current_date = datetime.now().strftime('%Y-%m-%d')
    # Put the object in the S3 bucket
    s3.put_object(
        Bucket=bucket_name,
        Key=f'amcs/counts/{schema_name}/{schema_name}.json',
        Body=json.dumps(schema_results)
    )
    print("S3 object successfully uploaded.")
else:
    print("The dictionary does not have exactly 2 keys. Skipping S3 upload.")
# At the end of processing, return the results
print(f"Schema results: {schema_results}")

# Notify success for the entire schema processing
success_message = f"Successfully processed schema: {schema_name}"
publish_sns_message(args['SNS_SUCCESS_TOPIC_ARN'], success_message)

# Commit the job with retry logic
max_retries = 2
delay = 5
for attempt in range(max_retries):
    try:
        job.commit()
        break
    except Exception as e:
        if "GLUE_JOB_BOOKMARK_VERSION_MISMATCH_ERROR" in str(e) or "VersionMismatchException" in str(e):
            print(f"Commit attempt {attempt + 1} failed due to VersionMismatchException. Retrying in {delay} seconds...")
            time.sleep(delay)
            delay *= 2
        else:
            print(f"Job failed during commit: {str(e)}")
            raise

print("Job committed successfully.")
# Publish results to Step Function

