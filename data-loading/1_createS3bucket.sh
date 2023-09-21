#!/bin/bash

read -p "Enter AWS region (e.g. us-west-2): " AWS_DEFAULT_REGION

export BUCKET_ID=$(echo $RANDOM | md5 | cut -c -32)

aws s3api create-bucket --bucket dc-taxi-$BUCKET_ID-$AWS_DEFAULT_REGION \
  --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION

# change data_dctaxi to the folder where you have the taxi data
aws s3 sync \
  --exlude 'README*' \
  data_dctaxi/ s3://dc-taxi-$BUCKET_ID-$AWS_DEFAULT_REGION/csv/

aws s3 ls --recursive --summarize --human-readable \
  s3://dc-taxi-$BUCKET_ID-$AWS_DEFAULT_REGION/csv/

