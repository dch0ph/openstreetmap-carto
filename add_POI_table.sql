DO $$
DECLARE default_craft_zoom CONSTANT int := 17;
DECLARE default_craft_zoom_label CONSTANT int := 18;
BEGIN
DROP TABLE IF EXISTS POITable;
CREATE TABLE POITable(
	feature_name	text	PRIMARY KEY,
	feature_class	text,
	start_zoom	int,
	start_zoom_label	int,
	symbol_url	text
	);
INSERT INTO POITable VALUES
	('craft_confectionery', 'craft', default_craft_zoom, default_craft_zoom_label, 'symbols/shop/confectionery.svg'),
	('craft_distiller', 'craft', default_craft_zoom, default_craft_zoom_label, 'symbols/shop/alcohol.svg'),
	('craft_brewery', 'craft', default_craft_zoom, default_craft_zoom_label, 'symbols/shop/alcohol.svg'),
	('craft_cider', 'craft', default_craft_zoom, default_craft_zoom_label, 'symbols/shop/alcohol.svg');
GRANT SELECT ON POITable TO gisuser;
END $$;
