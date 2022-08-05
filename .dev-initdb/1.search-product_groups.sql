-- Product Group Search table
CREATE TABLE search_product_groups(
	store_id uuid NOT NULL,
	product_group_id varchar NOT NULL,
	type varchar NOT NULL,
	lang varchar(5) NOT NULL,
	name text NOT NULL,
	description text NOT NULL,
	search tsvector,
	
	PRIMARY KEY(store_id, product_group_id, type, lang)
);

CREATE INDEX ix_store_id ON search_product_groups using hash(store_id);
CREATE INDEX ix_type on search_product_groups using hash(type);
CREATE INDEX ix_lang ON search_product_groups using hash(lang);
CREATE INDEX ix_search ON search_product_groups using GIN(search);

WITH collections AS (
	SELECT *
	FROM (
		VALUES
			('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, 'bcb036ae-b3e3-45af-9f03-6c319110a42f', 'collection', 'en', 'Barbie Brushes', 'Those Barbie Brushes are amazing. Check them out!'),
			('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, '26fd65ca-117a-4910-8f10-b63c347e4973', 'collection', 'en', 'Ken Brushes', 'Ken also has to use brushes to maintain his amazing hair style.'),
			('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, 'a15dadd7-b7f5-4bdd-af92-2c53fe7270b6', 'collection', 'en', 'Houses', 'Ken and Barbie need to stay somewhere and they need a house to invite all of their friends for cool parties.'),
			('c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid, 'a6133b6c-bffc-4877-9f78-223e37899a68', 'collection', 'en', 'Cars', 'Ken and Barbie need fashionable cars to get around and party all day and night.'),
			('92735db7-c1cf-4693-9bd1-bdb4e5307ca8'::uuid, 'f7060f06-1865-4ad3-8572-0f7bbd658086', 'collection', 'en', 'Mythic Swords', 'Crush your opponents with style with this collection of mythic swords.')
		) AS coll(store_id, product_group_id, type, lang, name, description)
)
INSERT INTO search_product_groups(store_id, product_group_id, type, lang, name, description, search)
SELECT store_id, product_group_id, type, lang, name, description, to_tsvector('english', name || ' ' || description) AS search
FROM collections
