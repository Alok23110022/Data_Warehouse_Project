/* Exploratory Data Analysis (EDA) for different Dimensions and Measures Using SQL */

-- Database Exploration

SELECT * FROM INFORMATION_SCHEMA.TABLES;
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'facts_sales';

-- Dimension Exploration

SELECT DISTINCT country FROM gold.dim_customers;
SELECT DISTINCT category, sub_category, product_name FROM gold.dim_products
	ORDER BY 1,2,3;

-- DATE Exploration

SELECT MIN(order_date) AS first_order_date,
	   MAX(order_date) AS last_order_date 
FROM gold.facts_sales;

SELECT MIN(birth_date) AS oldest_customer,
	   DATEDIFF(year, MIN(birth_date), GETDATE()) AS Age
FROM gold.dim_customers;

-- Measures Exploration
SELECT SUM(sales) AS total_sales,
	   SUM(quantity) AS total_items,
	   AVG(price) AS avg_selling_price,
	   COUNT(DISTINCT order_number) AS total_orders,
	   COUNT(DISTINCT product_key) AS total_products,
	   COUNT(DISTINCT customer_key) AS total_customers
FROM gold.facts_sales

SELECT 'Total Sales' AS measure_name, SUM(sales) AS measure_value FROM gold.facts_sales
UNION ALL 
SELECT 'Total Quantity', SUM(quantity) FROM gold.facts_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.facts_sales
UNION ALL
SELECT 'Total Customers', COUNT(DISTINCT customer_id) FROM gold.dim_customers
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.facts_sales

-- Magnitude Analysis

SELECT 
	country,
	COUNT(DISTINCT customer_key) AS Total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY Total_customers DESC;

SELECT 
	gender,
	COUNT(DISTINCT customer_key) AS Total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY Total_customers DESC;

SELECT 
	category,
	COUNT(DISTINCT product_key) AS Total_Products
FROM gold.dim_products
GROUP BY category
ORDER BY Total_Products DESC;

SELECT 
	dp.category,
	AVG(fs.price) AS Average_Price
FROM gold.facts_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
GROUP BY dp.category
ORDER BY Average_Price DESC;

SELECT 
	dp.category,
	SUM(sales) AS Total_Revenue
FROM gold.facts_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
GROUP BY dp.category
ORDER BY Total_Revenue DESC;

SELECT 
	DISTINCT dc.customer_id,
	SUM(fs.sales) AS Total_Revenue
FROM gold.facts_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_id
ORDER BY Total_Revenue DESC;

-- Ranking Analysis For getting the top as well bottom performers

WITH CTE AS (
SELECT
	dp.product_name,
	SUM(fs.sales) AS Total_Revenue,
	ROW_NUMBER() OVER(ORDER BY SUM(fs.sales) DESC) AS ranked_revenue
FROM gold.facts_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
GROUP BY dp.product_name)

SELECT * FROM CTE WHERE ranked_revenue <= 5;

SELECT TOP 3
	dc.customer_id,
	dc.first_name,
	dc.last_name,
	COUNT( DISTINCT fs.order_number) AS total_orders
FROM gold.facts_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_id, dc.first_name, dc.last_name
ORDER BY total_orders ASC;
