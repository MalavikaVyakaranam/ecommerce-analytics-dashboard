--Q1
with monthly_revenue as
(
select 
date_trunc('month',invoice_date) as month, ---> to consider precise value only starting from month
round(sum(revenue) :: numeric , 2) as total_revenue--> declared numeric due to accuracy issue with float (default data type for revenue)
from fact_orders group by month
)

select month,total_revenue, 
lag(total_revenue) over(order by month) as prev_month_revenue, --> lag of total_revenue ordered by month to display prev_month
round((total_revenue - lag(total_revenue) over(order by month) ) -->total_rev - prev_month/
       /
	   nullif(lag(total_revenue) over(order by month),0) --> prev_month
	   *100-->for percentage
	   ,2) as mom_growth_pct
from monthly_revenue order by month
--Q2
WITH yr AS (
select 
extract (year from invoice_date):: INT AS Y,
extract (month from invoice_date):: INT AS M,
sum(revenue) as rev
from fact_orders
group by Y,M
)--->extracts year,month, and it's sum of revenue
select m,
ROUND(
MAX(CASE WHEN Y=2010 THEN REV END):: NUMERIC, 2
) AS REV_2010,
ROUND(
MAX(CASE WHEN Y=2011 THEN REV END):: NUMERIC, 2
) AS REV_2011,
ROUND((
MAX(CASE WHEN Y=2011 THEN REV END) -
MAX(CASE WHEN Y=2010 THEN REV END))
/
NULLIF(MAX(CASE WHEN Y=2010 THEN REV END),0) * 100 :: NUMERIC,2
) AS YoY_PCT
from yr group by m order by m
--Q3

/*APPROACH 1 - USING NESTED SUM*/
select invoice_date,
ROUND(sum(revenue) :: NUMERIC,2) as daily_rev, -->TOTAL Per day
ROUND(sum(sum(revenue)) over(order by invoice_date) :: NUMERIC ,2)as running_total---> running total ,cummilative total
from fact_orders
group by invoice_date order by invoice_date

/*APPROACH 2 - CTE + WINDOW FUNCTION*/
WITH daily AS (
    SELECT
        invoice_date,
        ROUND(SUM(revenue)::numeric, 2) AS daily_rev
    FROM fact_orders
    GROUP BY invoice_date
)
SELECT
    invoice_date,
    daily_rev,
    ROUND(SUM(daily_rev) OVER (ORDER BY invoice_date)::numeric, 2) AS running_total
FROM daily
ORDER BY invoice_date;
--Q4
with actuals as (
select date_trunc('month', invoice_date) as month,
round(sum(revenue)::NUMERIC, 2) AS actual
from fact_orders
where  
EXTRACT(YEAR FROM invoice_date) = 2011
group by month)

select a.month, a.actual, 
ROUND((a.actual - d.budget_revenue) :: NUMERIC,2)as budget,
ROUND((a.actual - d.budget_revenue) / d.budget_revenue *100 :: NUMERIC ,2) as var_pct,
case when a.actual >= d.budget_revenue then 'On Target' else 'Below Target' end  as status
from actuals a join dim_budget d on a.month=d.month order by a.month
