-- Check for NULL in origindatetime_tr
SELECT 
    (
    SELECT
        COUNT(*)
    FROM "dc_taxi_parquet"
    ) AS total,
    COUNT(*) AS null_origindate_time_total
FROM "dc_taxi_parquet"
WHERE "origindatetime_tr" IS NULL;

-- Check for valid timestamp values
SELECT
    (SELECT COUNT(*) FROM dc_taxi_db.dc_taxi_parquet)
    - COUNT(DATE_PARSE(origindatetime_tr, '%m/%d/%Y %H:%i'))
    AS origindatetime_not_parsed
FROM
    dc_taxi_db.dc_taxi_parquet
WHERE
    origindatetime_tr IS NOT NULL;
