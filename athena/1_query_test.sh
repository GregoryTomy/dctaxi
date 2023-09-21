SQL="
CREATE EXTERNAL TABLE IF NOT EXISTS dc_taxi_db.dc_taxi_csv_sample_strings(
        fareamount STRING,
        origin_block_latitude STRING,
        origin_block_longitude STRING,
        destination_block_latitude STRING,
        destination_block_longitude STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION 's3://dc-taxi-a471b90f22023ac9b8f198538bdc622f-us-west-2/samples/' 
TBLPROPERTIES ('skip.header.line.count'='1');"

ATHENA_QUERY_ID=$(aws athena start-query-execution \
--work-group dc_taxi_athena_workgroup \
--query 'QueryExecutionId' \
--output text \
--query-string "$SQL")

echo $SQL
echo $ATHENA_QUERY_ID
until aws athena get-query-execution \
  --query 'QueryExecution.Status.State' \
  --output text \
  --query-execution-id $ATHENA_QUERY_ID | grep -v "RUNNING";
do
  printf '.'
  sleep 1; 
done
