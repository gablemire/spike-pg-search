CREATE TABLE search_product_items(
	store_id uuid NOT NULL,
	type varchar NOT NULL,
	product_item_id varchar NOT NULL,
	lang varchar(5) NOT NULL,
	
	product_group_id varchar,
	product_group_name varchar,

	name text NOT NULL,
	description text NOT NULL,
	search tsvector,
	
	prices jsonb,
	attributes jsonb NOT NULL,
	
	PRIMARY KEY(store_id, type, product_item_id, lang)
);

CREATE INDEX ix_search_product_items_store_id ON search_product_items using hash(store_id);
CREATE INDEX ix_search_product_items_type on search_product_items using hash(type);
CREATE INDEX ix_search_product_items_lang ON search_product_items using hash(lang);
CREATE INDEX ix_search_product_items_product_group_id ON search_product_items using hash(product_group_id);
CREATE INDEX ix_search_product_items_search ON search_product_items using GIN(search);

WITH collection_items AS (
	SELECT *
	FROM (
		VALUES
		-- Barbie brushes
		('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, '553514f2-40c4-490c-89c5-e8890f04d3a8', 'collection_item', 'en', 'bcb036ae-b3e3-45af-9f03-6c319110a42f', 'Barbie Brushes', 'Blue brush', 'This blue brush gives Barbie the best hair around.', '{ "usd": 999, "cad": 1299 }'::jsonb, '{ "color": "blue", "spark_color": "purple", "style": "fancy" }'::jsonb),
		('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, '818a80f4-bd7b-44d5-a63f-561245edc57a', 'collection_item', 'en', 'bcb036ae-b3e3-45af-9f03-6c319110a42f', 'Barbie Brushes', 'Pink brush', 'This pink brush gives Barbie the best hair around.', '{ "usd": 999, "cad": 1299 }'::jsonb, '{ "color": "pink", "spark_color": "yellow", "style": "fancy" }'::jsonb),
		('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, '6108c6e7-2d02-45b0-b2dc-94e807441818', 'collection_item', 'en', 'bcb036ae-b3e3-45af-9f03-6c319110a42f', 'Barbie Brushes', 'Yellow brush', 'This yellow brush gives Barbie the best hair around.', '{ "usd": 1599, "cad": 1999 }'::jsonb, '{ "color": "yellow", "spark_color": "silver", "style": "rich" }'::jsonb),
		
		-- Ken brushes
		('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, 'c5683e6a-5469-45f7-9311-c5a02c871d15', 'collection_item', 'en', '26fd65ca-117a-4910-8f10-b63c347e4973', 'Ken Brushes', 'Blue brush', 'This blue brush gives Ken the most gorgeous hair around.', '{ "usd": 999, "cad": 1299 }'::jsonb, '{ "color": "blue", "spark_color": "silver", "style": "gorgeous" }'::jsonb),
		('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, 'ae8fff59-4d0b-46e4-a4bb-136f1c5508cb', 'collection_item', 'en', '26fd65ca-117a-4910-8f10-b63c347e4973', 'Ken Brushes', 'Pink brush', 'This pink brush gives Ken the most gorgeous hair around.', '{ "usd": 999, "cad": 1299 }'::jsonb, '{ "color": "pink", "spark_color": "yellow", "style": "fancy" }'::jsonb),
		('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, 'c7af942c-7771-46ef-b4d3-89073670e079', 'collection_item', 'en', '26fd65ca-117a-4910-8f10-b63c347e4973', 'Ken Brushes', 'Yellow brush', 'This yellow brush gives the most gorgeous hair around.', '{ "usd": 1599, "cad": 1999 }'::jsonb, '{ "color": "yellow", "spark_color": "silver", "style": "rich" }'::jsonb),
		
		-- Colonial houses
		('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, '06b22356-7a9a-4493-a893-90a0315a9aa1', 'collection_item', 'en', 'a15dadd7-b7f5-4bdd-af92-2c53fe7270b6', 'Houses', 'Small colonial mansion', 'This small colonial mansion will do the job for now, but we will need to get a bigger one soon enough. It does not even have a pool...', '{ "usd": 9999, "cad": 1299 }'::jsonb, '{ "exterior_color": "pink", "size": "small", "nb_rooms": 16, "style": "colonial", "has_pool": false }'::jsonb),
		('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, '032f6b9c-dc57-468b-81ad-ab819a28de0f', 'collection_item', 'en', 'a15dadd7-b7f5-4bdd-af92-2c53fe7270b6', 'Houses', 'Medium colonial mansion', 'This medium colonial mansion is a bit bigger, but the neighbors have MUCH bigger. Where will the guests sleep?', '{ "usd": 19999, "cad": 24999 }'::jsonb, '{ "exterior_color": "blue", "size": "medium", "nb_rooms": 25, "style": "colonial", "has_pool": true }'::jsonb),
		('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, '0f212739-a478-4962-8eed-305e6b36a2c5', 'collection_item', 'en', 'a15dadd7-b7f5-4bdd-af92-2c53fe7270b6', 'Houses', 'Big colonial mansion', 'This big colonial mansion is perfect for when we stay in the country.', '{ "usd": 29999, "cad": 34999 }'::jsonb, '{ "exterior_color": "yellow", "size": "big", "nb_rooms": 50, "style": "colonial", "has_pool": true }'::jsonb),
	
		-- Modern penthouses
		('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, 'ea4af616-c22b-4cc8-8206-5212704ee460', 'collection_item', 'en', 'a15dadd7-b7f5-4bdd-af92-2c53fe7270b6', 'Houses', 'Small penthouse', 'This small penthouse is perfect for a city visit for the Barbie and Ken couple, but not many more.', '{ "usd":14999, "cad": 1799 }'::jsonb, '{ "exterior_color": "grey", "size": "small", "nb_rooms": 6, "style": "penthouse", "has_pool": false }'::jsonb),
		('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, '8ceb5537-c85b-4a4c-a064-e2d080d47ed8', 'collection_item', 'en', 'a15dadd7-b7f5-4bdd-af92-2c53fe7270b6', 'Houses', 'Medium penthouse', 'This medium penthouse is good for inviting some friends over to New York for a great week-end', '{ "usd": 24999, "cad": 29999 }'::jsonb, '{ "exterior_color": "black", "size": "medium", "nb_rooms": 15, "style": "penthouse", "has_pool": true }'::jsonb),
		('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, 'bc104d87-6eae-4df1-b776-4717a8cef7e5', 'collection_item', 'en', 'a15dadd7-b7f5-4bdd-af92-2c53fe7270b6', 'Houses', 'Big penthouse', 'This big penthouse is the main attraction of Los Angeles. It''s great to be rich...', '{ "usd": 34999, "cad": 39999 }'::jsonb, '{ "exterior_color": "white", "size": "big", "nb_rooms": 25, "style": "penthouse", "has_pool": true }'::jsonb),

		-- Mythic swords
		-- Sword of fire
		('92735db7-c1cf-4693-9bd1-bdb4e5307ca8'::uuid, '1378db78-38d7-47f8-8534-fd76a6ec4134', 'collection_item', 'en', 'f7060f06-1865-4ad3-8572-0f7bbd658086', 'Mythic Swords', 'Fire sword', 'A sword made of fire', '{ "usd": 999, "cad": 1299 }'::jsonb, '{ "color": "red" }'::jsonb),
		('92735db7-c1cf-4693-9bd1-bdb4e5307ca8'::uuid, '92f0db72-7658-4eed-89fe-8fb6ba4b9053', 'collection_item', 'en', 'f7060f06-1865-4ad3-8572-0f7bbd658086', 'Mythic Swords', 'Fire sword', 'A sword made of fire', '{ "usd": 999, "cad": 1299 }'::jsonb, '{ "color": "blue" }'::jsonb),
		('92735db7-c1cf-4693-9bd1-bdb4e5307ca8'::uuid, '8efc8c26-bc4e-42cb-b83e-d74749ff2013', 'collection_item', 'en', 'f7060f06-1865-4ad3-8572-0f7bbd658086', 'Mythic Swords', 'Fire sword', 'A sword made of fire', '{ "usd": 999, "cad": 1299 }'::jsonb, '{ "color": "yellow" }'::jsonb),
	
		-- Sword of water
		('92735db7-c1cf-4693-9bd1-bdb4e5307ca8'::uuid, '6916a602-f28a-4c7e-bd9d-8cc868247120', 'collection_item', 'en', 'f7060f06-1865-4ad3-8572-0f7bbd658086', 'Mythic Swords', 'Water sword', 'A sword made of water', '{ "usd": 1999, "cad": 2299 }'::jsonb, '{ "color": "red" }'::jsonb),
		('92735db7-c1cf-4693-9bd1-bdb4e5307ca8'::uuid, 'cb238dbe-9614-499b-822e-063c28c3a0b1', 'collection_item', 'en', 'f7060f06-1865-4ad3-8572-0f7bbd658086', 'Mythic Swords', 'Water sword', 'A sword made of water', '{ "usd": 1999, "cad": 2299 }'::jsonb, '{ "color": "blue" }'::jsonb),
		('92735db7-c1cf-4693-9bd1-bdb4e5307ca8'::uuid, '674c568c-10b9-4328-8e96-212fadc69845', 'collection_item', 'en', 'f7060f06-1865-4ad3-8572-0f7bbd658086', 'Mythic Swords', 'Water sword', 'A sword made of water', '{ "usd": 1999, "cad": 2299 }'::jsonb, '{ "color": "yellow" }'::jsonb)

	) AS coll(store_id, product_item_id, type, lang, product_group_id, product_group_name, name, description, prices, attributes)
)
INSERT INTO search_product_items(store_id, product_item_id, type, lang, product_group_id, product_group_name, name, description, prices, attributes, search)
SELECT store_id, product_item_id, type, lang, product_group_id, product_group_name, name, description, prices, attributes, to_tsvector('english', product_group_name || ' ' || name || ' ' || description) AS search
FROM collection_items