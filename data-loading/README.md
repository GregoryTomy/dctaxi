# Data Loading

The data loading phase consists of several steps, each represented by a Bash script. Below is a breakdown of the roles of each script and how to execute them.

## Directory Structure

```plaintext
data-loading/
|-- 0_download_data.sh
|-- 1_createS3bucket.sh
|-- 2_create_aws_role.sh
|-- 3_crawler.sh
```

## Explanation

1. 0_download_data.sh: This script uses gdown to download taxi trip data for the years 2015-2019. The downloaded zip files are then extracted into a directory called data_dctaxi.
2. 1_createS3bucket.sh: This script prompts the user for their AWS region and then creates an S3 bucket in that region. The data in the data_dctaxi folder is then uploaded into this S3 bucket.
3. 2_create_aws_role.sh: This script handles AWS IAM role creation and policy attachment for the Glue service. It prompts for the BUCKET_ID and AWS_DEFAULT_REGION to ensure the roles have the correct permissions.
4. 3_crawler.sh: This script sets up an AWS Glue Crawler, which scans the data in the S3 bucket and creates a data catalog. It also monitors the state of the crawler until it is complete.

## Usage

1. Execute the files in sequence, starting from 0.