import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(
    sys.argv, ["JOB_NAME", "BUCKET_SRC_PATH", "BUCKET_DST_PATH", "DST_VIEW_NAME"]
)

BUCKET_SRC_PATH = args["BUCKET_SRC_PATH"]
BUCKET_DST_PATH = args["BUCKET_DST_PATH"]
DST_VIEW_NAME = args["DST_VIEW_NAME"]

sc = SparkContext()
glueContext = GlueContext(sc)
logger = glueContext.get_logger()
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args["JOB_NAME"], args)

df = (
    spark.read.format("csv")
    .option("header", True)
    .option("inferSchema", True)
    .option("multiLine", True)
    .option("delimiter", "|")
    .load(f"{BUCKET_SRC_PATH}")
)

df.createOrReplaceTempView(f"{DST_VIEW_NAME}")

query_df = spark.sql(
    f"""
SELECT 

  CAST(fareamount AS DOUBLE) AS fareamount_double,
  CAST(fareamount AS STRING) AS fareamount_string,

  CAST(origindatetime_tr AS STRING) AS origindatetime_tr,

  CAST(origin_block_latitude AS DOUBLE) AS origin_block_latitude_double,
  CAST(origin_block_latitude AS STRING) AS origin_block_latitude_string,

  CAST(origin_block_longitude AS DOUBLE) AS origin_block_longitude_double,
  CAST(origin_block_longitude AS STRING) AS origin_block_longitude_string,

  CAST(destination_block_latitude AS DOUBLE) AS destination_block_latitude_double,
  CAST(destination_block_latitude AS STRING) AS destination_block_latitude_string,

  CAST(destination_block_longitude AS DOUBLE) AS destination_block_longitude_double,
  CAST(destination_block_longitude AS STRING) AS destination_block_longitude_string,

  CAST(mileage AS DOUBLE) AS mileage_double,
  CAST(mileage AS STRING) AS mileage_string 

FROM {DST_VIEW_NAME}""".replace(
        "\n", ""
    )
)

query_df.write.parquet(f"{BUCKET_DST_PATH}", mode="overwrite")

job.commit()
