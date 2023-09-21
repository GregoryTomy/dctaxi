-- Checking Validation Rules for Origin Locations
SELECT ROUND(
        100.0 * COUNT(*) / (
            SELECT COUNT(*)
            FROM "dc_taxi_parquet"
        ),
        2
    ) AS percentage_null,
    (
        SELECT COUNT(*)
        FROM dc_taxi_parquet
        WHERE "origin_block_latitude_double" IS NULL
            OR "origin_block_longitude_double" IS NULL
    ) AS either_null,
    (
        SELECT COUNT(*)
        FROM dc_taxi_parquet
        WHERE "origin_block_latitude_double" IS NULL
            AND "origin_block_longitude_double" IS NULL
    ) AS both_null
FROM "dc_taxi_parquet"
WHERE "origin_block_latitude_double" IS NULL
    OR "origin_block_longitude_double" IS NULL;

-- Checking Validation Rules for Destination Locations
SELECT ROUND(
        100.0 * COUNT(*) / (
            SELECT COUNT(*)
            FROM "dc_taxi_parquet"
        ),
        2
    ) AS percentage_null,
    (
        SELECT COUNT(*)
        FROM dc_taxi_parquet
        WHERE "destination_block_latitude_double" IS NULL
            OR "destination_block_longitude_double" IS NULL
    ) AS either_null,
    (
        SELECT COUNT(*)
        FROM dc_taxi_parquet
        WHERE "destination_block_latitude_double" IS NULL
            AND "destination_block_longitude_double" IS NULL
    ) AS both_null
FROM "dc_taxi_parquet"
WHERE "destination_block_latitude_double" IS NULL
    OR "destination_block_longitude_double" IS NULL;

-- Checking for Rows with At Least One NULL Location
SELECT
    COUNT(*) as total,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM dc_taxi_parquet), 2) AS percent
FROM dc_taxi_parquet
WHERE "origin_block_latitude_double" IS NULL
    OR "origin_block_longitude_double" IS NULL
    OR  "destination_block_latitude_double" IS NULL
    OR "destination_block_longitude_double" IS NULL;
