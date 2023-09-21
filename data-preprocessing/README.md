# Data Preprocessing and Exploration for DC Taxi Dataset

This repository contains scripts and queries for preprocessing and exploring the DC Taxi dataset.

## Directory Structure

```plaintext
data-preprocessing
├── athena_exploration
│   ├── check_null_locations.sql
│   ├── est_fare_upper.sql
│   ├── validate_datetime.sql
│   └── validate_fareamount.sql
├── 0_dctaxi_csv_to_parquet.py
├── 1_parquet_glue_job.sh
├── 2_parquet_crawler.sh
├── 3_dctaxi_parquet_vacuum.py
├── 4_pyspark_job.sh
├── 5_dctaxi_dev_test.py
├── 6_pyspark_dev_test.sh
└── trips_sample.csv
```

## Athena Exploration

### Purpose:
The Athena SQL query exploration is intended for validating, cleaning, and deriving insights from the DC Taxi dataset.

### Files:

check_null_locations.sql: Identifies entries where location data might be missing or invalid.
est_fare_upper.sql: Estimates the upper bound for the fare amounts.
validate_datetime.sql: Validates the datetime format and checks for null or invalid entries.
validate_fareamount.sql: Validates fare amounts, corrects parsing errors, and provides summary statistics.

## Data Preprocessing

### Purpose:
The data preprocessing steps convert the DC Taxi dataset into a cleaner, validated, and more accessible format for downstream machine learning or analytics tasks.

### Files:

1. 0_dctaxi_csv_to_parquet.py: Converts the dataset from CSV to Parquet format.
2. 1_parquet_glue_job.sh: AWS Glue job script for managing Parquet files.
3. 2_parquet_crawler.sh: Shell script to crawl the Parquet dataset.
4. 3_dctaxi_parquet_vacuum.py: Cleans up the Parquet dataset.
5. 4_pyspark_job.sh: Entry script for running the PySpark job.
6. 5_dctaxi_dev_test.py: Random sampling and generating development and test datasets.
7. 6_pyspark_dev_test.sh: Entry shell script to run the development and test PySpark job.

### Usage

1. Run the Athena SQL queries for initial data exploration.
2. Run the data preprocessing steps in sequence, starting with 0_dctaxi_csv_to_parquet.py.