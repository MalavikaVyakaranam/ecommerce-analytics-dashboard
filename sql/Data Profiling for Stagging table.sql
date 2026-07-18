SELECT COUNT(*) AS cancelled 
FROM staging_orders
WHERE invoice_no LIKE 'C%';

select 
sum(case when customer_id is null then 1 else 0 end) as  null_customers,
sum(case when quantity <=0 then 1 else 0 end ) as bad_quantity,
sum(case when unit_price <=0 then 1 else 0 end) as bad_price
from staging_orders;

