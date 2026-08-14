import sys
import boto3
from awsglue.utils import getResolvedOptions
from pyspark.sql import SparkSession

# Parse arguments
args = getResolvedOptions(sys.argv, ["JOB_NAME", "source_bucket", "target_bucket"])

# Get bucket names from arguments
source_bucket = args["source_bucket"]
target_bucket = args["target_bucket"]

# Initialize SparkSession
spark = SparkSession.builder.appName("GlueQuery").getOrCreate()

# Function to get the latest partition
# def get_latest_partition(bucket, prefix):
#     s3 = boto3.client("s3")
#     response = s3.list_objects_v2(Bucket=bucket, Prefix=prefix, Delimiter="/")
#     partitions = [obj["Prefix"] for obj in response.get("CommonPrefixes", [])]
    
#     if not partitions:
#         raise Exception(f"No partitions found under s3://{bucket}/{prefix}")

#     latest_partition = sorted(partitions)[-1]  # Get the most recent partition
#     print(f"Latest partition found: {latest_partition}")
#     return f"s3://{bucket}/{latest_partition}"

try:
    print("Loading data from source bucket...")

    # Define paths
    fact_route_path = f"s3://{source_bucket}/schemas/transport/factRoute/"
    dim_date_path = f"s3://{source_bucket}/schemas/common/dimDate/"
    dim_route_path = f"s3://{source_bucket}/schemas/common/dimRoute/"

    # Read partitioned Parquet files with mergeSchema
    fact_route_df = spark.read.option("mergeSchema", "true").parquet(fact_route_path+"*")
    dim_date_df = spark.read.option("mergeSchema", "true").parquet(dim_date_path+"*")
    dim_route_df = spark.read.option("mergeSchema", "true").parquet(dim_route_path+"*")

    print("Data loaded successfully!")
except Exception as e:
    print(f"Error loading data from source bucket: {e}")
    sys.exit(1)

try:
    print("Joining factRoute with dimDate...")
    fact_with_date = fact_route_df.join(dim_date_df, fact_route_df["routedatekey"] == dim_date_df["datekey"], "inner")

    print("Joining with dimRoute...")
    final_df = fact_with_date.join(
        dim_route_df,
        (fact_with_date["routedatekey"] == dim_route_df["routedate"]) &
        (fact_with_date["routeno"] == dim_route_df["routeno"]) &
        (fact_with_date["routekey"] == dim_route_df["routekey"]),
        "inner"
    )
    print("Data joined successfully!")
except Exception as e:
    print(f"Error joining data: {e}")
    sys.exit(1)

try:
    print("Selecting required columns...")
    result_df = final_df.select(
        dim_date_df["datekey"].alias("datekey"),
        dim_date_df["dayofweek"].alias("dayofweek"),
        dim_route_df["areaoforigin"].alias("city"),
        dim_route_df["notes"].alias("notes"),
        dim_route_df["driver"].alias("driver"),
        dim_route_df["vehicleregistration"].alias("truck"),
        fact_route_df["firstliftdatetime"].alias("start_time"),
        fact_route_df["lastliftdatetime"].alias("end_time"),
        fact_route_df["totaldowntime"].alias("downtime"),
        fact_route_df["disposalcosts"].alias("disposalcosts"),
        fact_route_df["routeno"].alias("routeno"),
        dim_route_df["companyoutlet"].alias("yard"),
        fact_route_df["calloutliftcount"].alias("total_calls"),
        fact_route_df["missedvisitcount"].alias("missed_stops"),
        fact_route_df["calloutliftcount"].alias("calloutliftcount"),
        fact_route_df["calloutliftcontainervolume"].alias("calloutliftcontainervolume"),
        fact_route_df["invoicedcount"].alias("invoicedcount"),
        dim_route_df["vehicletype"].alias("vehicletype"),
        dim_route_df["material"].alias("material"),
        dim_route_df["destination"].alias("destination"),
        fact_route_df["totalcollectedliftcount"],
        fact_route_df["completedvisitcount"],
        fact_route_df["completedliftcount"],
        fact_route_df["routevisitnotecount"].alias("total_route_units"),
        fact_route_df["totaldistance"],
        fact_route_df["fuelused"],
        dim_route_df["containervolume"].alias("disposal_tons")
    )
    print("Column selection successful!")
except Exception as e:
    print(f"Error selecting columns: {e}")
    sys.exit(1)

try:
    print(f"Writing results to target bucket: s3://{target_bucket}/residential/...")
    result_df.coalesce(1).write.format("parquet").mode("overwrite").save(f"s3://{target_bucket}/residential/")
    print("Data written successfully!")
except Exception as e:
    print(f"Error writing data to target bucket: {e}")
    sys.exit(1)
