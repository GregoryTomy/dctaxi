#!/bin/bash

read -p "Enter BUCKET_ID: " BUCKET_ID
read -p "Enter region: " AWS_DEFAULT_REGION

aws glue create-crawler \
  --name dc-taxi-parquet-crawler \
  --database-name dc_taxi_db \
  --table-prefix dc_taxi_ \
  --role $( aws iam get-role \
              --role-name AWSGlueServiceRole-dc-taxi \
              --query 'Role.Arn' \
              --output text ) \
   --targets '{
  "S3Targets": [
    {
      "Path": "s3://dc-taxi-'$BUCKET_ID'-'$AWS_DEFAULT_REGION'/parquet"
    }]
}'

aws glue start-crawler --name dc-taxi-parquet-crawler

# monitor the state of the crawler
printf "Waiting for crawler to finish..."
until echo "$(aws glue get-crawler --name dc-taxi-parquet-crawler --query 'Crawler.State' --output text)" | grep -q "READY"; do
   sleep 60
   printf "..."
done
printf "done\n" 
