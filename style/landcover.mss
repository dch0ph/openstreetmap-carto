// --- Parks, woods, other green things ---

@grass: #cdebb0;        // Lch(90,32,128) also village_green, garden, allotments
@meadow: lighten(@grass, 5%);
// grassland, meadow are a shade lighter
@meadow-line: @grass;
@scrub: #c8d7ab;        // Lch(84,24,122)
@wood: #add19e;       // Lch(80,30,135)
@forest: darken(@wood, 15%); // calculated to be #8dbf78
@forest-text: #46673b;  // Lch(40,30,135)
@park: #c8facc;         // Lch(94,30,145)
@allotments: #c9e1bf;   // Lch(87,20,135)
@allotments-dark: #7a946f;
@orchard: #aedfa3; // also vineyard, plant_nursery
@hedge: @forest;       // Lch(80,30,135)
@hedge-width-z14: 0.8;
@hedge-width-z16: 1.5;
@barrier-color: #333;   // darker than original #444
@water-line-color: lighten(#4d80b3, 5%); // Also used for high/low water contours
@dark-water-color: darken(#4d80b3, 5%); // Water features e.g. waterfalls 
@cliff-color: #444;

// --- "Base" landuses ---

@built-up-z12: #c6c6c6;
//@built-up-z12: #dddddd;
//@built-up-lowzoom: #d0d0d0;
@built-up-lowzoom: @built-up-z12;
//@residential: #e0dfdf;      // Lch(89,0,0)
@residential: #c6c6c6;		// Lch(80,0,0)  A bit darker
@residential-line: #b9b9b9; // Lch(75,0,0)
//@retail: #ffd6d1;           // Lch(89,16,30)
//@retail-line: #d99c95;      // Lch(70,25,30)
@commercial: #f2dad9;       // Lch(89,8.5,25)
@commercial-line: #d1b2b0;  // Lch(75,12,25)
// Use same flatter colour for commercial vs. retail
@retail: @commercial;
@retail-line: @commercial-line;
@industrial: darken(#ebdbe8, 4%);       // was Lch(89,9,330) (Also used for railway, wastewater_plant)
@industrial-line: #c6b3c3;  // Lch(75,11,330) (Also used for railway-line, wastewater_plant-line)
@farmland: darken(#eef0d5, 4%);         // was Lch(94,14,112)
@farmland-line: #c7c9ae;    // Lch(80,14,112)
@farmland-linewidth: 0.7;
@farmyard: #f5dcba;         // Lch(89,20,80)
//@farmyard-line: brown;
//@farmyard-line: #d1b48c;    // Lch(75,25,80)
@fence-color: brown;

// --- Contours ---

@contours: darken(orange, 8%);
@contours-text: @contours;
@contours-multiplier: 1.75;
@contours-smooth: 0.5;
@contours-width: 0.5;
@contours-width-highzoom: 0.7;
@contours-width-z11: 0.25;
@contours-width-z12: 0.4;
@contours-opacity: 0.7;
@contours-opacity-z11: 0.7;
@contour-cutoff: 50;    // minimum number of pixels to display contour

// --- Transport ----

@transportation-area: #e9e7e2;
@apron: #dadae0;
@garages: #dfddce;
//@parking: #eeeeee;
//@parking-outline: saturate(darken(@parking, 40%), 20%);
// make parking stand out more clearly
@parking: white;
@parking-outline: #999;  // same as footway casing
@railway: @industrial;
@railway-line: @industrial-line;
@rest_area: #efc8c8; // also services

// --- Other ----

@bare_ground: #eee5dc;
@rocky_ground: #d0d0d0; // base colour for rock features e.g. scree
@campsite: #def6c0; // also caravan_site, picnic_site
@campsite-line: saturate(darken(@campsite, 60%), 30%);
@cemetery: #aacbaf; // also grave_yard
@construction: #c7c7b4; // also brownfield
@heath: #d6d99f;
@mud: rgba(203,177,154,0.3); // produces #e6dcd1 over @land
@place_of_worship: #d0d0d0; // also landuse_religious
@place_of_worship_outline: darken(@place_of_worship, 30%);
@leisure: lighten(@park, 5%);
@power: darken(@industrial, 5%);
@power-line: darken(@industrial-line, 5%);
@sand: #f5e9c6;
@societal_amenities: #ffffe5;   // Lch(99,13,109)
@tourism: #660033;
@quarry: #c3c3c3;
@military: #f55;
@beach: #fff1ba;
@wastewater_plant: @industrial;
@wastewater_plant-line: @industrial-line;
@water_works: @industrial;
@water_works-line: @industrial-line;

// --- Sports ---

@pitch: #88e0be;           // Lch(83,35,166) also track
@track: @pitch;
@stadium: @leisure; // also sports_centre
@golf_course: @campsite;

#landcover-low-zoom[zoom < 10],
#landcover[zoom >= 10] {
/*  ::low-zoom[zoom < 11] {
    // Increase the lightness of the map by scaling color lightness to be in the 20%-100% range
    image-filters: scale-hsla(0,1, 0,1, 0.2,1, 0,1);
  }*/

  ::low-zoom[zoom < 12],
  ::high-zoom[zoom >= 12] {

  [feature = 'leisure_swimming_pool'][zoom >= 14] {
    polygon-fill: @water-color;
    [zoom >= 17] {
      line-width: 0.5;
      line-color: saturate(darken(@water-color, 20%), 20%);
    }
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'landuse_recreation_ground'][zoom >= 10],
  [feature = 'leisure_playground'][zoom >= 13],
  [feature = 'leisure_fitness_station'][zoom >= 13] {
    polygon-fill: @leisure;
    [zoom >= 15] {
      line-color: darken(@leisure, 60%);
      line-width: 0.3;
    }
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'tourism_camp_site'],
  [feature = 'tourism_caravan_site'],
  [feature = 'tourism_picnic_site'] {
    [zoom >= 10] {
      polygon-fill: @campsite;
      [zoom >= 13] {
        line-color: @campsite-line;
        line-width: 0.3;
      }
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
  }

  [feature = 'landuse_quarry'][zoom >= 10] {
 //   polygon-fill: @quarry;
	polygon-fill: @rocky_ground;
    [zoom >= 12] { 
		polygon-pattern-file: url('symbols/mine_patterncompact.svg');
	}
	[historic != null] { 
		polygon-fill: @scrub;
		[zoom >= 12] { polygon-pattern-file: url('symbols/disusedmine_patterncompact.svg'); }
	}
 /*   [zoom >= 13] {
      line-width: 0.5;
      line-color: darken(@quarry, 10%);
    }*/
    [way_pixels >= 4][zoom >= 12] { polygon-pattern-gamma: 0.75; }
    [way_pixels >= 64][zoom >= 12] { polygon-pattern-gamma: 0.3;  }
  }

  [feature = 'landuse_vineyard'] {
    [zoom >= 5] {
      polygon-fill: @orchard;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
    [zoom >= 13] {
      polygon-pattern-file: url('patterns/vineyard.svg');
      polygon-pattern-alignment: global;
      [way_pixels >= 4]  { polygon-pattern-gamma: 0.75; }
      [way_pixels >= 64] { polygon-pattern-gamma: 0.3;  }
    }
  }

  [feature = 'landuse_orchard'] {
    [zoom >= 5] {
      polygon-fill: @orchard;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
    [zoom >= 13] {
      polygon-pattern-file: url('patterns/orchard.svg');
      polygon-pattern-alignment: global;
      [way_pixels >= 4]  { polygon-pattern-gamma: 0.75; }
      [way_pixels >= 64] { polygon-pattern-gamma: 0.3;  }
    }
  }

  [feature = 'leisure_garden'] {
    [zoom >= 10] {
      polygon-fill: @grass;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
    [zoom >= 13] {
      polygon-pattern-file: url('patterns/plant_nursery.svg');
      polygon-pattern-opacity: 0.6;
      polygon-pattern-alignment: global;
      [way_pixels >= 4]  { polygon-pattern-gamma: 0.75; }
      [way_pixels >= 64] { polygon-pattern-gamma: 0.3;  }
    }
  }

  [feature = 'landuse_flowerbed'] {
    [zoom >= 10] {
      polygon-fill: @grass;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
    [zoom >= 15] {
      polygon-pattern-file: url('symbols/flowerbed_mid_zoom.svg');
      polygon-pattern-alignment: global;
      [way_pixels >= 4]  { polygon-pattern-gamma: 0.75; }
      [way_pixels >= 64] { polygon-pattern-gamma: 0.3;  }
    }
    [zoom >= 17] {
      polygon-pattern-file: url('symbols/flowerbed_high_zoom.svg');
      polygon-pattern-alignment: global;
      [way_pixels >= 4]  { polygon-pattern-gamma: 0.75; }
      [way_pixels >= 64] { polygon-pattern-gamma: 0.3;  }
    }
  }

  [feature = 'landuse_plant_nursery'] {
    [zoom >= 10] {
      polygon-fill: @orchard;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
    [zoom >= 13] {
      polygon-pattern-file: url('patterns/plant_nursery.svg');
      polygon-pattern-alignment: global;
      [way_pixels >= 4]  { polygon-pattern-gamma: 0.75; }
      [way_pixels >= 64] { polygon-pattern-gamma: 0.3;  }
    }
  }

  [feature = 'landuse_cemetery'],
  [feature = 'amenity_grave_yard'] {
    [zoom >= 10] {
      polygon-fill: @cemetery;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
    [zoom >= 13] {
      [religion = 'jewish'] { polygon-pattern-file: url('patterns/grave_yard_jewish.svg'); }
      [religion = 'christian'] { polygon-pattern-file: url('patterns/grave_yard_christian.svg'); }
      [religion = 'muslim'] { polygon-pattern-file: url('patterns/grave_yard_muslim.svg'); }
      [religion = 'INT-generic'] { polygon-pattern-file: url('patterns/grave_yard_generic.svg'); }
      [religion = 'jewish'],
      [religion = 'christian'],
      [religion = 'muslim'],
      [religion = 'INT-generic'] {
        [way_pixels >= 4]  { polygon-pattern-gamma: 0.75; }
        [way_pixels >= 64] { polygon-pattern-gamma: 0.3;  }
      }
    }
  }

  [feature = 'amenity_place_of_worship'][zoom >= 13],
  [feature = 'landuse_religious'][zoom >= 13] {
    polygon-fill: @place_of_worship;
    polygon-clip: false;
    [zoom >= 15] {
      line-color: @place_of_worship_outline;
      line-width: 0.3;
      line-clip: false;
    }
  }

  [feature = 'amenity_prison'][zoom >= 10][way_pixels > 75] {
    polygon-fill: #8e8e8e;
    polygon-opacity: 0.14;
    polygon-pattern-file: url('patterns/grey_vertical_hatch.svg');
    polygon-pattern-alignment: global;
    line-color: #888;
    line-width: 3;
    line-opacity: 0.329;
  }

  [feature = 'landuse_residential'][zoom >= 8],
  [feature = 'landuse_trailer_park'][zoom >= 8] {
    polygon-fill: @built-up-lowzoom;
    [zoom >= 12] { polygon-fill: @built-up-z12; }
    [zoom >= 13] { polygon-fill: @residential; }
    [zoom >= 16] {
      line-width: .5;
      line-color: @residential-line;
      [name != ''] {
        line-width: 0.7;
      }
    }
	[feature = 'landuse_trailer_park'][zoom >= 12] {
      polygon-fill: @campsite;
      [zoom >= 13] {
        line-color: @campsite-line;
        [zoom < 16] { line-width: 0.3; }
      }
	}
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'landuse_garages'][zoom >= 13] {
    polygon-fill: @garages;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'leisure_park'] {
    [zoom >= 10] {
      polygon-fill: @park;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
  }

  [feature = 'leisure_ice_rink'][is_building = 'no'] {
    [zoom >= 10] {
      polygon-fill: @glacier;
      line-width: 0.5;
      line-color: saturate(darken(@pitch, 30%), 20%);
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
  }

  [feature = 'leisure_dog_park'] {
    [zoom >= 10] {
      polygon-fill: @leisure;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
    [zoom >= 16] {
      polygon-pattern-file: url('patterns/dog_park.svg');
      polygon-pattern-alignment: global;
      [way_pixels >= 4]  { polygon-pattern-gamma: 0.75; }
      [way_pixels >= 64] { polygon-pattern-gamma: 0.3;  }
    }
  }

  [feature = 'leisure_golf_course'][zoom >= 10],
  [feature = 'leisure_miniature_golf'][zoom >= 15] {
    polygon-fill: @golf_course;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'landuse_allotments'] {
    [zoom >= 10] {
      polygon-fill: @allotments;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
    [zoom >= 13] {
      polygon-pattern-file: url('patterns/allotments.svg');
      polygon-pattern-alignment: global;
      [way_pixels >= 4]  { polygon-pattern-gamma: 0.75; }
      [way_pixels >= 64] { polygon-pattern-gamma: 0.3;  }
    }
    [zoom >= 14] {
      line-width: 0.5;
      line-color: @allotments-dark;
      [name != null] {
        line-width: 0.7;
      }
    }
  }

  [feature = 'landuse_forest'][zoom >= 5] {
    polygon-fill: @forest;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
// Can't smooth one landuse without adding smoothing to everything
//	polygon-smooth: 0.5;
  }
  [feature = 'natural_wood'][zoom >= 5] {
    polygon-fill: @wood;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
//	polygon-smooth: 0.5;
  }

// Kill off farmyard border. Generally bordered anyway, by fence, wall, buildings
  [feature = 'landuse_farmyard'][zoom >= 10] {
    polygon-fill: @farmyard;
/*	[zoom >= 14] {
		line-width: 0.5;
        line-color: @farmyard-line;
	}
	[zoom >= 16] {
        line-width: 0.7;
    }*/
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'landuse_farmland'],
  [feature = 'landuse_greenhouse_horticulture'] {
    [zoom >= 5] {
      polygon-fill: @farmland;
      [zoom >= 15] {
        line-width: @farmland-linewidth;
        line-color: @farmland-line;
      }
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
  }

  [feature = 'landuse_grass'][zoom >= 5],
  [feature = 'landuse_village_green'][zoom >= 5] {
    polygon-fill: @grass;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'natural_grassland'],
  [feature = 'landuse_meadow'],
  [feature = 'landuse_pasture'] {
    polygon-fill: @meadow;
	[feature = 'landuse_pasture'][pasture = 'rough'],
	[feature = 'natural_grassland'] { polygon-fill: @scrub; }
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
	[feature != 'natural_grassland'][zoom >= 15] {
        line-width: @farmland-linewidth;
        line-color: @meadow-line;
    }
  }

  [feature = 'landuse_retail'],
  [feature = 'shop_mall'],
  [feature = 'amenity_marketplace'] {
    [zoom >= 8] {
      polygon-fill: @built-up-lowzoom;
      [zoom >= 12] { polygon-fill: @built-up-z12; }
      [zoom >= 13] { polygon-fill: @retail; }
      [zoom >= 16] {
        line-width: 0.5;
        line-color: @retail-line;
        [name != ''] {
          line-width: 0.7;
        }
        [way_pixels >= 4]  { polygon-gamma: 0.75; }
        [way_pixels >= 64] { polygon-gamma: 0.3;  }
      }
    }
  }

  [feature = 'landuse_industrial'][zoom >= 8] {
    polygon-fill: @built-up-lowzoom;
    [zoom >= 12] { polygon-fill: @built-up-z12; }
    [zoom >= 13] { polygon-fill: @industrial; }
    [zoom >= 16] {
      line-width: .5;
      line-color: @industrial-line;
      [name != ''] {
        line-width: 0.7;
      }
    }
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'man_made_works'][zoom >= 16] {
    line-width: .5;
    line-color: @industrial-line;
    [name != ''] {
      line-width: 0.7;
    }
  }

  [feature = 'man_made_wastewater_plant'] {
    polygon-fill: @industrial;
    [zoom >= 15] {
      polygon-fill: @wastewater_plant;
    }
    [zoom >= 16] {
      line-width: 0.5;
      line-color: @wastewater_plant-line;
      [name != ''] {
        line-width: 0.7;
      }
    }
  }

  [feature = 'man_made_water_works'] {
    polygon-fill: @industrial;
    [zoom >= 15] {
      polygon-fill: @water_works;
    }
    [zoom >= 16] {
      line-width: 0.5;
      line-color: @water_works-line;
      [name != ''] {
        line-width: 0.7;
      }
    }
  }

  [feature = 'landuse_railway'][zoom >= 10] {
    polygon-fill: @railway;
    [zoom >= 16][name != ''] {
      line-width: 0.7;
      line-color: @railway-line;
    }
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'power_plant'][zoom >= 10],
  [feature = 'power_generator'][zoom >= 10],
  [feature = 'power_substation'][zoom >= 13] {
    polygon-fill: @industrial;
    [zoom >= 15] {
      polygon-fill: @power;
    }
    [zoom >= 16] {
      line-width: 0.5;
      line-color: @power-line;
      [name != ''] {
        line-width: 0.7;
      }
    }
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'landuse_commercial'][zoom >= 8] {
    polygon-fill: @built-up-lowzoom;
    [zoom >= 12] { polygon-fill: @built-up-z12; }
    [zoom >= 13] { polygon-fill: @commercial; }
    [zoom >= 16] {
      line-width: 0.5;
      line-color: @commercial-line;
      [name != ''] {
        line-width: 0.7;
      }
    }
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'landuse_brownfield'],
  [feature = 'landuse_construction'] {
   [zoom >= 10] {
      polygon-fill: @construction;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
  }

  [feature = 'landuse_landfill'] {
    [zoom >= 10] {
      polygon-fill: #b6b592;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
  }

  [feature = 'landuse_salt_pond'][zoom >= 10] {
    polygon-fill: @water-color;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'natural_bare_rock'][zoom >= 5] {
    polygon-fill: @rocky_ground;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
    [zoom >= 13] {
      polygon-pattern-file: url('symbols/barerock_compact.svg');
      [way_pixels >= 4]  { polygon-pattern-gamma: 0.75; }
      [way_pixels >= 64] { polygon-pattern-gamma: 0.3;  }
    }
  }

  [feature = 'natural_scree'],
  [feature = 'natural_shingle'] {
    [zoom >= 5] {
      polygon-fill: @bare_ground;
	  [feature = 'natural_scree'] { polygon-fill: @rocky_ground; }
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
      [zoom >= 13] {
        polygon-pattern-file: url('symbols/scree_compact.svg');
        [way_pixels >= 4]  { polygon-pattern-gamma: 0.75; }
        [way_pixels >= 64] { polygon-pattern-gamma: 0.3;  }
      }
    }
  }

  [feature = 'natural_sand'][zoom >= 5] {
    polygon-fill: @sand;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'natural_heath'][zoom >= 5] {
    polygon-fill: @heath;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'natural_scrub'][zoom >= 5] {
    polygon-fill: @scrub;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'wetland_swamp'][zoom >= 5] {
    polygon-fill: @forest;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'wetland_mangrove'][zoom >= 5] {
    polygon-fill: @scrub;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'wetland_reedbed'][zoom >= 5] {
    polygon-fill: @grass;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'wetland_bog'],
  [feature = 'wetland_string_bog'] {
    [zoom >= 5] {
      polygon-fill: @heath;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
  }

  [feature = 'wetland_wet_meadow'],
  [feature = 'wetland_fen'],
  [feature = 'wetland_saltmarsh'],
  [feature = 'wetland_marsh'] {
    [zoom >= 5] {
      polygon-fill: @grass;
      [feature = 'wetland_saltmarsh'][zoom >= 13] {
        polygon-pattern-file: url('symbols/salt-dots-2.png');
        polygon-pattern-alignment: global;
        [way_pixels >= 4]  { polygon-pattern-gamma: 0.75; }
        [way_pixels >= 64] { polygon-pattern-gamma: 0.3;  }
      }
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
  }

  [feature = 'amenity_hospital'],
  [feature = 'amenity_clinic'],
  [feature = 'amenity_university'],
  [feature = 'amenity_college'],
  [feature = 'amenity_school'],
  [feature = 'amenity_kindergarten'],
  [feature = 'amenity_community_centre'],
  [feature = 'amenity_social_facility'],
  [feature = 'amenity_arts_centre'] {
    [zoom >= 10] {
      polygon-fill: @built-up-lowzoom;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
    [zoom >= 12] {
      polygon-fill: @built-up-z12;
    }
    [zoom >= 13] {
      polygon-fill: @societal_amenities;
      line-width: 0.3;
      line-color: darken(@societal_amenities, 35%);
    }
  }

  [feature = 'amenity_fire_station'][zoom >= 8][way_pixels > 900],
  [feature = 'amenity_police'][zoom >= 8][way_pixels > 900],
  [feature = 'amenity_fire_station'][zoom >= 13],
  [feature = 'amenity_police'][zoom >= 13] {
    polygon-fill: #F3E3DD;
    line-color: @military;
    line-opacity: 0.24;
    line-width: 1.0;
    line-offset: -0.5;
    [zoom >= 15] {
      line-width: 2;
      line-offset: -1.0;
    }
  }

  [feature = 'amenity_parking'],
  [feature = 'amenity_bicycle_parking'],
  [feature = 'amenity_motorcycle_parking'],
  [feature = 'amenity_taxi'] {
    [zoom >= 14] {
      polygon-fill: @parking;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] {
		    polygon-gamma: 0.3;
        line/line-width: 0.5;
        line/line-color: @parking-outline;
      }
    }
  }

  [feature = 'amenity_parking_space'][zoom >= 18] {
    line-width: 0.3;
    line-color: mix(@parking-outline, @parking, 50%);
  }

  [feature = 'aeroway_apron'][zoom >= 10] {
    polygon-fill: @apron;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'aeroway_aerodrome'][zoom >= 10],
  [feature = 'amenity_ferry_terminal'][zoom >= 15],
  [feature = 'amenity_bus_station'][zoom >= 15] {
    polygon-fill: @transportation-area;
    line-width: 0.2;
    line-color: saturate(darken(@transportation-area, 40%), 20%);
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'natural_beach'][zoom >= 10],
  [feature = 'natural_shoal'][zoom >= 10] {
    polygon-fill: @beach;
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'highway_services'],
  [feature = 'highway_rest_area'] {
    [zoom >= 10] {
      polygon-fill: @rest_area;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
    }
  }

  [feature = 'railway_station'][zoom >= 10] {
    polygon-fill: @railway;
  }

  [feature = 'leisure_sports_centre'],
  [feature = 'leisure_water_park'],
  [feature = 'leisure_stadium'] {
    [zoom >= 10] {
      polygon-fill: @stadium;
      [way_pixels >= 4]  { polygon-gamma: 0.75; }
      [way_pixels >= 64] { polygon-gamma: 0.3;  }
      [zoom >= 13] {
        line-width: 0.3;
        line-color: darken(@stadium, 35%);
      }
    }
  }

  [feature = 'leisure_track'][zoom >= 10] {
    polygon-fill: @track;
    [zoom >= 15] {
      line-width: 0.5;
      line-color: desaturate(darken(@track, 20%), 10%);
    }
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }

  [feature = 'leisure_pitch'][zoom >= 10] {
    polygon-fill: @pitch;
    [zoom >= 14] {
      line-width: 0.5;
      line-color: desaturate(darken(@pitch, 20%), 10%);
    }
    [way_pixels >= 4]  { polygon-gamma: 0.75; }
    [way_pixels >= 64] { polygon-gamma: 0.3;  }
  }
}
}

/* man_made=cutline */
#landcover-line {
  [zoom >= 14] {
    line-width: 3;
    line-join: round;
// revert to default butt
//    line-cap: square;
// matches meadow
    line-color: lighten(@grass, 8%);
    [zoom >= 16] {
      line-width: 6;
      [zoom >= 18] {
        line-width: 12;
      }
    }
  }
}

#landcover-area-symbols {

  ::first {
    [natural = 'mud'] {
      [zoom >= 9] {
        polygon-fill: @mud;
        [way_pixels >= 4]  { polygon-gamma: 0.75; }
        [way_pixels >= 64] { polygon-gamma: 0.3;  }
      }
    }
 }

  [wetland = 'yes'][zoom >= 10],
  [natural = 'wetland'][zoom >= 10] {
    polygon-pattern-file: url('symbols/wetland-compact.svg');
    polygon-pattern-alignment: global;
  }
  [wetland = 'partial'][zoom >= 10] {
    cover/polygon-pattern-file: url('symbols/semi_wetland-compact.svg');
    cover/polygon-pattern-alignment: global;
  }  
  [natural = 'reef'][zoom >= 10] {
    polygon-pattern-file: url('symbols/reef.png');
    polygon-pattern-alignment: global;
  }
  [zoom >= 13] {
/*    [int_wetland = 'marsh'],
    [int_wetland = 'saltmarsh'],
    [int_wetland = 'wet_meadow'] {
      polygon-pattern-file: url('symbols/wetland_marsh.png');
      polygon-pattern-alignment: global;
    }
    [int_wetland = 'reedbed'] {
      polygon-pattern-file: url('symbols/wetland_reed.png');
      polygon-pattern-alignment: global;
    }
    [int_wetland = 'mangrove'] {
      polygon-pattern-file: url('symbols/wetland_mangrove.png');
      polygon-pattern-alignment: global;
    }
    [int_wetland = 'swamp'] {
      polygon-pattern-file: url('symbols/wetland_swamp.png');
      polygon-pattern-alignment: global;
    }
    [int_wetland = 'bog'],
    [int_wetland = 'fen'],
    [int_wetland = 'string_bog'] {
      polygon-pattern-file: url('symbols/wetland_bog.png');
      polygon-pattern-alignment: global;
    }
    [landuse = 'salt_pond'] {
      polygon-pattern-file: url('symbols/salt_pond.png');
      polygon-pattern-alignment: global;
    }
    [natural = 'beach'],
    [natural = 'shoal'] {
      [surface = 'sand'] {
        polygon-pattern-file: url('symbols/beach.png');
        polygon-pattern-alignment: global;
      }
      [surface = 'gravel'],
      [surface = 'fine_gravel'],
      [surface = 'pebbles'],
      [surface = 'pebblestone'],
      [surface = 'shingle'],
      [surface = 'stones'],
      [surface = 'shells'] {
        polygon-pattern-file: url('symbols/beach_coarse.png');
        polygon-pattern-alignment: global;
      }
    } */
	// Just use scrub colour for wet scrub
    [natural = 'scrub'][wetland = null] {
      polygon-pattern-file: url('symbols/scrub-compact.svg');
	  [zoom >= 16] { polygon-pattern-file: url('symbols/scrub.png'); }
      polygon-pattern-alignment: global;
    }
  }

  //Also landuse = forest, converted in the SQL
  [natural = 'wood'][zoom >= 14][wetland = null][leaf_type != null]::wood {
    polygon-pattern-file: url('symbols/leaftype_mixed_compact.svg');
    [leaf_type = "broadleaved"] { polygon-pattern-file: url('symbols/leaftype_broadleaved_compact.svg'); }
    [leaf_type = "needleleaved"] { polygon-pattern-file: url('symbols/leaftype_needleleaved_compact.svg'); }
    [leaf_type = "mixed"] { polygon-pattern-file: url('symbols/leaftype_mixed_compact.svg'); }
//    [leaf_type = "leafless"] { polygon-pattern-file: url('symbols/leaftype_leafless.svg'); }
	
    polygon-pattern-alignment: global;
    opacity: 0.75; // The entire layer has opacity to handle overlapping forests
// This doesn't work - will need to shrink pattern
//	[zoom < 16] { polygon-pattern-geometry-transform: scale(0.5); }
  }
  
  [landuse = 'pasture'][zoom >= 14] {
	polygon-pattern-file: url('symbols/cows.svg'); 
 //   polygon-pattern-alignment: global;
	polygon-pattern-opacity: 0.25;
  }
}

#landuse-overlay {
  [landuse = 'military'][zoom >= 8][way_pixels > 900],
  [landuse = 'military'][zoom >= 13] {
    polygon-fill: #ff5555;
    polygon-opacity: 0.08;
    polygon-pattern-file: url('patterns/military_red_hatch.svg');
    polygon-pattern-alignment: global;
    line-color: @military;
    line-opacity: 0.24;
    line-width: 1.0;
    line-offset: -0.5;
    [zoom >= 15] {
      line-width: 2;
      line-offset: -1.0;
    }
  }

  [military = 'danger_area'][zoom >= 9] {
    polygon-fill: #ff5555;
    polygon-opacity: 0.1;
    polygon-pattern-file: url('patterns/danger_red_hatch.svg');
    polygon-pattern-alignment: global;
    line-color: @military;
    line-opacity: 0.2;
    line-width: 2;
    line-offset: -1.0;
  }
}

#cliffs {
  [natural = 'cliff'] {
	line/line-width: 0.7;
	line/line-color: @cliff-color;
	marker-file: url('symbols/sidetriangle.svg');
	marker-fill: @cliff-color;
	marker-placement: line;
	marker-spacing: 7;
	marker-offset: 1.5;
	[zoom >= 16] {
		line/line-width: 1.0;
		marker-width: 7;
		marker-spacing: 14;
		marker-offset: 3.0;
	}
	marker-allow-overlap: true;
	marker-ignore-placement: true;
  }
  [natural = 'arete'] {
	line/line-width: 0.7;
	line/line-color: @cliff-color;
	marker-file: url('symbols/sidetriangles.svg');
	marker-placement: line;
	marker-spacing: 10;
	marker-allow-overlap: true;
	marker-ignore-placement: true;
  }
  [man_made = 'embankment'][zoom >= 15]::man_made {
		marker-file: url('symbols/roundedmiddowntriangle.svg');
		marker-fill: @earthworks-color;
		marker-placement: line;
		marker-spacing: 7.5;
		marker-offset: 1;
		marker-allow-overlap: true;
		marker-ignore-placement: true;
		[zoom >= 17] {
			marker-file: url('symbols/roundedtalldowntriangle.svg');
			marker-width: 5;
			marker-spacing: 15;
			marker-offset: 2;
		}	
  }
}

#barriers {
  [feature = 'barrier_city_wall'],
  [feature = 'barrier_ruined_city_wall'],
  [zoom >= 14] {
	line-width: 0.5;
    line-color: @barrier-color;
  [zoom >= 16] { line-width: 0.8; }
  [feature = 'barrier_ruins'] {
	line-dasharray: 1,2;
	[zoom >= 17] { line-dasharray: 2,4; }
  }
  [feature = 'barrier_fence'] { line-color: @fence-color; } 
  // barrier=ditch follows logic of wayerway=ditch, but with grey colour
  [feature = 'barrier_ditch'] {
		line-color: #aaa;
		line-width: @stream-width-z13;
		[zoom > 14] { line-width: @stream-width-z14; }
  }
  [feature = 'barrier_retaining_wall'] {
	marker-file: url('symbols/sidebump.svg');
	marker-fill: @barrier-color;
	marker-placement: line;
	marker-spacing: 7;
	marker-transform: translate(0,-0.8); 
	marker-offset: 1.5;
	marker-allow-overlap: true;
	marker-ignore-placement: true;
  }
  [feature = 'barrier_hedge'][zoom >= 14] {
	line-width: @hedge-width-z14;
    [zoom >=16] { line-width: @hedge-width-z16; }
    line-color: @hedge;
    [zoom >= 17] {
      line-width: 2;
    }
    [zoom >= 18] {
      line-width: 3;
    }
    [zoom >= 19] {
      line-width: 4;
    }
//    [zoom >= 20] {
//      line-width: 5;
//    }
  }
  [feature = 'barrier_city_wall'],
  [feature = 'barrier_ruined_city_wall'] {
    line-color: lighten(@barrier-color, 15%);
	line-width: 1.5;
	[zoom >= 14] { line-width: 2; }
    [zoom >= 16] { line-width: 2.5; }
    [zoom >= 17] {
      line-width: 3;
// Not sure what these were about
//      barrier/line-width: 0.4;
//      barrier/line-color: @barrier-color;
    }
    [zoom >= 18] { line-width: 3.5; }
    [zoom >= 19] { line-width: 4; }
//    [zoom >= 20] {
//      line-width: 5;
//    }
	[feature = 'barrier_ruined_city_wall'] {
		line-dasharray: 5,3,2,2;
		[zoom >= 17] { line-dasharray: 8,5,4,4; }
	}
  }
  }
}

#tourism-boundary {
  [zoom >= 12][way_pixels >= 200] {
    a/line-width: 1;
    a/line-offset: -0.5;
    a/line-color: @tourism;
    a/line-opacity: 0.5;
    a/line-join: round;
    a/line-cap: round;
    [zoom >= 17],
    [way_pixels >= 60] {
      b/line-width: 4;
      b/line-offset: -2;
      b/line-color: @tourism;
      b/line-opacity: 0.3;
      b/line-join: round;
      b/line-cap: round;
    }
    [zoom >= 17] {
      a/line-width: 2;
      a/line-offset: -1;
      b/line-width: 6;
      b/line-offset: -3;
    }
  }
}

#text-line {
  [feature = 'natural_valley'][zoom < 13] {
    text-name: "[name]";
    text-halo-radius: @standard-halo-radius;
    text-halo-fill: @standard-halo-fill;
    text-size: 10;
	[way_pixels > 200] { text-size: 13; }
    text-face-name: @oblique-fonts;
    text-placement: line;
	text-fill: @landform-color-text;
    text-vertical-alignment: middle;
  }
  [feature = 'natural_arete'][zoom >= 14],
  [feature = 'natural_cliff'][zoom >= 14],
  [feature = 'natural_ridge'][zoom >= 14],
  [feature = 'man_made_embankment'][zoom >= 14] {
    text-name: "[name]";
    text-halo-radius: @standard-halo-radius;
    text-halo-fill: @standard-halo-fill;
	[feature = 'natural_ridge'] {
		text-face-name: @oblique-fonts;
		text-fill: @landform-color-text;
		text-size: @standard-font-size;
		[zoom >= 16] { text-size: @larger-font-size; }
	}
	[feature != 'natural_ridge'] {
		text-face-name: @book-fonts;
		text-fill: @cliff-color;
		text-size: @small-font-size;
		[zoom >= 16] { text-size: @standard-font-size; }
		text-dy: 8;
		text-spacing: 400;
	}
    text-placement: line;
    text-vertical-alignment: middle;
  }
}

#gridlines {
	line-color: @water-color;
	line-width: 0.5;
  [zoom >= 15] { line-width: 0.8; }
}

#landcontours {
  [way_pixels = 0], [way_pixels > @contour-cutoff]  {
	[is_20 = 'yes'], [zoom >= 13] {
	  line-width: @contours-width;
	  [zoom = 11] { line-width: @contours-width-z11; }
	  [zoom = 12] { line-width: @contours-width-z12; }
	  [zoom >= 16] { line-width: @contours-width-highzoom; }
	  [is_major = 'yes'][zoom >=14] {
		line-width: @contours-width * @contours-multiplier;
		[zoom >= 16] { line-width: @contours-width-highzoom * @contours-multiplier; }
	  }
	  line-color: @contours;
	  line-smooth: @contours-smooth;
	  line-opacity: @contours-opacity;
	  [zoom = 11] { line-opacity: @contours-opacity-z11; }
	}
  }
}

#watercontours {
  [way_pixels = 0], [way_pixels > @contour-cutoff] {
  
  line-width: @contours-width * @contours-multiplier;
  [zoom = 12] { line-width: @contours-width-z12; }
  [zoom >= 14] { line-width: @contours-width * @contours-multiplier; }
  [zoom >= 16] { line-width: @contours-width-highzoom * @contours-multiplier; }
  line-color: @water-line-color;
  [sub_type = 'meanLowWater'] { line-dasharray: 2,4; }
  line-opacity: @contours-opacity;
  }
}

#contours-text {
  [way_pixels = 0], [way_pixels > @contour-cutoff] {
  text-name: "[prop_value]";
  text-face-name: @book-fonts;
  text-placement: line;
  text-fill: @contours-text;
  text-halo-fill: @standard-halo-fill;
  text-halo-radius: @standard-halo-radius;
  text-spacing: 400;
  [zoom < 15] { text-size: 7; }
  text-size: 8;
  }
}

	