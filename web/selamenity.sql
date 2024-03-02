DROP TABLE pois;
CREATE TABLE pois AS
	SELECT way, amenity, name, website
	FROM
		(SELECT ST_PointOnSurface(way) AS way, COALESCE(amenity, tourism) AS amenity, COALESCE(name, tags->'operator') AS name, tags->'website' AS website FROM planet_osm_polygon
		UNION ALL
		SELECT way, COALESCE(amenity, tourism) AS amenity, COALESCE(name, tags->'operator') AS name, tags->'website' AS website FROM planet_osm_point
		) _
	WHERE amenity IN ('pub', 'cafe', 'hotel') AND website IS NOT NULL AND name IS NOT NULL;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "devuser";


