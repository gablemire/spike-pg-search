create temporary sequence seq_swords_collection as integer;

ALTER SEQUENCE seq_swords_collection RESTART WITH 1;

-- Inserting automatically generated product items
with 
colors as (
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
		as colors(color)
),
special_effects as (
	select * from
	(values
		('sparks'),
		('rainbows'),
		('stars'),
		('spots'),
		('smoke'),
		('explosions')
	) as special_effects(special_effect)
),
elements as (
	select * from
	(values
		('fire'),
		('water'),
		('steam'),
		('electricity'),
		('earth'),
		('wind'),
		('life'),
		('arcane')
	) as elements(element)
),
materials as (
	select * from
	(values
		('wood'),
		('rock'),
		('steel'),
		('diamond'),
		('gold'),
		('titanium'),
		('crystal')
	) as materials(material)
),
charms as (
	select * from
	(values
		('none'),
		('claptrap'),
		('star'),
		('hollow_circles'),
		('sphere'),
		('cube'),
		('infinity'),
		('peace_sign'),
		('unity_logo'),
		('epic_logo'),
		('cat'),
		('dog'),
		('television'),
		('radio'),
		('apple'),
		('google')
	) as charms(charm)
),
collection_items as (
	select 
		nextval('seq_swords_collection') as id, 
		'92735db7-c1cf-4693-9bd1-bdb4e5307ca8'::uuid as store_id,
		gen_random_uuid() as product_item_id,
		'collection_item' as type,
		'en' as lang,
		'f7060f06-1865-4ad3-8572-0f7bbd658086' as product_group_id,
		'Mythic Swords' as product_group_name,
		'Mythic Sword #' as name_prefix,
		initcap(element)  || ' Mythic Swords made of ' || initcap(material) as description,
		case
			when floor(random() * 100)::int % 4 = 0 then null
			else jsonb_build_object(
				'usd',
				floor(random() * 100000 + 100),
				'cad',
				floor(random() * 100000 + 100)
			)
		end as prices,
		jsonb_build_object(
			'color', color, 
			'special_effect', special_effect, 
			'element', element, 
			'material', material, 
			'charm', charm
		) as attributes,
		color,
		special_effect,
		element,
		material,
		charm
	from
	colors, special_effects , elements, materials, charms	
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
		color || ' ' || 
		special_effect || ' ' ||
		element || ' ' ||
		material || ' ' ||
		charm || ' ' || 
		product_group_name || ' ' || 
		name_prefix || id || ' ' || 
		description) AS search
from collection_items
