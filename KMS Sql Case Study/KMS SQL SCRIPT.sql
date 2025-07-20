SELECT * FROM order_status;

SELECT * FROM "kms sql case study";


-- 1. Product category with the highest sales
SELECT "Product Category", Sum("Sales") AS TotalSales
FROM "kms sql case study"
GROUP BY "Product Category"
ORDER BY TotalSales DESC
LIMIT 1;


-- 2i). Top 3 Regions by Sales
SELECT "Region", Sum("Sales") AS TotalSales
FROM "kms sql case study"
GROUP BY "Region"
ORDER BY TotalSales DESC
LIMIT 3;


-- 2ii). Bottom 3 Regions by Sales
SELECT "Region", Sum("Sales") AS TotalSales
FROM "kms sql case study"
GROUP BY "Region"
ORDER BY TotalSales ASC
LIMIT 3;



-- 3). Total sales of appliances in Ontario
SELECT Sum("Sales") AS TotalSales
FROM "kms sql case study"
WHERE "Product Sub-Category" = 'Appliances'
	AND "Region" = 'Ontario';



-- 4). Advise the management of KMS on what to do to increase the revenue from the bottom 
-- 10 customers

-- Identify bottom 10 customers and store this in a CTE (Common Table Expression)
SELECT "Customer Name", Sum("Sales") AS TotalSales
FROM "kms sql case study"
GROUP BY "Customer Name"
ORDER BY TotalSales ASC
LIMIT 10;

-- W'ell use Five Behavioural Analysis Queries
-- 4i). What segments do these customers belong to?
-- Answer: The buttom customers actually included customers from all segments.
WITH bottom_customers AS (
  SELECT "Customer Name"
  FROM "kms sql case study"
  GROUP BY "Customer Name"
  ORDER BY SUM("Sales") ASC
  LIMIT 10
)
SELECT bc."Customer Name", ks."Customer Segment"
FROM bottom_customers bc
JOIN "kms sql case study" ks ON bc."Customer Name" = ks."Customer Name"
GROUP BY bc."Customer Name", ks."Customer Segment";

-- 4ii).What product categories are they buying?
-- Answer: These customers tend to purchase low-ticket items or focus only on a narrow category like Office Supplies, 
-- avoiding higher-margin categories like Technology or Furniture.
WITH bottom_customers AS (
  SELECT "Customer Name"
  FROM "kms sql case study"
  GROUP BY "Customer Name"
  ORDER BY SUM("Sales") ASC
  LIMIT 10
)
SELECT ks."Customer Name", ks."Product Category", COUNT(*) AS Orders, SUM("Sales") AS TotalSales
FROM bottom_customers bc
JOIN "kms sql case study" ks ON bc."Customer Name" = ks."Customer Name"
GROUP BY ks."Customer Name", ks."Product Category"
ORDER BY TotalSales DESC;

-- 4iii). How many orders did they place?
-- Answer: The total number of orders by these customers is low, which directly impacts their overall sales contribution.
WITH bottom_customers AS (
  SELECT "Customer Name"
  FROM "kms sql case study"
  GROUP BY "Customer Name"
  ORDER BY SUM("Sales") ASC
  LIMIT 10
)
SELECT ks."Customer Name", COUNT(DISTINCT ks."Order ID") AS TotalOrders
FROM bottom_customers bc
JOIN "kms sql case study" ks ON bc."Customer Name" = ks."Customer Name"
GROUP BY ks."Customer Name"
ORDER BY TotalOrders ASC;

-- 4iv). What shipping modes do they prefer?
WITH bottom_customers AS (
  SELECT "Customer Name"
  FROM "kms sql case study"
  GROUP BY "Customer Name"
  ORDER BY SUM("Sales") ASC
  LIMIT 10
)
SELECT ks."Customer Name", ks."Ship Mode", COUNT(*) AS OrderCount
FROM bottom_customers bc
JOIN "kms sql case study" ks ON bc."Customer Name" = ks."Customer Name"
GROUP BY ks."Customer Name", ks."Ship Mode"
ORDER BY ks."Customer Name", OrderCount DESC;

