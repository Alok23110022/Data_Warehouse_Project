CREATE VIEW gold.dim_customers AS 
SELECT 
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.CNTRY AS country,
	CASE 
			WHEN ci.cst_gndr IS NOT NULL THEN ci.cst_gndr
			ELSE COALESCE(ca.GEN, 'n/a')
	END AS gender,
	ci.cst_marital_status AS marital_status,
	ca.BDATE AS birth_date,
	ci.cst_create_date AS create_date		
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.CID
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.CID