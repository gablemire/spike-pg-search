create temporary sequence seq_cars_collection as integer;

ALTER SEQUENCE seq_cars_collection RESTART WITH 1;

with 
exterior_colors as (
	select * from 
		(values
			('blue'),
			('pink'),
			('red'),
			('purple'),
			('green'),
			('orange'),
			('brown'),
			('black'),
			('white'),
			('yellow')
		)
		as exterior_colors(exterior_color)
),
interior_colors as (
	select * from 
		(values
			('blue'),
			('pink'),
			('red'),
			('purple'),
			('green'),
			('orange'),
			('brown'),
			('black'),
			('white'),
			('yellow')
		)
		as interior_colors(interior_color)
),
interior_materials as (
	select * from
	(values
		('leather'),
		('faux leather'),
		('nylon'),
		('polyester'),
		('vinyl')
	) as interior_materials(interior_material)
),
styles as (
	select * from
	(values
		('sedan'),
		('coupe'),
		('sports'),
		('station wagon'),
		('hatchback'),
		('convertible'),
		('sport utility (SUV)'),
		('minivan'),
		('pickup truck'),
		('micro'),
		('roadster'),
		('van'),
		('limousine'),
		('cabriolet'),
		('supercar'),
		('campervan')
	) as styles(style)
),
collection_items as (
	select 
		nextval('seq_cars_collection') as id, 
		'c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid as store_id,
		gen_random_uuid() as product_item_id,
		'collection_item' as type,
		'en' as lang,
		'a6133b6c-bffc-4877-9f78-223e37899a68' as product_group_id,
		'Cars' as product_group_name,
		'Car #' as name_prefix,
		initcap(exterior_color) || ' ' || initcap(style) || ' Car' as description,
		case
			when floor(random() * 100)::int % 4 = 0 then null
			else jsonb_build_object(
				'usd',
				floor(random() * 100000 + 1000),
				'cad',
				floor(random() * 100000 + 1000)
			)
		end as prices,
		jsonb_build_object(
			'exterior_color', exterior_color, 
			'interior_color', interior_color, 
			'interior_material', interior_material, 
			'style', style
		) as attributes,
		exterior_color,
		interior_color,
		interior_material,
		style
	from
	exterior_colors, interior_colors , interior_materials, styles	
)
insert into search_product_items(store_id, product_item_id, type, lang, product_group_id, product_group_name, name, description, prices, attributes, search)
select 
	store_id, 
	product_item_id, 
	type, 
	lang, 
	product_group_id, 
	product_group_name, 
	name_prefix || id as name, 
	description, 
	prices, 
	attributes,
	to_tsvector('english', 
		id || ' ' || 
		exterior_color || ' ' || 
		interior_color || ' ' ||
		interior_material || ' ' ||
		style || ' ' || 
		product_group_name || ' ' || 
		name_prefix || id || ' ' || 
		description) AS search
from collection_items
