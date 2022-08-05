create temporary sequence seq_houses_collection as integer;

ALTER SEQUENCE seq_houses_collection RESTART WITH 1;

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
sizes as (
	select * from
	(values
		('minuscule'),
		('small'),
		('medium'),
		('large'),
		('huge'),
		('castle')
	) as sizes(size)
),
nb_rooms as (
	select * from
	(values
		(6),
		(10),
		(15),
		(25),
		(36),
		(50),
		(68),
		(83)
	) as nb_rooms(nb_rooms)
),
materials as (
	select * from
	(values
		('wood'),
		('glass'),
		('brick'),
		('concrete'),
		('silver'),
		('gold')
	) as materials(material)
),
styles as (
	select * from
	(values
		('colonial'),
		('modern'),
		('cape cod'),
		('french country'),
		('victorian'),
		('tudor'),
		('cottage'),
		('mediterranean'),
		('ranch'),
		('contemporary'),
		('art deco'),
		('prairie style'),
		('farmhouse'),
		('coastal'),
		('scandinavian'),
		('bohemian'),
		('traditional'),
		('midcentury modern'),
		('industrial'),
		('south western')
	) as styles(style)
),
collection_items as (
	select 
		nextval('seq_houses_collection') as id, 
		'c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid as store_id,
		gen_random_uuid() as product_item_id,
		'collection_item' as type,
		'en' as lang,
		'a15dadd7-b7f5-4bdd-af92-2c53fe7270b6' as product_group_id,
		'Houses' as product_group_name,
		'House #' as name_prefix,
		initcap(size) || ' ' || initcap(style) || ' House' as description,
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
			'size', size, 
			'nb_rooms', nb_rooms, 
			'material', material, 
			'style', style
		) as attributes,
		exterior_color,
		size,
		nb_rooms,
		material,
		style
	from
	exterior_colors, sizes , nb_rooms, materials, styles	
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
		size || ' ' ||
		nb_rooms || ' ' ||
		material || ' ' ||
		style || ' ' || 
		product_group_name || ' ' || 
		name_prefix || id || ' ' || 
		description) AS search
from collection_items
