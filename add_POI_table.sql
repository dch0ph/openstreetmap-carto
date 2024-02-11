DO $$
BEGIN
DROP TABLE IF EXISTS POITable;
CREATE TABLE POITable(
	feature_class	text NOT NULL,
	feature_value	text NOT NULL,
	symbol_file	text NOT NULL
	);
INSERT INTO POITable VALUES
	('craft', 'confectionery', 'symbols/shop/confectionery.svg'),
	('craft', 'distiller', 'symbols/shop/alcohol.svg'),
	('craft', 'brewery', 'symbols/shop/alcohol.svg'),
	('craft', 'cider', 'symbols/shop/alcohol.svg'),
	('craft', 'jeweller', 'symbols/shop/jewelry.svg'),
	('craft', 'shoemaker', 'symbols/shop/shoes.svg'),
	('craft', 'shoe_repair', 'symbols/shop/shoes.svg'),
	('craft', 'tailor', 'symbols/shop/clothes.svg'),
	('craft', 'dressmaker', 'symbols/shop/clothes.svg'),
	('craft', 'stonemason', 'symbols/historic/memorial.svg'),
	('craft', 'electronics_repair', 'symbols/shop/electronics.svg'),
	('craft', 'computer_repair', 'symbols/shop/computer.svg'),
	('craft', 'photo_studio', 'symbols/shop/photo.svg'),
	('craft', 'decorator', 'symbols/shop/paint.svg'),
	('craft', 'printer', 'symbols/shop/newsagent.svg'),
	('craft', 'weaver', 'symbols/shop/fabric.svg'),
	('craft', 'sculptor', 'symbols/tourism/artwork.svg'),
	('craft', 'upholsterer', 'symbols/shop/furniture.svg'),
	('office', 'taxi', 'symbols/amenity/taxi.svg'),
	('office', 'it', 'symbols/shop/computer.svg');
DROP TABLE IF EXISTS POIDefaults;
CREATE TABLE POIDefaults(
	feature_class	text PRIMARY KEY,
	normal_start_zoom int NOT NULL,
	large_start_zoom int NOT NULL,
	large_way_pixels int DEFAULT 2000,
	CHECK (normal_start_zoom >= large_start_zoom)
	);
INSERT INTO POIDefaults VALUES
	('craft', 17, 15, DEFAULT),
	('office', 17, 15, DEFAULT);
CREATE UNIQUE INDEX POITable_index ON POITable (feature_class, feature_value);
GRANT SELECT ON POITable TO gisuser;
GRANT SELECT ON POIDefaults TO gisuser;
END $$;
