ALTER TABLE dim_date
RENAME TO dim_date_old;
-- Step 1: Drop old dim_date
--DROP TABLE IF EXISTS dim_date;

-- Step 2: Create complete date table with no gaps
CREATE TABLE dim_date AS
SELECT
    gen_date::date                              AS date_id,
    EXTRACT(YEAR  FROM gen_date)::INT           AS year,
    EXTRACT(MONTH FROM gen_date)::INT           AS month,
    EXTRACT(DAY   FROM gen_date)::INT           AS day,
    TO_CHAR(gen_date, 'Month')                  AS month_name,
    TO_CHAR(gen_date, 'Day')                    AS day_name,
    EXTRACT(QUARTER FROM gen_date)::INT         AS quarter,
    EXTRACT(DOW FROM gen_date)::INT             AS day_of_week,
    CASE
        WHEN EXTRACT(DOW FROM gen_date) IN (0,6)
        THEN 'Weekend' ELSE 'Weekday'
    END                                         AS day_type
FROM GENERATE_SERIES(
    '2010-12-01'::date,   -- first date in your dataset
    '2011-12-31'::date,   -- last date in your dataset
    '1 day'::interval
) AS gen_date;

-- Step 3: Verify row count
SELECT COUNT(*) FROM dim_date;
-- Should return 396 rows (every day Dec 2010 to Dec 2011)

-- Step 4: Verify no gaps
SELECT
    MIN(date_id) AS first_date,
    MAX(date_id) AS last_date,
    COUNT(*)     AS total_days,
    (MAX(date_id) - MIN(date_id) + 1) AS expected_days
FROM dim_date;
-- total_days must equal expected_days → no gaps