---->Q7
WITH
	BASE AS (
		SELECT
			CUSTOMER_ID,
			MAX(INVOICE_DATE) AS LAST_BUY,
			COUNT(DISTINCT INVOICE_NO) AS FREQ,
			ROUND(SUM(REVENUE)::NUMERIC, 2) AS MONETARY
		FROM
			FACT_ORDERS
		GROUP BY
			CUSTOMER_ID
	),
	SCORE AS (
		SELECT *,
			('2012-01-01'::DATE - LAST_BUY
	) AS RECENCY_DAYS,
	
	NTILE(5) OVER (
		ORDER BY
			('2012-01-01'::DATE - LAST_BUY) DESC
	) AS R, 
	NTILE(5) OVER (
		ORDER BY
			FREQ DESC
	) AS F, 
	NTILE(5) OVER (
		ORDER BY
			MONETARY DESC
	) AS M
FROM
	BASE)
	SELECT *, CONCAT(R,F,M) AS RFM_CODE,
	CASE  
	WHEN R >=4 AND F >=4 THEN 'Champion'
	WHEN R >=3 AND F >=3 THEN 'Loyal'
	WHEN R >=3 AND F <=2 THEN 'Potential'
	WHEN R <=2 AND F >=3 THEN 'At Risk'
	WHEN R =1 AND F =1 THEN 'Lost'
	else 'Others'
	end as segment
	FROM SCORE


	
--->Q8
with pc as (select customer_id, count(distinct invoice_no) as orders from fact_orders group by customer_id )
select CASE WHEN orders = 1 THEN 'One-Time'
            WHEN orders between 2 and 5 THEN 'Occasional'
			ELSE  'Loyal'
			END As buyer_type,
			count(*) as customers,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () ,2) AS PCT FROM PC GROUP BY 1



