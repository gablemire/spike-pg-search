 SELECT ts_rank(search, query) AS score, store_id, product_item_id, product_group_id, product_group_name, name, type, description, CAST(prices->'usd' AS int) AS fractional_unit_price, attributes 
 FROM search_product_items, websearch_to_tsquery('english', 'apple') query
 WHERE store_id = '92735db7-c1cf-4693-9bd1-bdb4e5307ca8'
 	-- Mythic Swords
 	and product_group_id = 'f7060f06-1865-4ad3-8572-0f7bbd658086'
 	AND lang = 'en'
	AND search @@ query
 ORDER BY score DESC, fractional_unit_price asc
 LIMIT 100

WITH 
search_results AS (
	SELECT store_id, product_item_id, product_group_id, product_group_name, name, type, description, prices, attributes 
	FROM search_product_items
	WHERE store_id = '92735db7-c1cf-4693-9bd1-bdb4e5307ca8'
		-- Mythic Swords
		and product_group_id = 'f7060f06-1865-4ad3-8572-0f7bbd658086'
		AND lang = 'en'
		AND search @@ websearch_to_tsquery('english', 'apple')
--		 and attributes->>'color' = 'orange'
--		 and attributes->>'element' = 'fire'
),
-- Weird conversion bool facet
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
-- Int range facets
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
nb_kills_facet as (
	select
		'nb_kills' as facet,
		'int_range' as facet_type,
		'min' as field_value,
		MIN(CAST(attributes->>'nb_kills' AS int)) as value
	from search_results
	union all
		select
		'nb_kills' as facet,
		'int_range' as facet_type,
		'max' as field_value,
		MAX(CAST(attributes->>'nb_kills' AS int)) as value
	from search_results
),
-- Enum facets
charm_facet as (
	select 'charm' as facet, 'enum' as facet_type, attributes->>'charm' as field_value, count(1) as value
	from search_results
	group by field_value
	order by value desc, field_value asc
	limit 10
),
color_facet as (
	select 'color' as facet, 'enum' as facet_type, attributes->>'color' as field_value, count(1) as value
	from search_results
	group by field_value
	order by value desc, field_value asc
	limit 10
),
material_facet as (
	select 'material' as facet, 'enum' as facet_type, attributes->>'material' as field_value, count(1) as value
	from search_results
	group by field_value
	order by value desc, field_value asc
	limit 10
),
special_effect_facet as (
	select 'special_effect' as facet, 'enum' as facet_type, attributes->>'special_effect' as field_value, count(1) as value
	from search_results
	group by field_value
	order by value desc, field_value asc
	limit 10
),
-- Boolean facet
allowed_in_pvp_facet as (
	select 'allowed_in_pvp' as facet, 'bool' as facet_type, attributes->>'allowed_in_pvp' AS field_value, count(1) as value
	from search_results
	group by field_value
),
-- Int range facet (from range field)
damage_facet as (
	select
		'damage' as facet,
		'int_range' as facet_type,
		'min' as field_value,
		MIN(CAST(attributes#>>'{damage,min}' AS int)) as value
	from search_results
	union all
		select
		'damage' as facet,
		'int_range' as facet_type,
		'max' as field_value,
		MAX(CAST(attributes#>>'{damage,max}' AS int)) as value
	from search_results
),
-- Decimal range facet (from range field)
stunt_duration_facet as (
	select
		'stunt_duration' as facet,
		'decimal_range' as facet_type,
		'min' as field_value,
		MIN(CAST(attributes#>>'{stunt_duration,min}' AS decimal)) as value
	from search_results
	union all
		select
		'stunt_duration' as facet,
		'decimal_range' as facet_type,
		'max' as field_value,
		MAX(CAST(attributes#>>'{stunt_duration,max}' AS decimal)) as value
	from search_results
),
total as (
	select 'total' as facet, 'total' as facet_type, 'total' as field_value, COUNT(1) as value
	from search_results
),
facets as (
	select * from for_sale_facet
	union all
	select * from price_facet
	union all
	select * from nb_kills_facet
	union all
	select * from charm_facet
	union all
	select * from color_facet
	union all
	select * from material_facet
	union all
	select * from special_effect_facet
	union all
	select * from allowed_in_pvp_facet
	union all
	select * from damage_facet
	union all
	select * from stunt_duration_facet
	union all
	select * from total
)
select * from facets
order by facet asc, value desc, facet_value asc
