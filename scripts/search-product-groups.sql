SELECT ts_rank(search, query) AS score, store_id, product_group_id, name, type, description 
FROM search_product_groups, websearch_to_tsquery('english', 'Barbie or Ken brush') query
WHERE store_id = 'c026a0f3-a4e3-4cc8-b7ee-a60e16923ace'::uuid
	AND lang = 'en'
	AND type = 'collection'
	AND search @@ query
ORDER BY score DESC