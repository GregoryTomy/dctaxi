source utils.sh ; athena_query "
CREATE EXTERNAL TABLE IF NOT EXISTS dc_taxi_db.dc_taxi_csv_sample_double(
        fareamount DOUBLE,  
        origin_block_latitude DOUBLE,
        origin_block_longitude DOUBLE,
        destination_block_latitude DOUBLE,
        destination_block_longitude DOUBLE
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION 's3://dc-taxi-a471b90f22023ac9b8f198538bdc622f-us-west-2/samples/' 
TBLPROPERTIES ('skip.header.line.count'='1');"

