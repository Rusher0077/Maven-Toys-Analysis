-- =============================================
-- Inventory_Snapshot.sql
-- Purpose: Current stock levels by store and product + basic health indicators
-- Usage: Identify over/under-stocked items, link to sales velocity later,
--        support inventory optimization recommendations
-- Granularity: Store + Product
-- =============================================

with recent_sales as (
	select 
		store_id,
		product_id,
		sum(units) as total_units_sold
	from vw_Sales_Enriched
	group by 
		store_id,
		product_id
),
stock_category as (
select 
	i.store_id,
	st.store_name,
	st.store_location,

	p.product_id,
	p.product_name,
	p.product_category,

	i.stock_on_hand,
	coalesce(rs.total_units_sold,0) as total_units_sold,

	-- Some products exist in inventory but have never been sold, so they have no row
	-- in recent_sales. The LEFT JOIN returns NULL for rs.total_units_sold in these cases.
	-- COALESCE converts that NULL to 0, and the CASE then handles three zero-scenarios:
	case
		when coalesce(rs.total_units_sold,0) = 0 and i.Stock_On_Hand = 0	then 0.0
		when coalesce(rs.total_units_sold,0) = 0							then 9999.0
		when i.Stock_On_Hand = 0											then 0.0

	-- estimated_days = (stock on hand) / (stocks used per day which is -> total sold / total days)
		else round((i.Stock_On_Hand) /
			(coalesce(rs.total_units_sold,0) * 1.00 / 637),1) end		as	estimated_days_of_stock_left
	-- datediff(day,min(date),max(date)) = 637 days =  total_days

from inventory i
inner join stores st on st.store_id = i.Store_ID
inner join products p on p.product_id = i.product_id
left join recent_sales rs on rs.store_id = i.store_id and rs.product_id = i.product_id
)
select * 
from ( 
	select *,
		case
			when stock_on_hand = 0 then 'Stock Out'
			when estimated_days_of_stock_left = 0 then 'Stock Out'
			when estimated_days_of_stock_left >= 9999.0 then 'Dead Stock'
			when estimated_days_of_stock_left <= 35 then 'Potential Stockout Risk'
			when estimated_days_of_stock_left >= 170 then 'Overstocked'
			else 'Adequate' 
		end as stock_status
		
	from stock_category
) t
order by 
case stock_status
	when 'Stock Out' then 1
	when 'Dead Stock' then 2
	when 'Potential Stockout Risk' then 3
	when 'Adequate' then 4
	when 'Overstocked'  then 5
end 