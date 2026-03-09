-- =============================================
-- Data_Exploration_and_Quality.sql
-- Maven Toys - Initial data check
-- Goal: Confirm import worked, understand shape, spot obvious problems early
-- =============================================

-- 1. Row counts – make sure nothing got lost or duplicated during import
SELECT 'sales'     AS table_name, COUNT(*) AS row_count FROM sales
UNION ALL
SELECT 'inventory' AS table_name, COUNT(*) FROM inventory
UNION ALL
SELECT 'products'  AS table_name, COUNT(*) FROM products
UNION ALL
SELECT 'stores'    AS table_name, COUNT(*) FROM stores;

-- 2. Quick peek at actual rows (helps catch weird formatting or unexpected NULLs)
SELECT TOP 10 * FROM sales     ORDER BY Date DESC;
SELECT TOP 10 * FROM inventory ORDER BY Stock_On_Hand DESC;
SELECT TOP 10 * FROM products;
SELECT TOP 10 * FROM stores;

-- 3. Basic range & cardinality checks
-- Sales period & how many unique stores/products we actually have
SELECT  
    MIN(Date)                  AS earliest_date,
    MAX(Date)                  AS latest_date,
    DATEDIFF(DAY, MIN(Date), MAX(Date)) + 1 AS days_covered,
    COUNT(DISTINCT Store_ID)   AS unique_stores,
    COUNT(DISTINCT Product_ID) AS unique_products
FROM sales;

-- Inventory snapshot stats
SELECT  
    COUNT(DISTINCT Store_ID)   AS unique_stores,
    COUNT(DISTINCT Product_ID) AS unique_products,
    MIN(Stock_On_Hand)         AS lowest_stock_seen,
    MAX(Stock_On_Hand)         AS highest_stock_seen,
    AVG(Stock_On_Hand)         AS avg_stock
FROM inventory;

-- Products price range & categories
SELECT  
    COUNT(DISTINCT Product_ID)     AS unique_products,
    COUNT(DISTINCT Product_Category) AS unique_categories,
    MIN(Product_Price)             AS cheapest,
    MAX(Product_Price)             AS most_expensive
FROM products;

-- Stores by location type + opening dates
SELECT  
    Store_Location,
    COUNT(*)                  AS store_count,
    MIN(Store_Open_Date)      AS earliest_opening,
    MAX(Store_Open_Date)      AS latest_opening
FROM stores
GROUP BY Store_Location;

-- 4. Quick data quality flags – things that break analysis if present

-- NULLs in key sales columns
SELECT  
    SUM(CASE WHEN Sale_ID    IS NULL THEN 1 ELSE 0 END) AS null_sale_id,
    SUM(CASE WHEN Date       IS NULL THEN 1 ELSE 0 END) AS null_date,
    SUM(CASE WHEN Store_ID   IS NULL THEN 1 ELSE 0 END) AS null_store,
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS null_product,
    SUM(CASE WHEN Units      IS NULL THEN 1 ELSE 0 END) AS null_units
FROM sales;

-- Duplicate Sale_IDs? (should be unique)
SELECT Sale_ID, COUNT(*) AS occurrences
FROM sales
GROUP BY Sale_ID
HAVING COUNT(*) > 1;

-- Orphan sales – references to non-existing stores/products
SELECT DISTINCT s.Store_ID
FROM sales s
LEFT JOIN stores st ON st.Store_ID = s.Store_ID
WHERE st.Store_ID IS NULL;

SELECT DISTINCT s.Product_ID
FROM sales s
LEFT JOIN products p ON p.Product_ID = s.Product_ID
WHERE p.Product_ID IS NULL;

-- Optional quick check: negative / zero units (shouldn't happen)
SELECT *
FROM sales
WHERE Units <= 0;