import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType
import pyspark.sql.functions as F
from pyspark.sql import SparkSession

# Retrieve the parameters from the job arguments
args = getResolvedOptions(sys.argv, ["JOB_NAME", "source_bucket", "target_bucket"])

# Initialize Glue context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Get bucket names from arguments
source_bucket = args["source_bucket"]
target_bucket = args["target_bucket"]

# Initialize SparkSession
spark = SparkSession.builder.appName("GlueQuery").getOrCreate()

# Parameterized S3 paths
# fact_job_path = f"s3://{source_bucket}/amcs-datalake/transport/factJob/"
# dim_job_path = f"s3://{source_bucket}/amcs-datalake/common/dimJob/"
# dim_vehicle_path = f"s3://{source_bucket}/amcs-datalake/transport/dimVehicle/"
output_path = f"s3://{target_bucket}/heavyhaul/"

try:
    # Load the data from your data lake (using parameterized bucket paths)
    print("Loading data from source bucket...")
    fact_job_df = spark.read.format("parquet").load(f"s3://{source_bucket}/amcs-datalake/transport/factJob/")
    dim_job_df = spark.read.format("parquet").load(f"s3://{source_bucket}/amcs-datalake/common/dimJob/")
    dim_vehicle_df = spark.read.format("parquet").load(f"s3://{source_bucket}/amcs-datalake/transport/dimVehicle/")
    print("Data loaded successfully!")
except Exception as e:
    print(f"Error loading data from source bucket: {e}")
    #sys.exit(1)  # Exit the script if data loading fails

# Perform the joins
try:
    fact_with_job = fact_job_df.join(
        dim_job_df,
        (fact_job_df["jobid"] == dim_job_df["jobid"]),
        "inner"
    )

    fact_with_job_and_vehicle = fact_with_job.join(
        dim_vehicle_df,
        (fact_with_job["vehiclekey"] == dim_vehicle_df["vehiclekey"]),
        "inner"
    )
except Exception as e:
    print(f"Error during join operations: {str(e)}")
    job.commit()
    #sys.exit(1)


# Select the required columns
try:
    # Select the required columns with the new format
    result_df = fact_with_job_and_vehicle.select(
        dim_job_df["customersitename"].alias("customersitename"),
        dim_vehicle_df["registrationno"].alias("registrationno"),
        fact_job_df["workperformeddatekey"].alias("workperformeddatekey"),
        fact_job_df["hourschargeable"].alias("hourschargeable"),
        fact_job_df["totalcollectedweight"].alias("totalcollectedweight"),
        fact_job_df["totalcollectedvolume"].alias("totalcollectedvolume"),
        dim_job_df["routeno"].alias("routeno"),
        dim_job_df["driver"].alias("driver"),
        fact_job_df["iscompleted"].alias("iscompleted"),
        fact_job_df["customerrevenue"].alias("customerrevenue"),
        fact_job_df["haulrevenue"].alias("haulrevenue")
)
except Exception as e:
    print(f"Error during column selection: {str(e)}")
    job.commit()
    #sys.exit(1)
# Save the results to the parameterized S3 bucket
try:
    result_df.coalesce(1).write.format("parquet").mode("overwrite").save(output_path)
    print(f"Result written to {output_path} successfully.")
except Exception as e:
    print(f"Error writing results to {output_path}: {str(e)}")
    job.commit()
    #sys.exit(1)

# End the Glue job
job.commit()



