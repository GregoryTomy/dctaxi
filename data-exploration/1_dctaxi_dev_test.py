#!/usr/bin/env python3

"""
 This script performs random sampling of a dataset stored in an S3 bucket and 
 saves the sampled data along with associated summary statistics back to another
 S3 bucket. The sampling is guided by p-values and can be repeated multiple times 
 with different seeds.
"""

import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from kaen.spark import (
    spark_df_to_stats_pandas_df,
    pandas_df_to_spark_df,
    spark_df_to_shards_df,
)


args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "BUCKET_SRC_PATH",
        "BUCKET_DST_PATH",
        "SAMPLE_SIZE",
        "SAMPLE_COUNT",
        "SEED",
    ],
)

BUCKET_SRC_PATH = args["BUCKET_SRC_PATH"]
BUCKET_DST_PATH = args["BUCKET_DST_PATH"]

sc = SparkContext()
glueContext = GlueContext(sc)
logger = glueContext.get_logger()
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args["JOB_NAME"], args)

df = spark.read.format("parquet").load(f"{BUCKET_SRC_PATH}")

SAMPLE_SIZE = float(args["SAMPLE_SIZE"])
dataset_size = float(df.count())
sample_frac = SAMPLE_SIZE / dataset_size

summary_df = spark_df_to_stats_pandas_df(df)
mu = summary_df.loc["mean"]
sigma = summary_df.loc["stddev"]

# the summary statistics along with sample_frac are used to perform
# random sampling

SEED = int(args["SEED"])
SAMPLE_COUNT = int(args["SAMPLE_COUNT"])

for idx in range(SAMPLE_COUNT):
    dev_df, test_df = df.cache().randomSplit(
        [1.0 - sample_frac, sample_frac], seed=SEED
    )
    test_df = test_df.limit(int(SAMPLE_SIZE))

    test_stats_df = spark_df_to_stats_pandas_df(
        test_df, summary_df, pvalues=True, zscores=True
    )

    pvalues_series = test_stats_df.loc["pvalues"]

    if pvalues_series.min() < 0.05:
        SEED = SEED + idx
    else:
        break

# save development and test datasets to S3 along with summary statistics

for df, desc in [(dev_df, "dev"), (test_df, "test")]:
    (
        df.write.option("header", "true")
        .mode("overwrite")
        .csv(f"{BUCKET_DST_PATH}/{desc}")
    )

    stats_pandas_df = spark_df_to_stats_pandas_df(
        df, summary_df, pvalues=True, zscores=True
    )
    (
        pandas_df_to_spark_df(spark, stats_pandas_df)
        .coalesce(1)
        .write.option("header", "true")
        .mode("overwrite")
        .csv(f"{BUCKET_DST_PATH}/{desc}/.meta/stats")
    )

    (
        spark_df_to_shards_df(spark, df)
        .coalesce(1)
        .write.option("header", "true")
        .mode("overwrite")
        .csv(f"{BUCKET_DST_PATH}/{desc}/.meta/shards")
    )

job.commit()
