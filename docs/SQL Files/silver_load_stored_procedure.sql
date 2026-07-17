CREATE OR ALTER PROCEDURE Silver.load_silver
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @proc_start_time DATETIME,
        @proc_end_time DATETIME,
        @start_time DATETIME,
        @end_time DATETIME;

    BEGIN TRY

		SET @proc_start_time = GETDATE();

		PRINT '=========================================================';
		PRINT 'LOADING SILVER LAYER';
		PRINT '=========================================================';

-----------------------------------------------------------------------------------------------------------------------------
	PRINT '=========================================================';
	PRINT 'LOADING CRM TABLES';
	PRINT '=========================================================';
		
		SET @start_time = GETDATE();
	
			TRUNCATE TABLE silver.crm_cust_info;
			INSERT INTO silver.crm_cust_info (
				cst_id,
				cst_key,
				cst_firstname,
				cst_lastname,
				cst_marital_status,
				cst_gndr,
				cst_create_date)

			SELECT
				cst_id,
				cst_key,
				TRIM(cst_firstname) AS cst_firstname,
				TRIM(cst_lastname) AS cst_lastname,
					CASE 
						WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
						WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
						ELSE 'n/a'
					END AS cst_marital_status,

					CASE 
						WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
						WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
						ELSE 'Unknown'
					END AS cst_gender,
				cst_create_date
			FROM(SELECT *,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS Flag_duplicates
			FROM Bronze.crm_cust_info) AS t WHERE Flag_duplicates = 1 AND cst_id IS NOT NULL;

		PRINT 'Rows Loaded : ' + CAST(@@ROWCOUNT AS VARCHAR(20));
		SET @end_time = GETDATE();
		PRINT 'Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR(20)) + ' Seconds';

--------------------------------------------------------------------------------------------------------------------------------
		SET @start_time = GETDATE();
		
			TRUNCATE TABLE silver.crm_prd_info;
			INSERT INTO silver.crm_prd_info (
				prd_id,
				cat_id,
				prd_key,
				prd_nm,
				prd_cost,
				prd_line,
				prd_start_dt,
				prd_end_dt)

			SELECT 
				prd_id,
				REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS category_id,
				SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
				prd_nm,
				ISNULL(prd_cost,0) AS prd_cost,
					CASE 
						WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
						WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
						WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Sports'
						WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
						ELSE 'n/a'
					END AS prd_line,
				CAST(prd_start_dt AS DATE) AS prd_start_dt,
				CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
			FROM bronze.crm_prd_info;
		
		PRINT 'Rows Loaded : ' + CAST(@@ROWCOUNT AS VARCHAR(20));
		SET @end_time = GETDATE();
		PRINT 'Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR(20)) + ' Seconds';

---------------------------------------------------------------------------------------------------------------------------------
		SET @start_time = GETDATE();
			
			TRUNCATE TABLE silver.crm_sales_details;
			INSERT INTO silver.crm_sales_details(
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				sls_order_dt,
				sls_ship_dt,
				sls_due_dt,
				sls_sales,
				sls_quantity,
				sls_price)

			SELECT
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				CASE 
					WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
				END AS sls_order_dt,

				CASE 
					WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
				END AS sls_ship_dt,

				CASE 
					WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
				END AS sls_due_dt,

				CASE 
					WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales <> ABS(sls_quantity)*ABS(sls_price) 
						THEN ABS(sls_quantity)*ABS(sls_price)
					ELSE sls_sales
				END AS sls_sales,

				ABS(sls_quantity) AS sls_quantity,

				CASE 
					WHEN sls_price <=0 OR sls_price IS NULL 
						THEN sls_sales/NULLIF(sls_quantity,0)
					ELSE sls_price
				END AS sls_price	
			FROM bronze.crm_sales_details;
		
		PRINT 'Rows Loaded : ' + CAST(@@ROWCOUNT AS VARCHAR(20));
		SET @end_time = GETDATE();
		PRINT 'Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR(20)) + ' Seconds';

---------------------------------------------------------------------------------------------------------------------------------------
	PRINT '=========================================================';
	PRINT 'LOADING ERP TABLES';
	PRINT '=========================================================';
		
		SET @start_time = GETDATE();
			
			TRUNCATE TABLE silver.erp_cust_az12
			INSERT INTO silver.erp_cust_az12 (
				CID,
				BDATE,
				GEN)
			SELECT
				CASE 
					WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID)) 
					ELSE CID
				END AS CID,

				CASE WHEN BDATE > GETDATE() OR BDATE < '1900-01-01' THEN NULL
				ELSE BDATE
				END AS BDATE,

				CASE 
					WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
					WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
					ELSE 'n/a'
				END AS GEN
			FROM bronze.erp_cust_az12
	
		PRINT 'Rows Loaded : ' + CAST(@@ROWCOUNT AS VARCHAR(20));
		SET @end_time = GETDATE();
		PRINT 'Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR(20)) + ' Seconds';
-------------------------------------------------------------------------------------------------------------------------------------
		SET @start_time = GETDATE();
			
			TRUNCATE TABLE silver.erp_loc_a101
			INSERT INTO silver.erp_loc_a101 (
			CID, CNTRY)
			SELECT REPLACE(CID,'-','') AS CID,
				CASE 
					WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
					WHEN TRIM(CNTRY) IN ('USA', 'US') THEN 'United States'
					WHEN TRIM(CNTRY) = '' OR TRIM(CNTRY) IS NULL THEN 'n/a'
					ELSE TRIM(CNTRY)
				END AS CNTRY 
			FROM BRONZE.erp_loc_a101

		PRINT 'Rows Loaded : ' + CAST(@@ROWCOUNT AS VARCHAR(20));
		SET @end_time = GETDATE();
		PRINT 'Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR(20)) + ' Seconds';
-------------------------------------------------------------------------------------------------------------------------------------
		SET @start_time = GETDATE();
			
			TRUNCATE TABLE silver.erp_px_cat_g1v2
			INSERT INTO silver.erp_px_cat_g1v2
			( ID, CAT, SUBCAT, MAINTENANCE)
			(SELECT * FROM BRONZE.erp_px_cat_g1v2);

		PRINT 'Rows Loaded : ' + CAST(@@ROWCOUNT AS VARCHAR(20));
		SET @end_time = GETDATE();
		PRINT 'Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR(20)) + ' Seconds';
---------------------------------------------------------------------------------------------------------------------------------------
		SET @proc_end_time = GETDATE();

        PRINT '=========================================================';
        PRINT 'Silver Layer Loaded Successfully';
        PRINT 'Total Duration : '
            + CAST(DATEDIFF(SECOND,@proc_start_time,@proc_end_time) AS VARCHAR(20))
            + ' Seconds';
        PRINT '=========================================================';

		END TRY

    BEGIN CATCH
        PRINT '=========================================================';
        PRINT 'ERROR DURING SILVER LOAD';
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS VARCHAR(20));
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS VARCHAR(20));
        PRINT '=========================================================';
        THROW;
    END CATCH
END;
GO

EXEC Silver.load_silver;