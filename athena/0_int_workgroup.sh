aws athena delete-work-group --work-group dc_taxi_athena_workgroup --recursive-delete-option 2> /dev/null

aws athena create-work-group --name dc_taxi_athena_workgroup \
--configuration "ResultConfiguration={OutputLocation=s3://dc-taxi-a471b90f22023ac9b8f198538bdc622f-us-west-2/athena},EnforceWorkGroupConfiguration=false,PublishCloudWatchMetricsEnabled=false"
