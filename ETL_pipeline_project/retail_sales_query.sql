SELECT *
FROM retail_sales;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'retail_sales';

ALTER TABLE retail_sales
ALTER COLUMN unit_price type numeric using unit_price::numeric;

ALTER TABLE retail_sales
ALTER COLUMN total_sales type numeric using total_sales::numeric;


-- Store with highest sales
SELECT store_location, sum(total_sales) AS total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- Top 5 best-selling products by quantity
SELECT product_name, sum(quantity) AS quantity
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- Sales by month and category
SELECT product_category, month, sum(total_sales) AS total_sales
FROM retail_sales
GROUP BY 1,2
ORDER BY 2,3 DESC;


-- Correlation between payment method and purchase amount
SELECT payment_method, ROUND(AVG(total_sales), 2) AS Avg_purchase
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;


-- Age group with the highest customer purchase
SELECT age_group, SUM(total_sales) AS total_purchase
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;