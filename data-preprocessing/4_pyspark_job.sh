#!/bin/bash

read -p "Enter BUCKET_ID: " BUCKET_ID
read -p "Enter AWS_DEFAULT_REGION: " AWS_DEFAULT_REGION

source ../utils.sh

PYSPARK_SRC_NAME=dctaxi_parquet_vacuum.py \
PYSPARK_JOB_NAME=dc-taxi-parquet-vacuum-job \
BUCKET_SRC_PATH=s3://dc-taxi-$BUCKET_ID-$AWS_DEFAULT_REGION/parquet \
BUCKET_DST_PATH=s3://dc-taxi-$BUCKET_ID-$AWS_DEFAULT_REGION/parquet/vacuum \
run_job