-- 4v). Do they buy discounted products?
-- Answer: They often rely on discounted products, resulting in reduced revenue and possibly lower profits.
WITH bottom_customers AS (
  SELECT "Customer Name"
  FROM "kms sql case study"
  GROUP BY "Customer Name"
  ORDER BY SUM("Sales") ASC
  LIMIT 10
)
SELECT ks."Customer Name", AVG("Discount") AS AvgDiscount
FROM bottom_customers bc
JOIN "kms sql case study" ks ON bc."Customer Name" = ks."Customer Name"
GROUP BY ks."Customer Name"
ORDER BY AvgDiscount DESC;



-- 5). KMS incurred the most shipping cost using which shipping method? 
SELECT "Ship Mode", Sum("Shipping Cost") AS TotalShippingCost
FROM "kms sql case study"
GROUP BY "Ship Mode"
ORDER BY TotalShippingCost DESC
LIMIT 1;


-- 6). Who are the most valuable customers, and what products or services do they typically 
--purchase? 
-- 6i). FOR PRODUCTS

SELECT "Customer Name", "Product Sub-Category", SUM("Sales") AS TotalSales
FROM "kms sql case study"
GROUP BY "Customer Name", "Product Sub-Category"
ORDER BY TotalSales DESC
LIMIT 10;

-- 6ii). FOR SERVICES
SELECT "Customer Name", "Ship Mode", SUM("Sales") AS TotalSales
FROM "kms sql case study"
GROUP BY "Customer Name", "Ship Mode"
ORDER BY TotalSales DESC
LIMIT 10;



-- 7). Which small business customer had the highest sales? 
SELECT "Customer Name", SUM("Sales") AS TotalSales
FROM "kms sql case study"
WHERE "Customer Segment" = 'Small Business'
GROUP BY "Customer Name"
ORDER BY TotalSales DESC
LIMIT 1;



-- 8). Which Corporate Customer placed the most number of orders in 2009 – 2012?
SELECT "Customer Name", COUNT("Order Quantity") AS OrderQ
FROM "kms sql case study"
WHERE "Customer Segment" = 'Corporate'
	AND "Order Date" BETWEEN '2009-01-01' AND '2012-12-31'
GROUP BY "Customer Name"
ORDER BY OrderQ DESC
LIMIT 1;



-- 9). Which consumer customer was the most profitable one? 
SELECT "Customer Name", SUM("Sales") AS TotalSales
FROM "kms sql case study"
WHERE "Customer Segment" = 'Consumer'
GROUP BY "Customer Name"
ORDER BY TotalSales DESC
LIMIT 1;



-- 10). Which customer returned items, and what segment do they belong to?
SELECT "Customer Name", "Customer Segment"
FROM "kms sql case study"
INNER JOIN order_status
ON "order_id" = "Order ID"
WHERE "status" = 'Returned'
GROUP BY "Customer Name", "Customer Segment";



-- 11). If the delivery truck is the most economical but the slowest shipping method and 
--Express Air is the fastest but the most expensive one, do you think the company 
--appropriately spent shipping costs based on the Order Priority? Explain your answer

-- i). KMS incurred the most shipping cost using which shipping method? 
SELECT "Ship Mode", Sum("Shipping Cost") AS TotalShippingCost
FROM "kms sql case study"
GROUP BY "Ship Mode"
ORDER BY TotalShippingCost DESC
LIMIT 1;

-- ii). Were Delivery Truck mostly used for Low priority orders?
SELECT 
    "Order Priority",
    COUNT(*) AS OrderCount,
    SUM("Shipping Cost") AS TotalShippingCost
FROM 
    "kms sql case study"
WHERE 
    "Ship Mode" = 'Delivery Truck'
GROUP BY 
    "Order Priority"
ORDER BY 
    TotalShippingCost DESC;

-- iii). Is Delivery Truck Really the Most Economical? 
SELECT "Ship Mode", 
       COUNT(*) AS OrderCount,
       SUM("Shipping Cost") AS TotalShippingCost,
       SUM("Shipping Cost") / COUNT(*) AS AvgShippingCostPerOrder
FROM "kms sql case study"
GROUP BY "Ship Mode"
ORDER BY AvgShippingCostPerOrder ASC;


