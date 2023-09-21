-- checking and cleaning up invalid fareamounts.
SELECT
    "fareamount_string",
    COUNT("fareamount_string") AS rows,
    ROUND(100.0 * COUNT("fareamount_string") / 
        (SELECT COUNT(*) FROM "dc_taxi_parquet"), 2) AS precent
FROM "dc_taxi_parquet"
WHERE "fareamount_double" IS null
    AND "fareamount_string" IS NOT null
GROUP BY "fareamount_string";

-- "fareamount_string" is populated for those far amount values that failed the 
-- parsing from STRING to DOUBLE
-- There are 3,349,64 or 0.63% of the data where the parse failed. All correspond
-- to whre "fareamount_string" == 'NULL'.

-- Next we check summary statistics
WITH sq AS (
    SELECT "fareamount_double" AS val
    FROM dc_taxi_parquet
),

stats AS (
    SELECT
        MIN(val) AS min,
        approx_percentile(val, 0.25) AS q1,
        approx_percentile(val, 0.50) AS q2,
        approx_percentile(val, 0.75) AS q3,
        AVG(val) AS mean,
        STDDEV(val) AS std,
        MAX(val) AS max
    FROM sq
)

SELECT distinct min, q1, q2, q3, max
FROM stats;

-- we have negative values. We know fares cannot be less than $3.25 (min charge)
WITH sq2 AS (
    SELECT COUNT(*) AS total
    FROM "dc_taxi_parquet"
    WHERE "fareamount_double" IS NOT NULL
)

SELECT 
    ROUND(100.0 * COUNT("fareamount_double") / MAX(total), 2) AS precent
FROM dc_taxi_parquet, sq2
WHERE ("fareamount_double" < 3.25
    AND "fareamount_double" IS NOT NULL);
-- only 0.62% of the data are impacted by fare amount values that are below
-- the threshold.


-- Use "mileage_double" column to help understand the cases when mileage of the 
-- trip translates into NULL fareamounts
SELECT
    "fareamount_string",
    MIN("mileage_double") AS min,
    approx_percentile("mileage_double", 0.25) AS q1,
    approx_percentile("mileage_double", 0.50) AS q2,
    approx_percentile("mileage_double", 0.75) AS q3,
    MAX("mileage_double") AS max
FROm "dc_taxi_parquet"
WHERE "fareamount_string" LIKE 'NULL'
GROUP BY "fareamount_string"
/* more than a quarter of the mileage values correspond to 0 miles.
at least a quarter (50th to 75th percentile) appear to be in a reasonable 
mileage */


-- rerunning summary statistics after validation and new bounds 
-- (check estiamting farte amount)

WITH sq_val AS (
    SELECT "fareamount_double" as val
    FROM "dc_taxi_parquet"
    WHERE "fareamount_double" IS NOT NULL
         AND "fareamount_double" >= 3.25
         AND "fareamount_double" <= 616 --number from estiamting_fare_upperbound
)

SELECT
    ROUND(MIN(val), 2) AS min,
    ROUND(approx_percentile(val, 0.25), 2) AS q1,
    ROUND(approx_percentile(val, 0.5), 2) AS q2,
    ROUND(approx_percentile(val, 0.75), 2) AS q3,
    ROUND(MAX(val), 2) AS max,
    ROUND(AVG(val), 2) AS mean,
    ROUND(STDDEV(val), 2) AS std
FROM sq_val