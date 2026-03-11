-- =============================================
-- Product_Performance_Ranking.sql
-- Purpose: Overall performance ranking and quintile grouping for each product
-- Aggregates sales, profit, and margin metrics + category-wide % share and rankings
-- Usage: Shows top/bottom performers and buckets products into revenue quintiles
-- =============================================

WITH product_performance AS (
    SELECT
        Product_Category,
        Product_ID,
        Product_Name,
        
        COUNT(*)                                      AS transaction_count,
        SUM(Units)                                    AS total_units_sold,
        ROUND(SUM(Revenue), 2)                        AS total_revenue,
        ROUND(SUM(Gross_Profit), 2)                   AS total_gross_profit,
        ROUND(AVG(Gross_Margin_Pct), 2)               AS avg_gross_margin_pct,
        
        ROUND(100 * SUM(Revenue) / 
        SUM(SUM(Revenue)) OVER (), 2)                 AS pct_of_total_revenue,
        
        RANK() OVER (ORDER BY SUM(Units) DESC)        AS units_sold_rank,
        RANK() OVER (ORDER BY SUM(Revenue) DESC)      AS revenue_rank,
        RANK() OVER (ORDER BY SUM(Gross_Profit) DESC) AS gross_profit_rank,

        RANK() OVER (ORDER BY AVG(Gross_Margin_Pct) DESC) 
                                                      AS margin_rank,
        
        NTILE(5) OVER (ORDER BY SUM(Revenue) DESC)     
                                                      AS revenue_tile     -- 1 = top 20%, 5 = bottom 20%
    FROM vw_Sales_Enriched
    GROUP BY 
        Product_Category,
        Product_ID,
        Product_Name
)
SELECT
    *,
    CASE 
        WHEN revenue_tile = 1 THEN 'Top 20%'
        WHEN revenue_tile IN (2, 3, 4) THEN 'Middle 60%'
        WHEN revenue_tile = 5 THEN 'Bottom 20%'
    END AS performance_group
FROM product_performance
ORDER BY revenue_rank;