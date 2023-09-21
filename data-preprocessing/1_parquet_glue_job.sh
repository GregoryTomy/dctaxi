#!/bin/bash

read -p "Enter BUCKET_ID: " BUCKET_ID
read -p "Enter AWS_DEFAULT_REGION: " AWS_DEFAULT_REGION

aws s3 cp dctaxi_csv_to_parquet.py s3://dc-taxi-$BUCKET_ID-$AWS_DEFAULT_REGION/glue/
aws s3 ls s3://dc-taxi-$BUCKET_ID-$AWS_DEFAULT_REGION/glue/dctaxi_csv_to_parquet.py

aws glue create-job \
  --name dc-taxi-csv-to-parquet-job \
  --role $(aws iam get-role --role-name AWSGlueServiceRole-dc-taxi --query 'Role.Arn' --output text) \
  --default-arguments '{"--TempDir":"s3://dc-taxi-'$BUCKET_ID'-'$AWS_DEFAULT_REGION'/glue/"}' \
  --command '{
    "ScriptLocation": "s3://dc-taxi-'$BUCKET_ID'-'$AWS_DEFAULT_REGION'/glue/dctaxi_csv_to_parquet.py",
    "Name": "glueetl",
    "PythonVersion": "3"
  }' \
  --glue-version "2.0"

aws glue start-job-run \
  --job-name dc-taxi-csv-to-parquet-job \
  --arguments='--BUCKET_SRC_PATH="'$(
  echo s3://dc-taxi-$BUCKET_ID-$AWS_DEFAULT_REGION/csv/
)'",
--BUCKET_DST_PATH="'$(
echo s3://dc-taxi-$BUCKET_ID-$AWS_DEFAULT_REGION/parquet/
)'",
--DST_VIEW_NAME="dc_taxi_csv"'
