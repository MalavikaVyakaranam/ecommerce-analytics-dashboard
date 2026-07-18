ALTER TABLE fact_orders
ADD COLUMN invoice_month DATE;

UPDATE fact_orders
SET invoice_month = DATE_TRUNC('month', invoice_date)::date;


SELECT invoice_date, invoice_month
FROM fact_orders
LIMIT 5;