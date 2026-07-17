/* Advance Data Analytics USING SQL queries for practice later verfying it using Visualization Tool*/

-- Time Trend Analysis
SELECT 
	YEAR(order_date) AS Date_YEAR,
	DATENAME(month,order_date) AS Date_MONTH,
	SUM(sales) AS Total_Revenue,
	COUNT(DISTINCT customer_key) AS customer_gained,
	SUM(quantity) AS product_sold
FROM gold.facts_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), DATENAME(month,order_date)
ORDER BY Date_YEAR, Date_MONTH

-- Cummalative Analysis 

WITH CTE AS (
SELECT
    YEAR(order_date) AS Order_Year,
    MONTH(order_date) AS Month_no,
    DATENAME(month, order_date) AS Order_Month,
    SUM(sales) AS Total_Revenue,
    AVG(price) AS Average_Price
FROM gold.facts_sales
WHERE order_date IS NOT NULL
GROUP BY
    YEAR(order_date),
    MONTH(order_date),
    DATENAME(month, order_date)
)
SELECT Order_Year, Order_Month, Total_Revenue, Average_Price,
    SUM(Total_Revenue) OVER(PARTITION BY Order_Year ORDER BY Month_no) AS Running_Total,
    AVG(Average_Price) OVER(PARTITION BY Order_Year ORDER BY Month_no) AS Moving_Average
FROM CTE

-- Performance Analysis For Year to Year Comparison

WITH CTE AS(
SELECT 
    dp.product_name AS product_name,
    YEAR(fs.order_date) AS order_year,
    SUM(fs.sales) AS current_year_sales,
    LAG(SUM(fs.sales)) OVER(PARTITION BY dp.product_name ORDER BY dp.product_name,
                                YEAR(fs.order_date)) AS previous_year_sales
FROM gold.facts_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
WHERE fs.order_date IS NOT NULL
GROUP BY dp.product_name, YEAR(fs.order_date)
)

SELECT *,
    CASE 
        WHEN previous_year_sales IS NULL THEN NULL
        ELSE CONCAT(CAST((((current_year_sales - previous_year_sales)*100.00)/ previous_year_sales) AS DECIMAL(10,2)),'%')
    END AS Growth_Index,

    CASE
        WHEN previous_year_sales IS NULL THEN 'First Sale'
        WHEN (current_year_sales - previous_year_sales) < 0 THEN 'Under Performing'
        WHEN (current_year_sales - previous_year_sales) >0  THEN 'Upper Performing'
        ELSE 'No data available'
    END AS Performance_Index
        
FROM CTE

-- Performance Analysis (Part to Whole Analysis)

WITH CTE AS (
SELECT
    dp.category,
    SUM(fs.sales) AS total_category_sales
FROM gold.facts_sales fs
LEFT JOIN gold.dim_products dp 
ON fs.product_key = dp.product_key
GROUP BY dp.category)

SELECT *,
SUM(total_category_sales) OVER() AS total_sales,
CONCAT(CAST(((total_category_sales*100.00)/SUM(total_category_sales) OVER()) AS DECIMAL(10,2)),'%') AS percentage_contribution
FROM CTE

-- DATA SEGMENTATION using the CASE WHEN Statements

WITH CTE AS (
SELECT 
    fs.product_key,
    dp.product_name,
    CASE 
        WHEN fs.price < 100 THEN 'Cheap'
        WHEN fs.price BETWEEN 100 AND 500 THEN 'Moderate'
        WHEN fs.price BETWEEN 500 AND 2000 THEN 'Expensive'
        ELSE 'Extreme Expensive'
    END AS product_categorization
FROM gold.facts_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key)

SELECT product_categorization,
    count(*) AS value
FROM CTE 
GROUP BY product_categorization


WITH CTE AS 
(SELECT
    c.customer_key,
    SUM(f.sales) AS total_spending,
    MIN(f.order_date) AS first_order,
    MAX(f.order_date) AS last_order,
    DATEDIFF(month, MIN(f.order_date),MAX(f.order_date)) AS tenure
FROM gold.facts_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key),


CTE2 AS (
SELECT 
    customer_key,
    total_spending,
    tenure,
        CASE 
            WHEN tenure>=12 AND total_spending > 5000 THEN 'VIP Customer'
            WHEN tenure >= 12 AND total_spending < 5000 THEN 'Regular Customer'
            ELSE 'New Customer' 
        END AS customer_categorization
FROM CTE)

SELECT customer_categorization,
    COUNT(*) 
FROM CTE2 GROUP BY customer_categorization

