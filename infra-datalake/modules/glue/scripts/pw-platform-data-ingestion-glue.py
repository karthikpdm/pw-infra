import sys
import boto3
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from awsglue.job import Job
from datetime import datetime
from awsglue.utils import getResolvedOptions
from awsglue.transforms import *
from pyspark.sql import functions as F
from datetime import datetime
from pyspark.sql.types import StructType, StructField, StringType
import json
import logging

# Get job arguments
args = getResolvedOptions(sys.argv, ['JOB_NAME','SCHEMA_NAME', 'SCHEMA_PATH', 'HASH_PATH', 'COUNTS_PATH', 'SNS_SUCCESS_TOPIC_ARN', 'SNS_FAILURE_TOPIC_ARN'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

table_name = args['SCHEMA_NAME']
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# S3 target path (replace with your S3 bucket and path)
s3_target_path = args['SCHEMA_PATH']
table_counts = {}

def publish_sns_message(topic_arn, message):
    sns = boto3.client('sns')
    response = sns.publish(
        TopicArn=topic_arn,
        Message=json.dumps({'default': message}),
        MessageStructure='json'
    )
    return response
#------------------------------------------------------------------------------------------------------------#
def load_previous_hashes(table_name):
    previous_hashes_path = f"{args['HASH_PATH']}/{table_name}/"
    schema = StructType([StructField("row_hash", StringType(), True)])
    try:
        previous_hashes_df = spark.read.parquet(previous_hashes_path)
        return previous_hashes_df
    except Exception as e:
        logger.info(f"Could not load previous hashes for {table_name}: {str(e)}")
        return spark.createDataFrame([], schema)
#------------------------------------------------------------------------------------------------------------#
def save_current_hashes(current_hashes_df, table_name):
    
    current_hashes_path = f"{args['HASH_PATH']}/{table_name}/"
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

# Function to process each DynamoDB table
def process_table(table_name):
    print(f"Processing table: {table_name}")
    dynamodb_options = {
        "dynamodb.input.tableName": table_name,
        "dynamodb.input.region": "us-east-1"
    }

    # Read data from DynamoDB into DynamicFrame
    try:
        dynamodb_data = glueContext.create_dynamic_frame.from_options(
            connection_type="dynamodb",
            connection_options=dynamodb_options
        )
    except Exception as e:
        logger.info(f"Error reading data from DynamoDB table {table_name}: {e}")
        publish_sns_message(args['SNS_FAILURE_TOPIC_ARN'], f"Job failed after maximum retries for table {table_name}.")
        return  # Skip to the next table if error occurs

    # Convert DynamicFrame to Spark DataFrame for easy filtering
    df = dynamodb_data.toDF()
    previous_hashes_df = load_previous_hashes(table_name)
    df = get_md5_hash(df)
    new_rows_df = df.join(previous_hashes_df, on="row_hash", how="left_anti")
    new_rows_df.show()
    row_count = new_rows_df.count()
    logger.info(f"Row count for {table_name}: {row_count}")
    # Convert DataFrame to Glue DynamicFrame
    new_rows_df = new_rows_df.repartition(1)
    if not new_rows_df.rdd.isEmpty():
        save_current_hashes(new_rows_df.select("row_hash"), table_name)
    new_rows_df = new_rows_df.withColumn('pwIngestionTime', F.date_format(F.current_timestamp(), "dd-MM-yyyy:HH:mm"))
    # Define the S3 output path
    current_date_str = datetime.now().strftime('%Y-%m-%d')

    # Update the dictionary with the table name and its record count
    table_counts[table_name] = row_count
    
    # Optional: Adjust number of partitions if needed
    dynamic_frame_back = DynamicFrame.fromDF(new_rows_df, glueContext, f"dynamic_frame_{table_name}")

    # Write the data to S3
    s3_table_target_path = f"{s3_target_path}/{table_name}/{current_date_str}/"  # Organize by table in S3
    try:
        glueContext.write_dynamic_frame.from_options(
            frame=dynamic_frame_back,
            connection_type="s3",
            format="parquet",
            connection_options={"path": s3_table_target_path, "partitionKeys": []},
            transformation_ctx=f"s3_write_{table_name}"
        )
        logger.info(f"Data for {table_name} written to {s3_table_target_path}")
    except Exception as e:
        logger.info(f"Error writing data for {table_name} to S3: {e}")
        logger.info(f"Max retries reached for table {table_name}. Job failed.")
        publish_sns_message(args['SNS_FAILURE_TOPIC_ARN'], f"Job failed after maximum retries for table {table_name}.")

#------------------------------------------------------------------------------------------------------------#
# Main processing logic

start_time = datetime.now()
# Start parallel processing
process_table(table_name)

print("__table_counts__",table_counts)

end_time = datetime.now()

# Calculate the execution time in minutes
execution_time = (end_time - start_time).total_seconds() / 60  # in minutes
execution_time_rounded = round(execution_time, 2)
execution_time_min = f"{execution_time_rounded} min"

# Add execution time to the results
table_counts['execution_time'] = execution_time_min
# Check if the length of the dictionary is 2
if len(table_counts) == 2:
    # Create an S3 client
    s3 = boto3.client('s3')
    
    # Put the object in the S3 bucket
    s3.put_object(
        Bucket='pw-platform-data',
        Key=f'counts/{table_name}/{table_name}.json',
        Body=json.dumps(table_counts)
    )
    logger.info("S3 object successfully uploaded.")
else:
    logger.info("The dictionary does not have exactly 2 keys. Skipping S3 upload.")


# Notify success for the entire schema processing
success_message = f"Successfully processed DynamoDB table: {table_name}"
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

# Log the record counts (Optional)
logger.info("ETL job completed successfully for all tables")
logger.info("Table record counts:", table_counts)
