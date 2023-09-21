# Athena Exploration for DC Taxi Data

This repository contains a set of SQL queries designed to perform data exploration and validation on a dataset of Washington, DC taxi trips, stored in a table named dc_taxi_parquet. The dataset includes various features such as datetime of the ride, fare amount, origin and destination coordinates, and mileage. These queries run on Amazon Athena and are crucial for ensuring data quality and integrity before any further analysis or machine learning tasks are performed.

## File Structure

```plaintext
athena_exploration/
├── check_null_locations.sql
├── est_fare_upper.sql
├── validate_datetime.sql
└── validate_fareamount.sql
```

## File Descriptions
> check_null_locations.sql

This query is designed to identify null values in location-based columns. It helps to ascertain how many records lack essential geolocation data, such as latitude and longitude for both the origin and destination. This is crucial for any geospatial analysis or feature engineering based on locations.

> est_fare_upper.sql

This query estimates an upper bound for fare amounts using various methods, including:

1. Maximum miles driven per work shift based on legal requirements and speed limits.
2. Maximum fare based on time, assuming the cab is hired for the maximum number of hours in a shift.
3. Fare for the longest possible distance within the data's geographical scope.
4. Statistical measures like mean and standard deviation to find a probable upper limit for the fare.
5. This upper limit will serve as a guide for data cleaning and outlier detection.

> validate_datetime.sql

This query validates the origindatetime_tr column to ensure that all timestamps conform to a specified format. It counts the number of records that fail this validation, which is crucial for any time-series analysis or features based on time and date.

> validate_fareamount.sql

This comprehensive query performs several checks on the fareamount_double column to validate the fare amounts in the dataset. It:

1. Checks for NULL values and parsing errors from STRING to DOUBLE.
2. Calculates summary statistics like mean, median, quartiles, and standard deviation.
3. Validates the fare amounts against a pre-determined minimum and an estimated upper bound.
4. It helps to identify outliers or erroneous fare amounts that can affect the quality of further analyses.

# Usage

Each SQL file is a standalone query that can be run on Amazon Athena to perform its designated validation or exploration task on the dc_taxi_parquet dataset.

# Goals

The primary objective of running these queries is to validate the data for:

1. Consistency
2. Completeness
3. Range accuracy
This step is vital for anyone aiming to use this data for further statistical analysis, data visualization, or machine learning model building.

# Prerequisites
1. Access to the dc_taxi_parquet dataset on Amazon Athena.
2. Basic SQL and Amazon Athena knowledge for query execution.
By ensuring that the data is clean, valid, and ready for analysis, these queries lay the foundation for any high-quality data science or machine learning project.