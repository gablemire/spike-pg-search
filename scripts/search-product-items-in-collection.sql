-- Search in a given collection
-- Results query
SELECT ts_rank(search, query) AS score, store_id, product_item_id, product_group_id, product_group_name, name, type, description, CAST(prices->'usd' AS int) AS fractional_unit_price, attributes 
FROM search_product_items, websearch_to_tsquery('english', 'house') query
WHERE store_id = 'c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'
	and product_group_id = 'a15dadd7-b7f5-4bdd-af92-2c53fe7270b6'
	AND lang = 'en'
	AND search @@ query
ORDER BY score DESC, fractional_unit_price ASC
LIMIT 50
-- OFFSET 50

-- Facets query (and total)
WITH 
search_results AS (
	SELECT store_id, product_item_id, product_group_id, product_group_name, name, type, description, prices, attributes 
	FROM search_product_items
	WHERE store_id = 'c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid
		and product_group_id = 'a15dadd7-b7f5-4bdd-af92-2c53fe7270b6'
		AND lang = 'en'
		AND search @@ websearch_to_tsquery('english', 'house')
		-- and attributes->>'has_pool' = 'true'
		-- and attributes->>'size' = 'big'
),
price_facet as (
	select
		'fractional_price' as facet,
		'int_range' as facet_type,
		'min' as field_value,
		MIN(CAST(prices->>'usd' AS int)) as value
	from search_results
	union all
		select
		'fractional_price' as facet,
		'int_range' as facet_type,
		'max' as field_value,
		MAX(CAST(prices->>'usd' AS int)) as value
	from search_results
),
size_facet as (
	select 'size' as facet, 'enum' as facet_type, attributes->>'size' as field_value, count(1) as value
	from search_results
	group by field_value
	order by value desc, field_value asc
	limit 10
),
style_facet as (
	select 'style' as facet, 'enum' as facet_type, attributes->>'style' as field_value, count(1) as value
	from search_results
	group by field_value
	order by value desc, field_value asc
	limit 10
),
has_pool_facet as (
	select 'has_pool' as facet, 'bool' as facet_type, attributes->>'has_pool' AS field_value, count(1) as value
	from search_results
	group by field_value
),
nb_rooms_facet as (
	select
		'nb_rooms' as facet,
		'int_range' as facet_type,
		'min' as field_value,
		MIN(CAST(attributes->>'nb_rooms' AS int)) as value
	from search_results
	union all
		select
		'nb_rooms' as facet,
		'int_range' as facet_type,
		'max' as field_value,
		MAX(CAST(attributes->>'nb_rooms' AS int)) as value
	from search_results
),
exterior_color_facet as (
	select 'exterior_color' as facet, 'enum' as facet_type, attributes->>'exterior_color' as field_value, count(1) as value
	from search_results
	group by field_value
	order by value desc, field_value asc
	limit 10
),
total as (
	select 'total' as facet, 'total' as facet_type, 'total' as field_value, COUNT(1) as value
	from search_results
),
facets as (
	select * from size_facet
	union all
	select * from price_facet
	union all
	select * from style_facet
	union all
	select * from has_pool_facet
	union all
	select * from nb_rooms_facet
	union all
	select * from exterior_color_facet
	union all
	select * from total
)
select * from facets
order by facet asc, value desc, field_value asc