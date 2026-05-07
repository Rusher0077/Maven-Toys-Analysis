-- =============================================
-- 02_10_Fact_Sales.sql
-- Purpose: Clean fact table at transaction level for Power BI (Star Schema)
-- =============================================

CREATE OR ALTER VIEW Fact_Sales AS
SELECT 
    s.Sale_ID,
    s.Date,
    s.Store_ID,
    s.Product_ID,
    s.Units,
    
    -- Time intelligence ready
    YEAR(s.Date)           AS Sale_Year,
    MONTH(s.Date)          AS Sale_Month,
    DATEPART(QUARTER, s.Date) AS Sale_Quarter,
    
    -- Measures
    s.Units * p.Product_Price          AS Revenue,
    s.Units * p.Product_Cost           AS Cost_Of_Goods_Sold,
    s.Units * (p.Product_Price - p.Product_Cost) AS Gross_Profit,
    
    ROUND(
        CASE WHEN s.Units * p.Product_Price = 0 THEN NULL 
             ELSE (s.Units * (p.Product_Price - p.Product_Cost)) * 100.0 
                  / (s.Units * p.Product_Price) 
        END, 2) AS Gross_Margin_Pct

FROM sales s
INNER JOIN products p ON s.Product_ID = p.Product_ID;