import sys
import boto3
from awsglue.utils import getResolvedOptions
from pyspark.sql import SparkSession

# Parse Glue job arguments
args = getResolvedOptions(sys.argv, ["JOB_NAME", "source_bucket", "target_bucket"])

source_bucket = args["source_bucket"]  # Example: "my-source-bucket"
target_bucket = args["target_bucket"]  # Example: "pw-reporting"

# Initialize SparkSession
spark = SparkSession.builder.appName("CSVtoParquet").getOrCreate()

try:
    print("Listing CSV files in source bucket...")

    # List files from S3 using boto3
    s3 = boto3.client("s3")
    response = s3.list_objects_v2(Bucket=source_bucket, Prefix="scheduled-reports/")

    # Extract CSV file paths
    csv_files = [
        f"s3://{source_bucket}/{obj['Key']}" for obj in response.get("Contents", [])
        if obj["Key"].endswith(".csv")
    ]

    if not csv_files:
        raise Exception("No CSV files found in the source bucket!")

    print(f"Found {len(csv_files)} CSV files.")

    # Read CSV files into Spark DataFrame
    df = spark.read.format("csv") \
        .option("header", "true") \
        .option("inferSchema", "true") \
        .load(csv_files)  # Pass list of full S3 paths

    print("CSV data loaded successfully!")

except Exception as e:
    print(f"Error loading CSV files: {e}")
    sys.exit(1)

try:
    print("Writing data as Parquet to target bucket...")

    # Define the target path
    target_path = f"s3://{target_bucket}/connect/"

    # Save as Parquet with overwrite mode
    df.write.format("parquet") \
        .mode("overwrite") \
        .save(target_path)

    print(f"Data written successfully to {target_path}")

except Exception as e:
    print(f"Error writing Parquet data: {e}")
    sys.exit(1)
