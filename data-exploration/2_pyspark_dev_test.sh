#!/bin/bash

read -p "Enter SAMPLE_SIZE: " SAMPLE_SIZE
read -p "Enter SAMPLE_COUNT: " SAMPLE_COUNT

read -r BUCKET_ID AWS_DEFAULT_REGION < ../bucket_id.txt

source ../utils.sh

PYSPARK_SRC_NAME=dctaxi_dev_test.py \
PYSPARK_JOB_NAME=dc-taxi-dev-test-job \
ADDITIONAL_PYTHON_MODULES="kaen[spark]" \
BUCKET_SRC_PATH=s3://dc-taxi-$BUCKET_ID-$AWS_DEFAULT_REGION/parquet/vacuum \
BUCKET_DST_PATH=s3://dc-taxi-$BUCKET_ID-$AWS_DEFAULT_REGION/csv \
SAMPLE_SIZE=$SAMPLE_SIZE \
SAMPLE_COUNT=$SAMPLE_COUNT \
SEED=30 \
run_job
