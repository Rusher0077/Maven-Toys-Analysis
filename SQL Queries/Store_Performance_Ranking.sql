-- =============================================
-- Store_Performance_Summary.sql
-- Purpose: Overall performance ranking and share for each store
-- Aggregates sales, profit, and margin metrics + company-wide % share and rankings
-- =============================================

select 
	Store_ID,
	Store_Name,
	Store_Location,
	Store_City,

	count(*)		as transaction_count,
	sum(units)		as total_units_sold,
	round(sum(revenue),2) as total_revenue,
	round(sum(cost_of_goods_sold),2) as total_cogs,
	round(sum(gross_profit),2) as total_gross_profit,
	round(avg(gross_margin_pct),2) as avg_gross_margin_pct,

	round( 100 * sum(revenue) / sum(sum(revenue)) over (), 2) as pct_of_total_revenue,
	
	rank() over(order by sum(revenue) desc) as revenue_rank,
	rank() over(order by sum(gross_profit) desc) as gross_profit_rank,
	rank() over(order by avg(gross_margin_pct) desc) as margin_rank

from vw_Sales_Enriched

group by 
	Store_ID,
	Store_Name,
	Store_Location,
	Store_City
	
order by revenue_rank