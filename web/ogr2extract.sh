#!/bin/sh
sudo -u postgres psql -d gis -U postgres -f selamenity.sql
ogr2ogr -t_srs "EPSG:4326" -f GeoJSON amenitydata.geojson PG:"user='devuser' dbname='gis' port='5432' password='gispassword'" "pois" 
sudo -u postgres psql -d gis -U postgres -f selimage.sql
ogr2ogr -t_srs "EPSG:4326" -f GeoJSON imagedata.geojson PG:"user='devuser' dbname='gis' port='5432' password='gispassword'" "imagelinks" 
echo "var amenityData =" > markerdata.js
cat amenitydata.geojson >> markerdata.js
echo ";" >> markerdata.js
echo "var imageData =" >> markerdata.js
cat imagedata.geojson >> markerdata.js
echo ";" >> markerdata.js
gzip -f -k markerdata.js

