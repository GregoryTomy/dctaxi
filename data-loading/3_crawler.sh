read -p "Enter BUCKET_ID: " BUCKET_ID
read -p "Enter region: " AWS_DEFAULT_REGION

aws glue delete-database --name dc_taxi_db 2> /dev/null

# Create the database named dc_taxi_db
aws glue create-database --database-input '{
  "Name": "dc_taxi_db"
}'

# confirm that the database was created 
# aws glue get-database --name 'dc_taxi_db'

# create and start a Glue crawler
aws glue delete-crawler --name dc-taxi-csv-crawler 2> /dev/null

aws glue create-crawler \
  --name dc-taxi-csv-crawler \
  --database-name dc_taxi_db \
  --table-prefix dc_taxi_ \
  --role $( aws iam get-role \
              --role-name AWSGlueServiceRole-dc-taxi \
              --query 'Role.Arn' \
              --output text ) \
   --targets '{
  "S3Targets": [
    {
      "Path": "s3://dc-taxi-'$BUCKET_ID'-'$AWS_DEFAULT_REGION'/csv"
    }]
}'

aws glue start-crawler --name dc-taxi-csv-crawler
# monitor the state of the crawler
printf "Waiting for crawler to finish..."
until echo "$(aws glue get-crawler --name dc-taxi-csv-crawler --query 'Crawler.State' --output text)" | grep -q "READY"; do
   sleep 60
   printf "..."
done
printf "done\n" 
