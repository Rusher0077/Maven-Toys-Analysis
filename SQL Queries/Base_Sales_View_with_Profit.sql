
-- =============================================
-- Base_Sales_View_with_Profit.sql
-- Purpose: Single source of truth for all sales analysis
--          Joins core tables + calculates profit metrics per transaction
-- =============================================
create or alter view vw_Sales_Enriched as 
select 
	s.Sale_ID,
	s.Product_ID,
	s.Store_ID,
	s.Units,
	s.Date,
	month(s.date) as sale_month,
	year(s.date) as sale_year,
	datepart(quarter,s.date) as sale_quarter,
	datename(month, s.Date) as month_name,

	st.Store_Name,
	st.Store_City,
	st.Store_Location,

	p.Product_Name,
	p.Product_Category,
	(s.Units * p.Product_Price) as revenue,
	(s.Units * p.Product_Cost) as cost_of_goods_sold,
	(s.Units * (p.Product_price - p.Product_Cost)) as gross_profit,
	case
		when s.units * p.product_price = 0 then null
		else round(((s.Units * (p.Product_Price - p.Product_Cost)) / (s.Units * p.Product_Price)) * 100,2)
		end as gross_margin_pct

from sales s
inner join products p on p.Product_ID = s.Product_ID
inner join stores st on st.Store_ID = s.Store_ID