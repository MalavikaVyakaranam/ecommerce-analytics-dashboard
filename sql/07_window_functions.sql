---Q11
with co as (select customer_id, invoice_date,
LAG(invoice_date) over (partition by customer_id order by invoice_date) as PREV
from fact_orders),
gaps as (select customer_id, (invoice_date - PREV) as days_between
from co 
where  PREV is NOT NULL  AND (invoice_date - prev) > 0 )

SELECT ROUND(AVG(DAYS_BETWEEN),1) AS avg_days_between_orders,
ROUND(MIN(DAYS_BETWEEN),1) AS min_gap,
ROUND(MAX(DAYS_BETWEEN),1) AS max_gap
from gaps;

-- KEY FINDING: Average days between orders = 45.7 days (~6 weeks)
-- Min gap = 1 day  (back-to-back buyers, likely B2B customers)
-- Max gap = 366 days (once-a-year buyers, likely Lost segment)
-- RECOMMENDATION:
-- Trigger re-engagement email at Day 44 (just before avg gap)
-- Flag any customer exceeding Day 60 as At Risk in CRM system

---Q12
WITH order_dates AS (
    -- Step 1: one row per customer per unique order DATE
    SELECT DISTINCT
        customer_id,
        invoice_date::date AS order_date
    FROM fact_orders
),
with_lead AS (
    -- Step 2: now apply LEAD on clean distinct dates
    SELECT
        customer_id,
        order_date AS current_order,
        LEAD(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS next_order
    FROM order_dates
)
SELECT
    customer_id,
    current_order,
    next_order,
    (next_order - current_order) AS days_to_next
FROM with_lead
WHERE next_order IS NOT NULL  -- remove last orders
ORDER BY customer_id, current_order;


WITH CR AS (
SELECT F.CUSTOMER_ID, C. COUNTRY, 
ROUND(SUM(REVENUE) :: NUMERIC ,2) AS TOTAL_REVENUE,
COUNT(DISTINCT F.INVOICE_NO) AS TOTAL_ORDERS,
ROUND(SUM(REVENUE) / COUNT(DISTINCT F.INVOICE_NO) :: NUMERIC ,2) AS AVG_ORDER_VALUE
FROM FACT_ORDERS F JOIN DIM_CUSTOMERS C ON F.CUSTOMER_ID=C.CUSTOMER_ID 
GROUP BY 1,2 
),

RANKED AS (
SELECT *, 
DENSE_RANK() OVER(PARTITION BY COUNTRY ORDER BY  TOTAL_REVENUE DESC) AS COUNTRY_RANK
FROM CR
)
SELECT * FROM RANKED WHERE COUNTRY_RANK = 1 ORDER BY TOTAL_REVENUE DESC


-- TOP CUSTOMER PER COUNTRY — KEY FINDINGS:
-- 37 unique countries in dataset
-- EIRE: strongest international market (201 orders, consistent)
-- Australia: highest avg order value £5,948 (likely B2B wholesale)
-- USA, Brazil, Saudi Arabia: single order only → no repeat business
-- Germany: underperforms vs market size → investigate pricing/product fit
-- Single-order countries (Israel, Greece, USA etc): need localised campaigns
-- RECOMMENDATION:
-- Priority markets: EIRE, Australia, Sweden, Japan → invest in retention
-- Opportunity markets: Germany, France → grow with targeted campaigns  
-- Single-order markets: USA, Brazil → test localised marketing
