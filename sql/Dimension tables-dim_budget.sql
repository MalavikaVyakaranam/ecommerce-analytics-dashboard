-- Monthly revenue targets for 2011
-- Created manually -- realistic because Finance sends targets separately
CREATE TABLE dim_budget (
    month          DATE PRIMARY KEY, 
    budget_revenue DECIMAL(12,2)
);

INSERT INTO dim_budget VALUES
('2011-01-01',500000),('2011-02-01',520000),('2011-03-01',550000),
('2011-04-01',580000),('2011-05-01',600000),('2011-06-01',620000),
('2011-07-01',640000),('2011-08-01',680000),('2011-09-01',720000),
('2011-10-01',800000),('2011-11-01',950000),('2011-12-01',700000);

-- Verify
SELECT COUNT(*) FROM dim_budget;
-- Expected: 12 rows----12