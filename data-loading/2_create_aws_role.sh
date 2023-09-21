# Prompt the user for BUCKET_ID
read -p "Enter the BUCKET_ID: " BUCKET_ID

# Prompt the user for AWS_DEFAULT_REGION
read -p "Enter the AWS_DEFAULT_REGION: " AWS_DEFAULT_REGION

aws iam detach-role-policy --role-name AWSGlueServiceRole-dc-taxi --policy-arn arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole && \
aws iam delete-role-policy --role-name AWSGlueServiceRole-dc-taxi --policy-name GlueBucketPolicy && \
aws iam delete-role --role-name AWSGlueServiceRole-dc-taxi

aws iam create-role --path "/service-role/" --role-name AWSGlueServiceRole-dc-taxi --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}'

aws iam attach-role-policy --role-name AWSGlueServiceRole-dc-taxi --policy-arn arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole

aws iam put-role-policy --role-name AWSGlueServiceRole-dc-taxi --policy-name GlueBucketPolicy --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::dc-taxi-'$BUCKET_ID'-'$AWS_DEFAULT_REGION'/*"
            ]
        }
    ]
}'
  
