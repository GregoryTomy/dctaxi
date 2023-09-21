/* Setting an upper bound for fare amount. 

Estiamte 1: maximum fare amount depends on the miles driver per work shift 
of a driver. DC taxi drivers are required to take at least 8 hours of rest from 
driving every 24 hours. Assuming a max of 16 driving hours and DC, Maryland and 
Virginia max speed limit at 70mph, we get the maximum of 1,120 miles travelled.
This mounts to (1,120 * 2.16 + 3.25) $2,422.45.

Estimate 2: Based on time. A cab can be hired for $35/hr. 35 * 16 - $560 

Estimate 3: Longest distance travelled. the area described is roughly a square 
with DC in the middle. */

select
    MIN(lat) AS lower_left_latitude,
    MIN(lon) AS lower_left_longitude,
    MAX(lat) AS upper_right_latitude,
    MAX(lon) AS upper_right_longitude
FROM (
    select
        MIN("origin_block_latitude_double") AS lat,
        MIN("origin_block_longitude_double") AS lon
    FROM "dc_taxi_parquet"
    
    UNION
    
    select
        MIN("destination_block_latitude_double") AS lat,
        MIN("destination_block_longitude_double") AS lon
    FROM "dc_taxi_parquet"
    
    UNION
    
    select
        MAX("origin_block_latitude_double") AS lat,
        MAX("origin_block_longitude_double") AS lon
    FROM "dc_taxi_parquet"
    
    UNION
    
    select
        MAX("destination_block_latitude_double") AS lat,
        MAX("destination_block_longitude_double") AS lon
    FROM "dc_taxi_parquet"
)

/* Plugging these values in OpenStreetMap yields 21.13 miles or an estimate of
$48.89.

Estimate 4: The central limit states that the sample means of random
samples of fare amount values is distributed according to the Gaussian distribution.
(independent and sampled with replacement) */

WITH dc_taxi AS(
    SELECT *,
        origindatetime_tr 
        || fareamount_string 
        || origin_block_latitude_string 
        || origin_block_longitude_string 
        || destination_block_latitude_string 
        || destination_block_longitude_string 
        || mileage_string AS objectid
    FROM "dc_taxi_parquet"
    WHERE
        "fareamount_double" >= 3.25 
        AND "fareamount_double" IS NOT NULL
        AND "mileage_double" > 0
),

dc_taxi_samples AS (
    SELECT 
        AVG("mileage_double") AS average_mileage
    FROM dc_taxi
    WHERE "objectid" IS NOT NULL
    GROUP BY
        MOD(ABS(from_big_endian_64(xxhash64(to_utf8("objectid")))), 1000)
)

SELECT
    AVG(average_mileage) + 4 * STDDEV(average_mileage)
FROM dc_taxi_samples
/* the application of the functions to objectid play the role of the unique 
identifier. The combination of the xxhash64 hashing function and the 
from_big_endian_64 produces what is effectively a pseudorandom but deterministic
value from objectid.This approach as the advantage of pseudorandom shuffle, 
eliminating unintended bias, and produced identical results accross queries 
regardless of additions to the data set as long as each row of data can be 
uniquely identified.

This query yields 12.138. Since 99.99% of values are within 4 std from the mean,
we have roughly $29.19 as another uppder bound estimate

Estimate 5: We do the same as estimate 4 but for "fareamount_double" */

WITH dc_taxi AS(
    SELECT *,
        origindatetime_tr 
        || fareamount_string 
        || origin_block_latitude_string 
        || origin_block_longitude_string 
        || destination_block_latitude_string 
        || destination_block_longitude_string 
        || mileage_string AS objectid
    FROM "dc_taxi_parquet"
    WHERE
        "fareamount_double" >= 3.25 
        AND "fareamount_double" IS NOT NULL
        AND "mileage_double" > 0
),

dc_taxi_samples AS (
    SELECT 
        AVG("fareamount_double") AS average_fareamount
    FROM dc_taxi
    WHERE "objectid" IS NOT NULL
    GROUP BY
        MOD(ABS(from_big_endian_64(xxhash64(to_utf8("objectid")))), 1000)
)

SELECT
    AVG(average_fareamount) + 4 * STDDEV(average_fareamount)
FROM dc_taxi_samples

/* returns an upper bound opf 15.96. Averaging the 5 estimates we get an upper 
bound of $615.30.