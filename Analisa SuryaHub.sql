SELECT * FROM `project-suryahub.SuryaHub.suryaHub` LIMIT 1000;
SELECT COUNT(*) AS total_pembelian
FROM `project-suryahub.SuryaHub.suryaHub`
WHERE  Gender = 'Female';

SELECT Location, COUNT(DISTINCT Customer_ID) AS total_customers
FROM `SuryaHub.suryaHub`
GROUP BY  Location
ORDER BY total_customers DESC
LIMIT 5;

SELECT Discount_Used, COUNT(*) AS total
FROM `SuryaHub.suryaHub`
WHERE Brand_Loyalty = 5
GROUP BY Discount_Used;

SELECT 
    Purchase_Intent, 
    ROUND(AVG(Purchase_Amount), 2) AS avg_amount,
    ROUND(AVG(Frequency_of_Purchase), 2) AS avg_frequency
FROM `SuryaHub.suryaHub`
GROUP BY Purchase_Intent
ORDER BY avg_amount DESC;

SELECT 
    Purchase_Channel,
    ROUND(AVG(Purchase_Amount), 2) AS avg_amount,
    ROUND(AVG(Frequency_of_Purchase), 2) AS avg_frequency
FROM `SuryaHub.suryaHub`
GROUP BY Purchase_Channel
ORDER BY avg_amount DESC;

SELECT 
    Customer_Loyalty_Program_Member,
    ROUND(AVG(Purchase_Amount), 2) AS avg_amount,
    ROUND(AVG(Frequency_of_Purchase), 2) AS avg_frequency
FROM `SuryaHub.suryaHub`
GROUP BY Customer_Loyalty_Program_Member;

SELECT 
    Customer_ID, 
    SUM(Purchase_Amount) AS total_spent,
    MAX(Location) AS Location,
    MAX(Purchase_Channel) AS Channel,
    MAX(Brand_Loyalty) AS Brand_Loyalty
FROM `SuryaHub.suryaHub`
GROUP BY Customer_ID
ORDER BY total_spent DESC
LIMIT 10;

#Segmentasi pelanggan dengan CASE WHEN
SELECT
  CASE
    WHEN Purchase_Amount >= 400 THEN 'High'
    WHEN Purchase_Amount >= 200 THEN 'Medium'
    ELSE 'Low'
  END AS segmen,
  COUNT(*) AS jumlah,
  ROUND(AVG(Frequency_of_Purchase), 2) AS avg_frekuensi
FROM `SuryaHub.suryaHub`
GROUP BY segmen
ORDER BY jumlah DESC;

#HAVING: lokasi dengan rata-rata belanja di atas rata-rata keseluruhan
SELECT Location, ROUND(AVG(Purchase_Amount), 2) AS avg_amount
FROM `SuryaHub.suryaHub`
GROUP BY Location
HAVING AVG(Purchase_Amount) > (SELECT AVG(Purchase_Amount) FROM `SuryaHub.suryaHub`)
ORDER BY avg_amount DESC;

#CTE + window function: peringkat pelanggan dalam tiap lokasi
WITH total AS (
  SELECT Customer_ID, Location, SUM(Purchase_Amount) AS total_spent
  FROM `SuryaHub.suryaHub`
  GROUP BY Customer_ID, Location
)
SELECT *,
  RANK() OVER (PARTITION BY Location ORDER BY total_spent DESC) AS peringkat
FROM total
QUALIFY peringkat <= 3;