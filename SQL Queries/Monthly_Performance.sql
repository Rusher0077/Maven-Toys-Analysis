-- Monthly_Performance.sql
-- Purpose: Monthly aggregated sales & profitability
-- Granularity: Year + Month

select
    sale_year,
    sale_month,
    month_name,
    sale_quarter,
    product_category,
    store_location,

    count(*)                               as transaction_count,
    sum(units)                              as total_units_sold,
    round(sum(revenue), 2)                  as total_revenue,
    round(sum(cost_of_goods_sold), 2)       as total_cogs,
    round(sum(gross_profit), 2)             as total_gross_profit,
    round(avg(gross_margin_pct), 2)         as avg_gross_margin_pct,

    sum(revenue) /
    nullif(
        lag(sum(revenue)) over (
            order by sale_year, sale_month), 0 ) - 1
                                            as revenue_growth_MoM

-- Growth formula : (Current - Previous) / Previous or
-- (Current / Previous ) - 1
-- Here - 1 is just converting a ratio into a growth rate.

from vw_sales_enriched

group by
    sale_year,
    sale_month,
    month_name,
    sale_quarter,
    product_category,
    store_location

order by
    sale_year,
    sale_month;