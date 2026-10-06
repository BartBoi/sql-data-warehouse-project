/*
========================================================================================
Quality Checks
========================================================================================
Script Purpose:
  -This script performs various data quality checks for data consistency, accuracy,
  and standardisation across the 'silver' schema. It includes checks for:
    -NULL or duplicate primary keys
    -Unwanted spaces in string fields
    -Data standardisation and consitency
    -Invalid ranges and orders
    -Data consistency between related fields

Usage Notes:
  -Use these checks after loading silver layer
  -Investigate and resolve any discrepancies found during the checks
========================================================================================
*/

--=================Checking Quality of silver.crm_cust_info=============================

--Check for NULLs or duplicates in Primary Key
--Expectation: No result

  SELECT
  cst_id,
  COUNT(*)
  FROM silver.crm_cust_info
  GROUP BY cst_id
  HAVING COUNT(*) >1 OR cst_id IS NULL;


--Check for Unwanted Spaces (can swap out column to check others)
--Expectation: No result

  SELECT cst_first_name
  FROM silver.crm_cust_info
  WHERE cst_first_name != TRIM(cst_first_name);

--Data Consistency and Standardisation (can swap out column to check others)

  SELECT DISTINCT
  cst_gndr
  FROM silver.crm_cust_info

--=================Checking Quality of silver.crm_prd_info==============================

--Check for NULLs or duplicates in Primary Key
--Expectation: No result

  SELECT 
  prd_id,
  COUNT(*)
  FROM silver.crm_prd_info
  GROUP BY prd_id
  HAVING COUNT(*) >1 OR prd_id IS NULL

--Check for Unwanted Spaces (can swap out column to check others)
--Expectation: No result

  SELECT prd_nm
  FROM silver.crm_prd_info
  WHERE prd_nm != TRIM(prd_nm);

--Check for NULLs or Negative Numbers
--Expectation: No Results

  SELECT prd_cost
  FROM silver.crm_prd_info
  WHERE prd_cost < 0 OR prd_cost IS NULL;

--Data Consistency and Standardisation (can swap out column to check others)

  SELECT DISTINCT
  prd_line
  FROM silver.crm_prd_info

--Check for Invalid Date Orders

  SELECT *
  FROM silver.crm_prd_info
  WHERE prd_end_dt <prd_start_dt

--=================Checking Quality of silver.crm_sales_details=========================

--Check for Invalid Date Orders

  SELECT *
  FROM silver.crm_sales_details
  WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--Check for rows with invalid sales calculation

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

--=================Checking Quality of silver.erp_cust_az12==============================

--Check for Out-Of-Range Dates

  SELECT
  bdate
  FROM silver.erp_cust_az12
  WHERE bdate <'1926-01-01'OR bdate > GETDATE();

--Data Consistency and Standardisation (can swap out column to check others)

  SELECT DISTINCT
  gen
  FROM silver.erp_cust_az12;

--=================Checking Quality of silver.erp_loc_a101==============================

--Data Consistency and Standardisation (can swap out column to check others)

  SELECT DISTINCT
  cntry
  FROM silver.erp_loc_a101;

--=================Checking Quality of silver.erp_px_cat_g1v2==============================

--Check for Unwanted Spaces

  SELECT * FROM silver.erp_px_cat_g1v2
  WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != REPLACE(TRIM(maintenance), CHAR(13), '')

--Data Consistency and Standardisation (can swap out column to check others)

  SELECT DISTINCT
  maintenance
  FROM silver.erp_px_cat_g1v2

