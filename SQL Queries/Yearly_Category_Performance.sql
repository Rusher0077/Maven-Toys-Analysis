-- Yearly_Category_Performance.sql
-- Purpose: Yearly sales & profitability breakdown by product category
-- Granularity: Year + Product_Category

select 
    sale_year,
    sale_quarter,
    Product_Category,

    count(*)                              as transaction_count,
    sum(units)                            as total_units_sold,
    round(sum(revenue),2)                 as total_revenue,
    round(sum(cost_of_goods_sold),2)      as total_cogs,
    round(sum(gross_profit),2)            as total_gross_profit,
    round(avg(gross_margin_pct),2)        as avg_gross_margin_pct,

    round(
        100 * sum(revenue) / sum(sum(revenue)) over (partition by sale_year),2
    
    )                                     as pct_of_year_revenue,

    round(
        100 * sum(gross_profit) / sum(sum(gross_profit)) over (partition by sale_year),2
    )                                     as pct_of_gross_profit

from vw_Sales_Enriched

group by 
    sale_year,
    sale_quarter,
    Product_Category

order by 
    sale_year,
    sale_quarter,
    total_revenue desc;