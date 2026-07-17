CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
 

    DECLARE
        @proc_start_time DATETIME,
        @proc_end_time DATETIME,
        @start_time DATETIME,
        @end_time DATETIME;

    BEGIN TRY
        SET @proc_start_time = GETDATE();

        PRINT '=========================================================';
        PRINT '             LOADING BRONZE LAYER';
        PRINT '=========================================================';
        PRINT '';

        -- Repeat the timing pattern below for each table

        -- CRM CUSTOMER
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_cust_info;

        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\ACER\Desktop\DATA Analyst Prep\SQL Notes\DATA WITH BARAA\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Successfully Loaded : bronze.crm_cust_info';
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' Seconds';
        PRINT '';

        -- CRM PRODUCT
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_prd_info;

        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\ACER\Desktop\DATA Analyst Prep\SQL Notes\DATA WITH BARAA\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Successfully Loaded : bronze.crm_prd_info';
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR(20)) + ' Seconds';
        PRINT '';

        -- CRM SALES
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_sales_details;

        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\ACER\Desktop\DATA Analyst Prep\SQL Notes\DATA WITH BARAA\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Successfully Loaded : bronze.crm_sales_details';
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR(20)) + ' Seconds';
        PRINT '';

        -- ERP CUSTOMER
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_cust_az12;

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\ACER\Desktop\DATA Analyst Prep\SQL Notes\DATA WITH BARAA\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Successfully Loaded : bronze.erp_cust_az12';
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR(20)) + ' Seconds';
        PRINT '';

        -- ERP LOCATION
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_loc_a101;

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\ACER\Desktop\DATA Analyst Prep\SQL Notes\DATA WITH BARAA\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Successfully Loaded : bronze.erp_loc_a101';
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR(20)) + ' Seconds';
        PRINT '';

        -- ERP PRODUCT CATEGORY
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\ACER\Desktop\DATA Analyst Prep\SQL Notes\DATA WITH BARAA\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Successfully Loaded : bronze.erp_px_cat_g1v2';
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR(20)) + ' Seconds';
        PRINT '';

        SET @proc_end_time = GETDATE();

        PRINT '=========================================================';
        PRINT 'Bronze Layer Loaded Successfully';
        PRINT 'Total Load Duration : ' + CAST(DATEDIFF(SECOND,@proc_start_time,@proc_end_time) AS VARCHAR(20)) + ' Seconds';
        PRINT '=========================================================';

    END TRY
    BEGIN CATCH
        PRINT '=========================================================';
        PRINT 'ERROR DURING BRONZE LAYER LOAD';
        PRINT 'Error Number    : ' + CAST(ERROR_NUMBER() AS VARCHAR(20));
        PRINT 'Error Message   : ' + ERROR_MESSAGE();
        PRINT 'Error State     : ' + CAST(ERROR_STATE() AS VARCHAR(20));
        PRINT 'Error Line      : ' + CAST(ERROR_LINE() AS VARCHAR(20));
        PRINT 'Error Procedure : ' + ISNULL(ERROR_PROCEDURE(),'N/A');
        PRINT '=========================================================';
        THROW;
    END CATCH
END;
GO

EXEC bronze.load_bronze;
