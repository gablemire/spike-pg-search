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
		('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, 'c7af942c-7771-46ef-b4d3-89073670e079', 'collection_item', 'en', '26fd65ca-117a-4910-8f10-b63c347e4973', 'Ken Brushes', 'Yellow brush', 'This yellow brush gives the most gorgeous hair around.', '{ "usd": 1599, "cad": 1999 }'::jsonb, '{ "color": "yellow", "spark_color": "silver", "style": "rich" }'::jsonb)
	) AS coll(store_id, product_item_id, type, lang, product_group_id, product_group_name, name, description, prices, attributes)
)
INSERT INTO search_product_items(store_id, product_item_id, type, lang, product_group_id, product_group_name, name, description, prices, attributes, search)
SELECT store_id, product_item_id, type, lang, product_group_id, product_group_name, name, description, prices, attributes, to_tsvector('english', product_group_name || ' ' || name || ' ' || description) AS search
FROM collection_items
