-- =============================================
-- Sales_Velocity_Fast_Slow_Movers.sql
-- Purpose: Classify products by sales velocity (units sold per day of available data)
-- Usage: Identify fast-moving / slow-moving items, support inventory replenishment
--        and assortment decisions, connect to overstock / stockout risks
-- Granularity: Product level
-- =============================================
with velocity as (
select 
	product_id,
	product_name,
	product_category,

	sum(units)						          		as total_units_sold,
	count(distinct (date))							as total_sales_day,
	round(sum(units) * 1.00/ nullif(count(distinct date),0),2)
													as units_per_day_of_sale,
	
	round(sum(units) * 1.00 /637, 2)				as avg_daily_unit_full_period,
	round(100 * sum(revenue) / sum(sum(revenue)) over () , 2)
													as pct_of_total_revenue,
	rank() over (order by sum(units) desc)			as units_rank,
	ntile(5) over (order by sum(units) desc)		as velocity_quintile

	
from vw_Sales_Enriched
group by 
	product_id,
	product_name,
	product_category
)

select *,
case 
	when velocity_quintile =  1 then 'Fast Mover (Top 20%)'
	when velocity_quintile in (2,3,4) then 'Medium Mover' 
	else 'Slow Mover (Bottom 20%)' 
end as velocity_category

from velocity
order by units_rank