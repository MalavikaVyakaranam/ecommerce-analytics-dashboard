DROP TABLE IF EXISTS dim_products

CREATE TABLE dim_products AS
WITH ranked AS (
    SELECT
        UPPER(TRIM(stock_code))       AS product_id,
        UPPER(TRIM(description))      AS product_description,
        COUNT(*)                      AS frequency,
        ROW_NUMBER() OVER (
            PARTITION BY UPPER(TRIM(stock_code))
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM staging_orders
    WHERE stock_code  IS NOT NULL
      AND description IS NOT NULL
    GROUP BY UPPER(TRIM(stock_code)), UPPER(TRIM(description))
)
SELECT product_id, product_description
FROM ranked
WHERE rn = 1;

SELECT COUNT(*) FROM dim_products;--3848

SELECT product_id, COUNT(*)
FROM dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;-------0


UPDATE fact_orders
SET product_id = UPPER(TRIM(product_id));

SELECT product_id
FROM dim_products
WHERE product_id LIKE '%bl%'
   OR product_id LIKE '%BL%';

   
SELECT DISTINCT product_id FROM dim_products LIMIT 5;
SELECT DISTINCT product_id FROM fact_orders  LIMIT 5;