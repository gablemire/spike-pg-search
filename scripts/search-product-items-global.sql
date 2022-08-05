-- Search globally
-- Results query
SELECT ts_rank(search, query) AS score, store_id, product_item_id, product_group_id, product_group_name, name, type, description, CAST(prices->'usd' AS int) AS fractional_unit_price, attributes 
FROM search_product_items, websearch_to_tsquery('english', 'houses') query
WHERE store_id = 'c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'
	AND lang = 'en'
	AND search @@ query
ORDER BY score DESC, fractional_unit_price ASC
LIMIT 50

-- Facets query (and total)
WITH 
search_results AS (
	SELECT store_id, product_item_id, product_group_id, product_group_name, name, type, description, prices, attributes 
	FROM search_product_items
	WHERE store_id = 'c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'
		AND lang = 'en'
),
collection_facet as (
	select
		'collection' as facet,
		'enum' as facet_type,
		product_group_id as facet_value,
		COUNT(1) as value
	from search_results
	group by product_group_id 
	order by value desc
	limit 10
),
for_sale_facet as (
	select 
		'for_sale' as facet,
		'bool' as facet_type,
		'false' as facet_value,
		count(1) as value
	from search_results
	where prices->>'usd' is null
	union all
	select 
		'for_sale' as facet,
		'bool' as facet_type,
		'true' as facet_value,
		count(1) as value
	from search_results
	where prices->>'usd' is not null
),
price_facet as (
	select
		'fractional_price' as facet,
		'int_range' as facet_type,
		'min' as field_value,
		MIN(CAST(prices->>'usd' AS int)) as value
	from search_results
	where prices->>'usd' is not null
	union all
		select
		'fractional_price' as facet,
		'int_range' as facet_type,
		'max' as field_value,
		MAX(CAST(prices->>'usd' AS int)) as value
	from search_results
	where prices->>'usd' is not null
),
total as (
	select 'total' as facet, 'total' as facet_type, 'total' as field_value, COUNT(1) as value
	from search_results
),
facets as (
	select * from price_facet
	union all
	select * from for_sale_facet
	union all
	select * from total
	union all
	select * from collection_facet
)
select * from facets
order by facet asc, value desc, field_value asc