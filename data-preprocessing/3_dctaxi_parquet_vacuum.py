import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col, to_timestamp, dayofweek, year, month, hour
from pyspark.sql.types import IntegerType

args = getResolvedOptions(sys.argv, ["JOB_NAME", "BUCKET_SRC_PATH", "BUCKET_DST_PATH"])

BUCKET_SRC_PATH = args["BUCKET_SRC_PATH"]
BUCKET_DST_PATH = args["BUCKET_DST_PATH"]

sc = SparkContext()
glueContext = GlueContext(sc)
logger = glueContext.get_logger()
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args["JOB_NAME"], args)

df = spark.read.parquet(f"{BUCKET_SRC_PATH}")

df.createOrReplaceTempView("dc_taxi_parquet")

query_df = spark.sql(
    """
SELECT
    fareamount_double,
    origindatetime_tr,
    origin_block_latitude_double,
    origin_block_longitude_double,
    destination_block_latitude_double,
    destination_block_longitude_double 
FROM 
  dc_taxi_parquet 
WHERE 
    origindatetime_tr IS NOT NULL
    AND fareamount_double IS NOT NULL
    AND fareamount_double >= 3.25
    AND fareamount_double <= 180.0
    AND origin_block_latitude_double IS NOT NULL
    AND origin_block_longitude_double IS NOT NULL
    AND destination_block_latitude_double IS NOT NULL
    AND destination_block_longitude_double IS NOT NULL
    """.replace(
        "\n", ""
    )
)

# convert timestamp feature into numeric data
query_df = (
    query_df.withColumn(
        "origindatetime_ts", to_timestamp("origindatetime_tr", "dd/MM/yyy HH:mm")
    )
    .where(col("origindatetime_tr").isNotNull())
    .drop("origindatetime_tr")
    .withColumn("year_integer", year("origindatetime_ts").cast(IntegerType()))
    .withColumn("month_integer", month("origindatetime_ts").cast(IntegerType()))
    .withColumn("dow_integer", dayofweek("origindatetime_ts").cast(IntegerType()))
    .withColumn("hour_integer", hour("origindatetime_ts").cast(IntegerType()))
    .drop("origindatetime_ts")
)

query_df = query_df.dropna().drop_duplicates()

(query_df.write.parquet(f"{BUCKET_DST_PATH}", mode="overwrite"))


def save_stats_metadata(df, dest, header="true", mode="overwrite"):
    return df.describe().coalesce(1).write.option("header", header).csv(dest, mode=mode)


save_stats_metadata(query_df, f"{BUCKET_DST_PATH}/.meta/stats")

job.commit()
