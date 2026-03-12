-- =============================================
-- Weekday_Weekend_Performance.sql
-- Purpose: Sales performance breakdown by day of week + weekday/weekend grouping
-- Usage: Identify weekend vs weekday patterns, potential staffing / promotion implications,
--        understand customer behavior by day type
-- Granularity: Year + Day of Week (or aggregated to Weekday/Weekend)
-- =============================================
select
    sale_year,
    DATENAME(WEEKDAY, date) AS day_name,
    DATEPART(WEEKDAY, date) AS day_number,
    case
        when DATEPART(WEEKDAY, date) in (1,7) then 'Weekend'
    else 'Weekday' end as day_type,

    round(sum(revenue), 2)                  as total_revenue,
    round(sum(gross_profit), 2)             as total_gross_profit,
    round(avg(gross_margin_pct), 2)         as avg_gross_margin_pct,

    round(100 * sum(revenue) / sum(sum(revenue)) over (partition by sale_year),2)
                                            as pct_of_total_revenue,

    round(sum(revenue)/count(*),2)          as avg_transaction_value

from vw_Sales_Enriched
group by 
    
    sale_year,
    DATENAME(WEEKDAY, date),
    DATEPART(WEEKDAY, date) ,
    case
        when DATEPART(WEEKDAY, date) in (1,7) then 'Weekend'
    else 'Weekday' end

order by sale_year, day_number