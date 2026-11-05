-- 1 Preview the data
SELECT *
FROM suryahub.suryahub
LIMIT 10;

-- row and customers
 Select COUNT(*)   AS total_rows,
COUNT(DISTINCT Customer_ID) AS unique_customers
FROM  suryahub.suryahub;

-- 3 Missing values in the columns used below
SELECT 
	sum(Customer_ID IS NULL)           AS null_customer_id,
	sum(Location IS NULL)              AS null_location,
	sum(Purchase_Amount IS NULL)       AS null_purchase_amount,
	sum(Frequency_of_Purchase IS NULL) AS null_frequency,
	sum(Purchase_Channel IS NULL)      AS null_channel
FROM suryahub;

-- 0.4 Range of Purchase_Amount (confirms the scale before segmentation in section 4)
SELECT
  MIN(Purchase_Amount)           AS min_amount,
  ROUND(AVG(Purchase_Amount), 2) AS avg_amount,
  MAX(Purchase_Amount)           AS max_amount
FROM suryahub.suryahub;

-- =====================================================================
-- 1. CUSTOMER OVERVIEW
-- =====================================================================
 
-- Q1: How do purchases and average spend compare by gender?
SELECT
  Gender,
  COUNT(*)                       AS total_purchases,
  ROUND(AVG(Purchase_Amount), 2) AS avg_amount
FROM suryahub.suryahub
GROUP BY Gender
ORDER BY total_purchases DESC;
 
 -- Q2: Which 5 locations have the most customers?
SELECT
  Location,
  COUNT(DISTINCT Customer_ID)    AS total_customers,
  ROUND(AVG(Purchase_Amount), 2) AS avg_amount
FROM suryahub.suryahub
GROUP BY Location
ORDER BY total_customers DESC
LIMIT 5;


 -- 2. PURCHASE BEHAVIOR
-- =====================================================================
 
-- Q3: Which purchase channel has the highest average spend?
SELECT
  Purchase_Channel,
  COUNT(*)                                 AS total_purchases,
  ROUND(AVG(Purchase_Amount), 2)           AS avg_amount,
  ROUND(AVG(Frequency_of_Purchase), 2)     AS avg_frequency
FROM suryahub
GROUP BY Purchase_Channel
ORDER BY avg_amount DESC;

-- Q4: Does purchase intent relate to spend and frequency?
SELECT
  Purchase_Intent,
  COUNT(*)                                 AS total_purchases,
  ROUND(AVG(Purchase_Amount), 2)           AS avg_amount,
  ROUND(AVG(Frequency_of_Purchase), 2)     AS avg_frequency
FROM suryahub
GROUP BY Purchase_Intent
ORDER BY avg_amount DESC;

-- Q5: Do loyalty program members spend more or buy more often?
SELECT
  Customer_Loyalty_Program_Member,
  COUNT(*)                                 AS total_purchases,
  ROUND(AVG(Purchase_Amount), 2)           AS avg_amount,
  ROUND(AVG(Frequency_of_Purchase), 2)     AS avg_frequency
FROM suryahub
GROUP BY Customer_Loyalty_Program_Member;

-- Q6: How many of the most loyal customers (Brand_Loyalty = 5) use discounts?
SELECT
  Discount_Used,
  COUNT(*)                                          AS total,
  ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 2)  AS pct
FROM suryahub
WHERE Brand_Loyalty = 5
GROUP BY Discount_Used;

-- Q7: Do customers who use discounts spend differently?
SELECT
  Discount_Used,
  COUNT(*)                       AS total_purchases,
  ROUND(AVG(Purchase_Amount), 2) AS avg_amount
FROM suryahub
GROUP BY Discount_Used;


-- =====================================================================
-- 3. TOP CUSTOMERS
-- =====================================================================
 
-- Q8: Who are the top 10 customers by purchase value?
-- Each Customer_ID appears once (498 rows, 498 customers), so total_spent
-- equals a single purchase amount.
SELECT
  Customer_ID,
  SUM(Purchase_Amount)  AS total_spent,
  MAX(Location)         AS location,
  MAX(Purchase_Channel) AS channel,
  MAX(Brand_Loyalty)    AS brand_loyalty
FROM suryahub
GROUP BY Customer_ID
ORDER BY total_spent DESC
LIMIT 10;


-- =====================================================================
-- 4. CUSTOMER SEGMENTATION (CASE WHEN)
-- =====================================================================
 
-- Q9: Segment purchases into High / Medium / Low spend.
-- Purchase_Amount ranges from about 0.8M to 7.7M (see query 0.4), so the cutoffs
-- are set near the 33rd and 67th percentiles (about 3.08M and 5.45M), rounded.
SELECT
  CASE
    WHEN Purchase_Amount >= 5500000 THEN 'High'
    WHEN Purchase_Amount >= 3000000 THEN 'Medium'
    ELSE 'Low'
  END AS segment,
  COUNT(*)                             AS total_purchases,
  ROUND(AVG(Frequency_of_Purchase), 2) AS avg_frequency
FROM suryahub
GROUP BY segment
ORDER BY total_purchases DESC;

-- =====================================================================
-- 5. ADVANCED QUERIES (SUBQUERY, CTE, WINDOW FUNCTION)
-- =====================================================================
 
-- Q10: Which locations spend more than the overall average? (HAVING + subquery)
SELECT
  Location,
  ROUND(AVG(Purchase_Amount), 2) AS avg_amount
FROM `project-suryahub.SuryaHub.suryaHub`
GROUP BY Location
HAVING AVG(Purchase_Amount) > (
  SELECT AVG(Purchase_Amount)
  FROM suryahub
)
ORDER BY avg_amount DESC;

-- Q11: Who are the top 3 customers in each location? (CTE + window function)
-- Because each customer has one row, this ranks single purchases within a location.
-- RANK() keeps ties, so a location can return more than 3 rows.
WITH customer_totals AS (
  SELECT
    Customer_ID,
    Location,
    SUM(Purchase_Amount) AS total_spent
  FROM suryahub
  GROUP BY Customer_ID, Location
)
SELECT
  *,
  RANK() OVER (PARTITION BY Location ORDER BY total_spent DESC) AS spend_rank
FROM customer_totals
QUALIFY spend_rank <= 3;
