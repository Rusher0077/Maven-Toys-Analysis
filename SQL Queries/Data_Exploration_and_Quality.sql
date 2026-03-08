-- =============================================
-- Data_Exploration_and_Quality.sql
-- Maven Toys - First script
-- Goal: Understand the data + basic quality checks
-- =============================================

-- Section 1: Row counts & basic shape
-- WHY: Knowing exact row counts confirms successful import & gives scale
-- WHY: Helps detect if file was truncated or double-imported

select 'sales' as table_name, count(*) from sales
union all
select 'inventory', count(*) from inventory
union all
select 'products', count(*) from products
union all
select 'stores', count(*) from stores


-- Section 2: Sample rows
-- WHY: See if values look reasonable, spot formatting issues, unexpected NULLs
--------------------------------------------------
select top 10 * from sales
select top 10 * from inventory
select top 10 * from products
select top 10 * from stores

-- Section 3: Date range & key fields
-- WHY: Tells us analysis period, how many unique stores/products really exist
-- WHY: Helps detect data entry errors (e.g. future dates, negative IDs)
--------------------------------------------------

-- sales
select 
	min(date) as earliest_sales_date,
	max(date) as latest_sales_date,
	datediff(day, min(date), max(date)) + 1 as sales_period,
	count(distinct store_id) as total_stores,
	count(distinct product_id) as total_products
from sales

-- inventory

select 
	count(distinct store_id) as unique_stores_in_inventory,
	count(distinct product_id) as unique_products_in_inventory,
	max(stock_on_hand) as max_stocks_observed,
	min(stock_on_hand) as min_stocks_observed,
	avg(stock_on_hand) as avg_stocks_observed
from inventory

-- products
select 
	count(distinct product_id) as total_unique_products,
	count(distinct product_category) as total_category,
	max(product_price) as most_expensive_price,
	min(product_price) as cheapest_price
from products

-- stores

select 
	store_location,
	count(store_location) as store_counts,
	min(store_open_date) as oldest_opening_date,
	max(store_open_date) as newest_opening_date
from stores
group by store_location

-- Section 4: Date quality - Nulls, Duplicates, Referential integrity
-- WHY: These checks catch the most common serious problems before analysis
--------------------------------------------------

-- null check
select 
	sum(case when sale_id is null then 1 else 0  end) as n_sale_id,
	sum(case when date is null then 1 else 0 end) as n_date,
	sum(case when store_id is null then 1 else 0 end) as n_store_id,
	sum(case when product_id is null then 1 else 0 end) as n_product_id,
	sum(case when units is null then 1 else 0 end) as n_unit
from sales


-- Duplicate sales? (Sale_ID should be unique)
select
	sale_id,
	count(sale_id)
from sales
group by sale_id
having count(sale_id) > 1

-- Referential integrity – sales should only contain existing stores & products
-- WHY: If this returns rows → data quality problem (orphan records)

select
	distinct s.store_id
from sales s
left join stores st on st.store_id = s.Store_ID
where st.Store_ID is null

select
	distinct s.product_id
from sales s
left join products p on p.Product_ID = s.Product_ID
where p.Product_ID is null

