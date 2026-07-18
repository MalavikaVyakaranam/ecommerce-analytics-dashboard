ALTER TABLE dim_customers
RENAME TO dim_customers_old;

select * from dim_customers_old;

CREATE TABLE dim_customers AS
WITH ranked AS (
    SELECT
        customer_id,
        country,
        MIN(invoice_date::date) AS first_purchase_date,
        COUNT(*)                AS frequency,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM staging_orders
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id, country
)
SELECT customer_id, country, first_purchase_date
FROM ranked
WHERE rn = 1;

SELECT customer_id, COUNT(*)
FROM dim_customers 	
GROUP BY customer_id
HAVING COUNT(*) > 1;