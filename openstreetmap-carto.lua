-- For documentation of Lua tag transformations, see:
-- https://github.com/openstreetmap/osm2pgsql/blob/master/docs/lua.md

-- Objects with any of the following keys will be treated as polygon

-- abandoned seems a bit random... (PH)

local polygon_keys = {
    'abandoned:aeroway',
    'abandoned:amenity',
    'abandoned:building',
    'abandoned:landuse',
    'abandoned:power',
    'aeroway',
    'allotments',
    'amenity',
    'area:highway',
    'craft',
    'building',
    'building:part',
    'club',
    'golf',
    'emergency',
    'harbour',
    'healthcare',
    'historic',
    'landuse',
    'leisure',
    'man_made',
    'military',
    'natural',
    'office',
    'place',
    'power',
    'public_transport',
    'shop',
    'tourism',
    'water',
    'waterway',
    'wetland'
}

-- Objects with any of the following key/value combinations will be treated as linestring
local linestring_values = {
    golf = {cartpath = true, hole = true, path = true}, 
    emergency = {designated = true, destination = true, no = true, official = true, yes = true},
    historic = {citywalls = true},
    leisure = {track = true, slipway = true},
    man_made = {breakwater = true, cutline = true, embankment = true, groyne = true, pipeline = true},
    natural = {cliff = true, earth_bank = true, tree_row = true, ridge = true, arete = true},
    power = {cable = true, line = true, minor_line = true},
    tourism = {yes = true},
    waterway = {canal = true, derelict_canal = true, ditch = true, drain = true, river = true, stream = true, tidal_channel = true, wadi = true, weir = true}
}

-- Objects with any of the following key/value combinations will be treated as polygon
local polygon_values = {
    aerialway = {station = true},
    boundary = {aboriginal_lands = true, national_park = true, protected_area= true},
    highway = {services = true, rest_area = true},
    junction = {yes = true},
    railway = {station = true}
}

-- The following keys will be deleted
-- Non-UK tags removed (PH)
local delete_tags = {
    'note',
    'source',
    'source_ref',
    'attribution',
	'description',
    'comment',
    'fixme',
	'FIXME',
    -- Tags generally dropped by editors, not otherwise covered
    'created_by',
    'odbl',

    -- misc
    'import',
    'import_uuid',
    'OBJTYPE',
    'SK53_bulk:load'
}

delete_prefixes = {
    'note:',
    'source:',
    -- Naptan (UK)
    'naptan:',
}

delete_exceptions = { 'naptan:verified' }

-- Big table for z_order and roads status for certain tags. z=0 is turned into
-- nil by the z_order function
local roads_info = {
    highway = {
        motorway        = {z = 380, roads = true},
        trunk           = {z = 370, roads = true},
        primary         = {z = 360, roads = true},
        secondary       = {z = 350, roads = true},
        tertiary        = {z = 340, roads = false},
        residential     = {z = 330, roads = false},
        unclassified    = {z = 330, roads = false},
        road            = {z = 330, roads = false},
-- Note that track is combined with service
        living_street   = {z = 320, roads = false},
        pedestrian      = {z = 310, roads = false},
        raceway         = {z = 300, roads = false},
        motorway_link   = {z = 240, roads = true},
        trunk_link      = {z = 230, roads = true},
        primary_link    = {z = 220, roads = true},
        secondary_link  = {z = 210, roads = true},
        tertiary_link   = {z = 200, roads = false},
        service         = {z = 150, roads = false},
        track           = {z = 110, roads = false},
-- Fake highway types created from route relations
		rwn             = {z = 110, roads = false},
		lwn             = {z = 110, roads = false},
        path            = {z = 100, roads = false},
-- Promote footway to just below service
        footway         = {z = 130, roads = false},
        bridleway       = {z = 100, roads = false},
-- Move cycleway up since these are often parallel too and over-written by roads at zoom = 14
        cycleway        = {z = 375, roads = false},
        steps           = {z = 90,  roads = false},
        platform        = {z = 90,  roads = false}
    },
    railway = {
        rail            = {z = 440, roads = true},
        subway          = {z = 420, roads = true},
        narrow_gauge    = {z = 420, roads = true},
        light_rail      = {z = 420, roads = true},
        funicular       = {z = 420, roads = true},
        preserved       = {z = 420, roads = false},
        monorail        = {z = 420, roads = false},
        miniature       = {z = 420, roads = false},
        turntable       = {z = 420, roads = false},
        tram            = {z = 410, roads = false},
-- Move disused railway down
        disused         = {z = 80, roads = false},
        dismantled      = {z = 80, roads = false},
        construction    = {z = 400, roads = false},
        platform        = {z = 90,  roads = false},
    },
    aeroway = {
        runway          = {z = 60,  roads = false},
        taxiway         = {z = 50,  roads = false},
    },
    boundary = {
        administrative  = {z = 0,  roads = true}
    },
}

local excluded_railway_service = {
    spur = true,
    siding = true,
    yard = true
}
--- Gets the z_order for a set of tags
-- @param tags OSM tags
-- @return z_order if an object with z_order, otherwise nil
function z_order(tags)
    local z = 0
    for k, v in pairs(tags) do
        if roads_info[k] and roads_info[k][v] then
            z = math.max(z, roads_info[k][v].z)
        end
    end

    if tags["highway"] == "construction" then
        if tags["construction"] and roads_info["highway"][tags["construction"]] then
            z = math.max(z, roads_info["highway"][tags["construction"]].z/10)
        else
            z = math.max(z, 33)
        end
    end

    return z ~= 0 and z or nil
end

--- Gets the roads table status for a set of tags
-- @param tags OSM tags
-- @return 1 if it belongs in the roads table, 0 otherwise
function roads(tags)
    for k, v in pairs(tags) do
        if roads_info[k] and roads_info[k][v] and roads_info[k][v].roads then
            if not (k ~= 'railway' or tags.service) then
                return 1
            elseif not excluded_railway_service[tags.service] then
                return 1
            end
        end
    end
    return 0
end

local meadow_tags = { 'pasture', 'paddock', 'meadow', 'animal_keeping' }
local known_rentals = { 'car_rental', 'bicycle_rental' }
local tradeshop_tags = { 'builders_merchant', 'plumbers_merchant', 'building_materials' }
local sportshop_tags = { 'scuba_diving', 'water_sports', 'fishing' }
local mine_tags = { 'mine', 'mine_shaft', 'mineshaft', 'adit', 'mine_level', 'mine_adit' }
local promotetocraft_tags = { 'tailor', 'computer_repair', 'photo_studio', 'shoe_repair' }
local healthcarestrip_tags = { 'clinic', 'hospital', 'hospice', 'pharmacy', 'doctors', 'dentist', 'veterinary'}
local important_protected_tags = { 'national_park', 'area_of_outstanding_natural_beauty', 'Area of Outstanding Natural Beauty'}
local communitycentre_tags = { 'village_hall', 'social_centre', 'scout_hut' }
local ford_tags = { 'stream', 'intermittent', 'tidal', 'seasonal' }
 
--- If tagged with disused, turn into 'historic=yes'

--- Generic filtering of OSM tags
-- @param tags Raw OSM tags
-- @return Filtered OSM tags
function filter_tags_generic(tags)
    -- Short-circuit for untagged objects
    if next(tags) == nil then
        return 1, {}
    end

	if tags['opening_hours'] == 'closed' then
		if tags['amenity'] then
			tags['amenity'] = nil
		elseif tags['shop'] then
			tags['shop'] = nil
		end
	end

    -- Delete tags listed in delete_tags
    for _, d in ipairs(delete_tags) do
        tags[d] = nil
    end

    -- By using a second loop for wildcards we avoid checking already deleted tags
    for tag, _ in pairs (tags) do
        for _, d in ipairs(delete_prefixes) do
            if string.sub(tag, 1, string.len(d)) == d then
				if not is_in(d, delete_exceptions) then
					tags[tag] = nil
				end
                break
            end
        end
    end
	
	-- Actively suppress building=no to simplify SQL
	if tags['building'] == 'no' then
		tags['building'] = nil
	end
	
	-- Consolidate key contact tags
	if tags['contact:website'] then
		if tags['website'] == nil then
			tags['website'] = tags['contact:website']
		end
		tags['contact:website'] = nil
	end
	if tags['contact:facebook'] then
		if tags['facebook'] == nil then
			tags['facebook'] = tags['contact:facebook']
		end
		tags['contact:facebook'] = nil
	end
	
	if tags["name:en"] and (tags["name"] == nil) then
		tags["name"] = tags["name:en"]
	end
	
	-- Suppress admin boundaries
   if (tags["boundary"] == "administrative") then
      tags["boundary"] = nil
   end
   
    -- Try to second-guess what permissive actually means (only relevant to paths which change colour)
    if tags['access'] == 'permissive' then
		if (tags['highway'] == 'path') or (tags['highway'] == 'footway') then
			tags['foot'] = 'permissive'
		end
	--	tags['access'] = 'yes'
	end

	-- Strip out bogus archaeological sites
	if (tags['historic'] == 'archaeological_site') and tags['name'] and string.find(tags['name'], "old mine workings") then
		return 1, {}
	end

   -- Filter out objects that have no tags after deleting
    if next(tags) == nil then
        return 1, {}
    end
	
	if is_in(tags['ford'], ford_tags) then
		tags['ford'] = 'yes'
	end

	-- Normalise to disused:man_made but abandoned:landuse
	if tags['abandoned:man_made'] then
		tags['disused:man_made'] = tags['abandoned:man_made']
		tags['abandoned:man_made'] = nil
	end
	
	if tags['disused:landuse'] then
		tags['abandoned:landuse'] = tags['disused:landuse']
		tags['disused:landuse'] = nil
	end

	--- Fudge disused status into historic = yes
	--- Combine mine, mineshaft and adit (often poorly distinguished)
	if tags['disused:man_made'] then
		tags['man_made'] = tags['disused:man_made']
		tags['historic'] = 'yes'
	end
	if (tags['abandoned:landuse'] == 'quarry') or (tags['historic'] == 'quarry') then
		tags['landuse'] = 'quarry'
		tags['historic'] = 'yes'
	end
	if tags['man_made'] == 'adit' then
		tags['man_made'] = 'mineshaft'
	end
	if (tags['disused'] == 'yes') or (tags['abandoned'] == 'yes') then
		tags['historic'] = 'yes'
	end
	if is_in(tags['historic'], mine_tags) then
		tags['man_made'] = 'mineshaft'
		tags['historic'] = 'yes'
	end
	
	if tags['historic'] == 'pinfold' then
		tags['man_made'] = 'sheepfold'
	end
	
	if (tags['man_made'] == 'spoil_heap') or (tags['disused:man_made'] == 'spoil_heap') then
		tags['natural'] = 'scree'
	end
			
	if tags['landuse'] == 'farmland' then
		if is_in(tags['farmland'], meadow_tags) or (tags['animal'] ~= nil) then
			if (tags['farmland'] ~= 'meadow') or (tags['animal'] ~= nil) then
				tags['meadow'] = 'pasture'
			end
			tags['landuse'] = 'meadow'
		end
	elseif tags['landuse'] == 'forest' then
	-- assume plantations are conifers if not stated otherwise (will trigger a darker colour)
		if tags['leaf_type'] then
			tags['leaf_type'] = 'needleleaved'  
		elseif tags['leaf_type'] == 'broadleaved' then
			tags['landuse'] = nil
			tags['natural'] = 'wood'
		end
	end
	if (tags['landuse'] == 'meadow') and (tags['meadow'] == 'pasture') then
	-- Fake new landuse to distinguish animal grazing
		tags['landuse'] = 'pasture'
		if tags['pasture'] == 'unimproved' then
			tags['pasture'] = 'rough'
		end
	end
	if (tags['natural'] == 'wood') and (tags['leaf_type'] == 'needleleaved') then
		tags['natural'] = nil
		tags['landuse'] = 'forest'
	end
	
	if tags['healthcare'] then
		-- Merge hospital
		if tags['healthcare'] == 'hospital' then
			tags['amenity'] = 'hospital'
		elseif tags['amenity'] and is_in(tags['amenity'], healthcarestrip_tags) then
		--  As healthcare now rendered, remove any double-tagging
			tags['healthcare'] = nil
		end		
	end
	
	-- Find likely disused units
	if tags['old_name'] and (tags['name'] == nil) and tags['addr:unit'] then
	-- Kill off address info to prevent empty units in otherwise busy area showing up
		tags['addr:unit'] = nil
		tags['addr:housename'] = nil
	end

-- Bodge lack of rendering of dedicated sports hall
	if tags['leisure'] == 'sports_hall' then
		tags['leisure'] = 'sports_centre'
	end
	
    -- Convert layer to an integer
    tags['layer'] = layer(tags['layer'])

	-- If name does not exist but name:en does, use it.	
    if (tags['name'] == nil) and tags['name:en'] then
		tags['name'] = tags['name:en']
    end
	-- Try to find missing names
	if tags['name'] == nil then
	-- Possibly useful more generally, but common for fuel
		if (tags['amenity'] == 'fuel') or tags['shop'] then
			if tags['brand'] then
				tags['name'] = tags['brand']
			else
				tags['name'] = tags['operator']
			end
		elseif tags['power'] == 'substation' then
			tags['name'] = tags['ref']
		elseif (tags['leisure'] == 'outdoor_seating') and tags['operator'] then
			tags['name'] = "(" .. tags['operator'] .. ")"
		end
	end
	
	-- Normalise use of common
	if (tags['leisure'] == 'common') and (tags['designation'] == nil) then
		tags['designation'] = 'common'
	end

-- Ensure national parks and AONBs are rendered by explictly setting a protect class (up to 6 rendered)
-- protect_class = 7 often used for local nature reserves
-- Similarly show common land as 'minor protected area'
	if tags["boundary"] == "protected_area" then
		if is_in(tags["designation"], important_protected_tags) then
			tags["protect_class"] = "5"
		else
			if tags["designation"] == 'SSSI' then
				tags["designation"] = 'site_of_special_scientific_interest'				
			end
			if ((tags["designation"] == 'site_of_special_scientific_interest') and (tags["leisure"] ~= "nature_reserve")) or (tags["designation"] == 'common') then
				tags["protect_class"] = '7'
			end
		end
    end

	if tags['ruins:building'] or tags['ruined:building'] or (tags['building'] == 'collapsed') then
		tags['building'] = 'ruins'
	elseif tags['building'] and ((tags['ruined'] == 'yes') or (tags['ruins'] == 'yes') or (tags['historic'] == 'ruins')) then
		tags['building'] = 'ruins'
	end
	-- Kill off tagging to make ruins buildings show up as walls
	if (tags['buildings'] == 'ruins') and (tags['barrier'] == 'wall') then
		tags['barrier'] = nil
	end
		
	-- Try to strip leading The from pub/cafe names if results has >1 word
	-- e.g. will shorten to "Rat and Ratchet" but not change "The Rat"
	if ((tags['amenity'] == 'pub') or (tags['amenity'] == 'cafe')) and tags['name'] then
		stripname = string.match(tags['name'], "^The (.*)")
		if stripname and string.find(stripname, " ") then
			tags['name'] = stripname
		end
	end
	
	-- Remove bar/bar tagging for social clubs now that club is rendered
	if tags['club'] == 'social' then
		if (tags['amenity'] == 'bar') or (tags['amenity'] == 'pub') then
			tags['amenity'] = nil
		end
	end
	-- Render scout buildings as community centre
	if (tags['club'] == 'scout') and tags['building'] then
		tags['amenity'] = 'community_centre'
		tags['club'] = nil
	end
	
	if is_in(tags['amenity'], communitycentre_tags) then
		tags['amenity'] = 'community_centre'
	elseif tags['amenity'] == 'social_club' then
		tags['club'] = 'social'
		tags['amenity'] = nil
	end
	
	if tags['leisure'] == 'social_club' then
		tags['club'] = 'social'
		tags['leisure'] = nil
	end
	
	if (tags["railway"] == "platform") and tags["ref"] then
		tags["name"] = "Platform " .. tags["ref"]
        tags["ref"]  = nil
    end
	
	-- Convert incorrect beer gardens into outdoor_seating
    if (tags["amenity"] == "biergarten") and (tags["name"] == nil) and (tags["leisure"] == nil) then
		tags["leisure"] = "outdoor_seating"
		tags["amenity"] = nil
	end
	
	if (tags['amenity'] == 'social_facility') and (tags['social_facility'] == 'hospice') then
		tags['amenity'] = nil
		tags['healthcare'] = 'hospice'
	end
	
		
	-- As craft is now rendered, prioritise craft over shop 
	if tags['craft'] then
		tags['shop'] = nil
	elseif is_in(tags['shop'], promotetocraft_tags) then
		tags['craft'] = tags['shop']
		tags['shop'] = nil
	end
	
	if tags['shop'] then
		if tags['shop'] == 'car;car_repair' then
			tags['shop'] = 'car'
		elseif tags['shop'] == 'appliance' then
			tags['shop'] = 'electronics'
		elseif tags['shop'] == 'wedding' then
			tags['shop'] = 'clothes'
			tags['clothes'] = 'bridal'
		elseif is_in(tags['shop'], tradeshop_tags) then
			tags['shop'] = 'trade'
		elseif is_in(tags['shop'], sportshop_tags) then
			tags['shop'] = 'sports'		
		-- Remove double tagging for known rental types
		elseif (tags["shop"] == "rental") and is_in(tags["amenity"], known_rentals) then
			tags["shop"] = nil
		elseif tags['shop'] == 'chair' then
			tags['shop'] = 'furniture'
		elseif tags['shop'] == 'decorating' then
			tags['shop'] = 'paint'
		elseif tags['shop'] == 'flooring' then
			tags['shop'] = 'carpet'
		elseif tags['shop'] == 'car_accessories' then
			tags['shop'] = 'car_parts'
		elseif (tags['shop'] == 'pet_supplies') or (tags['shop'] == 'pet_food') then
			tags['shop'] = 'pet'
		elseif (tags['shop'] == 'curtains') or (tags['shop'] == 'linen') then
			tags['shop'] = 'fabric'
		-- Bottle shop arguably more interesting as shop=alcohol than whether or not it has a bar
		elseif (tags["shop"] == 'alcohol') and ((tags['amenity'] == 'bar') or (tags['amenity'] == 'pub')) then
			tags['shop'] = nil
		end
	end
	
	-- Normalise swimming pools. Outdoor pools rendered as water areas
	if (tags['leisure'] == 'swimming_pool') and (tags['indoor'] == 'yes') then
		tags['leisure'] = 'sports_centre'
		tags['sport'] = 'swimming'
	end
	
	-- No good tagging for outdoor centre. 
	if tags['amenity'] == 'outdoor_education_centre' then
		tags['amenity'] = 'community_centre'
	end

	if (tags['waterway'] == 'sluice_gate') or (tags['waterway'] == 'floating_barrier') then
		tags['waterway'] = 'weir'
	end

	-- Retagging for renderer!
	if (tags['man_made'] == 'pumping_station') and (tags['building'] ~= nil) then
		tags['made_made'] = 'wastewater_plant'
	end
	
	-- historic=monument takes precedence over man_made=tower
    if (tags["man_made"] == "tower") and (tags["historic"] == "monument") then
		tags["man_made"] = nil
    end
	
		
    return 0, tags
end

function string:endswith(suffix)
    return self:sub(-#suffix) == suffix
end

-- Filtering on nodes
function filter_tags_node (keyvalues, numberofkeys)

-- Move filter_tags_generic to top for consistency with ways and relations
    local filter, keyvalues = filter_tags_generic(keyvalues)
    if filter == 1 then
        return 1, keyvalues
    end

	-- Suppress the dubious natural=hill tag
	if keyvalues["natural"] == "hill" then
		keyvalues["natural"] = "peak"
	elseif keyvalues['natural'] == 'shake_hole' then
		keyvalues["natural"] = 'sinkhole'
	end

	-- Render jersey barrier as block if node
--	if keyvalues['barrier'] == 'jersey_barrier' then
--		keyvalues['barrier'] = 'block'
--	end

-- Suppress cairn / survey_point etc. if coincides with peak
	if (keyvalues['natural'] == 'peak') and keyvalues['man_made'] then
		if keyvalues['man_made'] == 'survey_point' then
			keyvalues['survey_point'] = 'yes'
		end
		keyvalues['man_made'] = nil
	end
	
	if (keyvalues['historic'] == 'market_cross') or (keyvalues['historic'] == 'cross') then
		keyvalues['man_made'] = 'cross'
	end
	
-- Suppress tree if coincides with marker (both appear from z17)
-- Note that overlap of name/ref is handled by scoring in project.mml
	if (keyvalues['orienteering'] == 'marker') and (keyvalues['natural'] == 'tree') then
		keyvalues['natural'] = nil
	end
	
-- Almost certainly mistake to have both defib and phone
	if (keyvalues['emergency'] == 'defibrillator') and (keyvalues['amenity'] == 'telephone') then
		keyvalues['amenity'] = nil
	end
	
-- Separate out grouse butt from generic hunting stand
	if keyvalues['hunting_stand'] == 'grouse_butt' then
		keyvalues['amenity'] = 'grouse_butt'
	end

-- If no height given, set as 'medium'-sized chimney
    if keyvalues['height'] == nil then
        if keyvalues['man_made'] == 'chimney' then
            keyvalues['height'] = '40'
        end
    end
	
	-- For some reason NCN mileposts often lack guidepost tagging
	if keyvalues['ncn_milepost'] and (keyvalues['tourism'] == nil) then
		keyvalues['tourism'] = 'information'
		keyvalues['information'] = 'guidepost'
	end

-- Mark transitions, including distribution transformers, with larger pole
	if keyvalues['power'] == 'pole' then
		if (keyvalues['location:transition'] == 'yes') or (keyvalues['transformer'] == 'distribution') then
			keyvalues['power'] = 'transitionpole'
		end
	end
	
	if (keyvalues['man_made'] == 'water_tap') and (keyvalues['drinking_water'] == 'yes') and (keyvalues['amenity'] == nil) then
		keyvalues['amenity'] = 'drinking_water'
	end
	
	-- Kill off weird isolated_dwelling thing
	if keyvalues["place"] == "isolated_dwelling" then
		if keyvalues["name"] and keyvalues["name"]:endswith(" Farm") then
			keyvalues["place"] = "farm"
		else
			keyvalues["place"] = "locality"
		end
	end
		
    if keyvalues["highway"] == "passing_place" then
		keyvalues["highway"] = "turning_circle"
	end
		
-- Best efforts at updating pipeline marker tagging (post vs plate has no impact on rendering)
	if (keyvalues['pipeline'] == 'marker') and keyvalues['substance'] then
		if (keyvalues['support'] == 'wall_mounted') or (keyvalues['support'] == 'ground') then
			keyvalues['marker'] = 'plate'
		else
			keyvalues['marker'] = 'post'
		end
		keyvalues['utility'] = keyvalues['substance']
	end
	
	-- Unnamed farm shop selling distinct produce better indicating as vending_machine
   if (keyvalues["shop"] == "farm" ) and (keyvalues["name"] == nil) and keyvalues["produce"] then
      keyvalues["amenity"] = "vending_machine"
      keyvalues["vending"] = keyvalues["produce"]
      keyvalues["shop"] = nil
   end
   
    -- Render memorial benches as benches not memorials
    if keyvalues["memorial"] == "bench" then
		keyvalues['amenity'] = 'bench'
		keyvalues['historic'] = nil
	end
 	
	-- Kill off details like route markers on stiles etc. in favour of rendering barrier
	if keyvalues['barrier'] then
		if keyvalues['tourism'] == 'information' then
			keyvalues['tourism'] = nil
			keyvalues['information'] = nil
		end
		-- Treat locked=yes as shorthand for access=no
		if (keyvalues['locked'] == 'yes') and (keyvalues['access'] == nil) then
			keyvalues['access'] = 'no'
		end	
	end
	
end

-- Filtering on relations
function filter_basic_tags_rel (keyvalues, numberofkeys)
    -- Filter out objects that are filtered out by filter_tags_generic
    local filter, keyvalues = filter_tags_generic(keyvalues)
    if filter == 1 then
        return 1, keyvalues
    end

    -- Filter out all relations except route, multipolygon and boundary relations
    if ((keyvalues["type"] ~= "route") and (keyvalues["type"] ~= "multipolygon") and (keyvalues["type"] ~= "boundary")) then
        return 1, keyvalues
    end

    return 0, keyvalues
end

-- These will also be treated as 'bad'
local poor_visibility_tags = { 'no', 'none', 'nil', 'horrible', 'very_bad', 'poor'}
-- service or unclassified road with these surface tags will be demoted to (grade4) track
local poor_surface_tags = { 'dirt', 'earth', 'ground' }
-- Positively bad surfaces
local bad_surface_tags = { 'mud' }
-- likely to be decent surfaces for walking -> grade2
local goodunsealed_surface_tags = { 'unpaved', 'compacted', 'fine_gravel', 'cobblestone', 'woodchips', 'stepping_stones', 'rock', 'grass_paver' }
-- excellent is defined for walking rather than cycling!
local excellent_surface_tags = { 'asphalt', 'concrete', 'paved', 'paving_stones', 'sett', 'metal'}
-- other surfaces, such as grass and sand, default to grade3
local private_access_tags = { 'private', 'permit', 'delivery', 'forestry', 'military' }
--- Note not trying to distinguish between restricted_byway and byway
--- Also treating ORPAs as BOATs
local BOAT_alternative_tags = { 'byway', 'public_byway', 'orpa', 'unclassified_country_road', 'unclassified_county_road', 'restricted_byway', 'unclassified_highway' }
local PRoW_designation_tags = { 'byway_open_to_all_traffic', 'public_footpath', 'public_bridleway'}
--local keepbridges = { 'cycleway', 'path', 'bridleway' }
local access_tags = { 'foot', 'horse', 'bicycle' }
local pathtypes = { 'cycleway', 'path', 'bridleway' }
local suppress_construction = { 'raceway', 'pedestrian', 'footway', 'cycleway', 'path', 'bridleway', 'steps' }
-- synonyms for two sided embankment / cutting
local cuttingtypes = { 'yes', 'both', 'two_sided' }
local allow_lit = { 'service', 'pedestrian', 'footway', 'steps' }
local notopen_tags = { 'destination', 'private', 'no' }

-- Specific filtering on highways
function filter_highway (keyvalues)

	if keyvalues['highway'] == 'construction' then
		if is_in(keyvalues['construction'], suppress_construction) then
			return 1, keyvalues
		end
		if keyvalues['construction'] == 'living_street' then
			keyvalues['construction'] = 'residential'
		elseif keyvalues['construction'] == nil then
			keyvalues['construction'] = 'unclassified'
		end
	end

	-- Treat highway = escape as case of highway = service
	if keyvalues['highway'] == 'escape' then
		keyvalues['highway'] = 'service'
	end
-- Demote narrow / unpaved roads to give better visual indication of importance / traffic levels 
	if ((keyvalues['junction'] == nil) and (keyvalues['oneway'] == nil)) or (keyvalues['surface'] == 'unpaved') then 
		if keyvalues['lanes'] == 1 then
			if keyvalues['highway'] == 'unclassified' then
				keyvalues['highway'] = 'service'
			elseif keyvalues['highway'] == 'tertiary' then
				keyvalues['highway'] = 'unclassified'
			end
		elseif (keyvalues['lane_markings'] == 'no') and (keyvalues['highway'] == 'tertiary') then
			keyvalues['highway'] = 'unclassified'
		end
	end
-- Mark driveways as private if reasonable
	if (keyvalues['service'] == 'driveway') and (keyvalues['designation'] == nil) and (keyvalues['access'] == nil) then
		keyvalues['access'] = 'private'
	end
	
	-- Consolidate tags relating to poor trail visibility (these will be desaturated)
	if is_in(keyvalues['trail_visibility'], poor_visibility_tags) or (keyvalues['foot:physical'] == 'no') or (keyvalues['overgrown'] == 'yes') then
		keyvalues['trail_visibility'] = 'bad'
	end

-- Consolidate access tags
-- Note the SQL query also looks to "compact" private -> no
-- Keep distinction between private and no for now, since these have different significance for PRoW
-- First - lose "access=designated", which is meaningless.
-- Keep permissive for time being. Remove customers access to reduce clutter (more logically indicated elsewhere)
	if keyvalues['access'] then
		if (keyvalues['access'] == 'designated') or (keyvalues['access'] == 'customers') then
			keyvalues['access'] = nil
		elseif is_in(keyvalues['access'], private_access_tags) then
			keyvalues['access'] = 'private'
		end
	end

	-- Normalise BOAT designation
	if is_in(keyvalues['designation'], BOAT_alternative_tags) then
		keyvalues['designation'] = 'byway_open_to_all_traffic'
	elseif keyvalues['designation'] == 'permissive_footpath' then
		keyvalues['foot'] = 'permissive'
	elseif keyvalues['designation'] == 'permissive_bridleway' then
		keyvalues['foot'] = 'permissive'
		keyvalues['bicycle'] = 'permissive'
		keyvalues['horse'] = 'permissive'
    end
				
	-- Very difficult to render highways that overlap with (disused) railways. Kill railway tag
	keyvalues['railway'] = nil

    -- Prioritise any explicit footway surface
	if keyvalues['footway:surface'] then
		keyvalues['surface'] = keyvalues['footway:surface']
	end

	-- Assume building passages / indoor routes are paved in absence of contrary information
	if ((keyvalues['tunnel'] == 'building_passage') or (keyvalues['indoor'] == 'yes')) and (keyvalues['surface'] == nil) then
		keyvalues['surface'] = 'paved'
	end
	
	-- Normalise covered tag, e.g. covered=arcade
	if keyvalues['covered'] then
		if keyvalues['covered'] == 'no' then
			keyvalues['covered'] = nil
		else
			keyvalues['covered'] = 'yes'
		end
	end
	if keyvalues['indoor'] == 'yes' then
		keyvalues['covered'] = 'yes'
	end
	
	local surface = keyvalues['surface']
	if surface then
		if (surface == 'cobblestone:flattened') or (surface == 'unhewn_cobblestone') then
			surface = 'cobblestone'
		elseif (surface == 'concrete:plates') or (surface == 'concrete:lanes') then
			surface = 'concrete'
		elseif surface == 'chipseal' then
			surface = 'asphalt'
		elseif surface == 'pebblestone' then
			surface = 'compacted'
		end
	end
	local isexcellentsurface = is_in(surface, excellent_surface_tags)
	
	-- assume footway = surface or adopted_footway has excellent surface
	-- Remove name from footway=sidewalk (we expect it to be rendered via the road that this is a sidewalk for)
	if surface == nil then
		if (keyvalues['footway'] == 'sidewalk') or (keyvalues['is_sidepath'] == 'yes') or (keyvalues['designation'] == 'adopted_footway') or (keyvalues['highway'] == 'service') or (keyvalues['highway'] == 'cycleway') or keyvalues['bridge'] then
			isexcellentsurface = true
		end
	end
	if keyvalues['footway'] == 'sidewalk' then			
		keyvalues['name'] = nil
	end
	
--	local width = tonumber(keyvalues['width']) or 0
--	if keyvalues['highway'] == 'footway' and (keyvalues['trail_visibility'] == nil) then
--		if width >= 2 then	
--			keyvalues['trail_visibility'] = 'excellent'
--		elseif (keyvalues['informal'] == 'yes') and (surface == nil) then
--			keyvalues['trail_visibility'] = 'bad'
--		end
--	end
	
	-- Create a tracktype based on surface if none exists
	-- Default tracktype is 3 for track, and 1 for service
	if keyvalues['tracktype'] == nil then
		if isexcellentsurface then
			keyvalues['tracktype'] = 'grade1'
		elseif is_in(surface, bad_surface_tags) or (keyvalues['trail_visibility'] == 'bad') then
			keyvalues['tracktype'] = 'grade5'
		elseif is_in(surface, goodunsealed_surface_tags) then
			keyvalues['tracktype'] = 'grade2'
		elseif is_in(surface, poor_surface_tags) or (keyvalues['informal'] == 'yes') then
			keyvalues['tracktype'] = 'grade4'
		else
			keyvalues['tracktype'] = 'grade3'
		end
	end
		
-- Consolidate access tags: designated->yes
 
    for index, access_tag in ipairs (access_tags) do
--		if keyvalues[access_tag] == 'private' then
--			keyvalues[access_tag] = 'no'
--		else
		if keyvalues[access_tag] == 'designated' then
			keyvalues[access_tag] = 'yes'
		end
    end
 
 	local isPROW = is_in(keyvalues['designation'], PRoW_designation_tags)

   -- Remove private access if PRoW and not explicitly tagged with foot=no
   -- Does not affect access = no (which generally means way is barred)
   if ((keyvalues['access'] == 'private') or (keyvalues['access'] == 'destination')) and isPROW and (keyvalues['foot'] ~= 'no') then
		keyvalues['access'] = nil
	end
	
	-- Kill off track and extend service to include tracktype
	if keyvalues['highway'] == 'track' then
	-- Kill off lit = no tagging as wouldn't expect tracks to be lit
		if keyvalues['lit'] == 'no' then
			keyvalues['lit'] = nil
		end
		keyvalues['highway'] = 'service'
		-- Kill any sidewalk tag from tracks
		keyvalues['sidewalk'] = nil
	elseif keyvalues['highway'] == 'footway' then
	-- For pedestrian-focussed routes, ignore any bicycle access (prevents 'upgrade' to cycleway)
		keyvalues['bicycle'] = nil
		if keyvalues['tracktype'] ~= 'grade1' then
			keyvalues['highway'] = 'path'
		end
	end
	
	-- Treat highway=busway as highway=service
	-- Normalisation of access tags not strictly necessary as will not affect rendering
	if keyvalues['highway'] == 'busway' then
		keyvalues['highway'] = 'service'
		if keyvalues['motor_vehicle'] == nil then
			keyvalues['motor_vehicle'] = 'no'
		end
		if keyvalues['bus'] == nil then
			keyvalues['bus'] = 'yes'
		end
	end
	
	-- Explicitly set foot = no if accessed blocked (to avoid multiple checks when styling)
	if keyvalues['access'] == 'no' then
		keyvalues['foot'] = 'no'
	end
	if keyvalues['highway'] == 'path' then
	-- Upgrade paths with cycle access (doesn't apply to ways originally marked as footway)
		if keyvalues['bicycle'] == 'yes' then
			keyvalues['highway'] = 'cycleway'
		elseif (keyvalues['designation'] == 'public_bridleway') or (keyvalues['designation'] == 'permissive_bridleway') then
			keyvalues['highway'] = 'bridleway'
		end
	end

	-- Unless other access set, then tag towpaths as foot=permissive
	if (keyvalues['towpath'] == 'yes') and (keyvalues['designation'] == nil) and (keyvalues['foot'] == nil) then
		keyvalues['foot'] = 'permissive'
	end

	if (keyvalues['highway'] == 'path') or (keyvalues['highway'] == 'footway') then
	-- Normalise access tagging (destination only access is effectively foot = private/no)
		if (keyvalues['foot'] ~= 'yes') and is_in(keyvalues['access'], notopen_tags) then
			keyvalues['foot'] = 'no'
		end
	-- Use path styling for forbidden footways
		if keyvalues['foot'] == 'no' then
			keyvalues['highway'] = 'path'
		end
	end
	
	-- permissive only relevant to highway=path. Normalise rest
	-- similarly, segregated=yes implies foot=yes
	if (keyvalues['highway'] ~= 'path') and (keyvalues['foot'] == 'permissive') then
		keyvalues['foot'] = 'yes'
	elseif (keyvalues['highway'] == 'cycleway') and (keyvalues['segregated'] == 'yes') then
		keyvalues['foot'] = 'yes'
	end
	
	if is_in(keyvalues['highway'], pathtypes) and keyvalues['bridge'] == nil then
		if is_in(keyvalues['embankment'], cuttingtypes) then
			keyvalues['bridge'] = 'embankment'
		elseif is_in(keyvalues['cutting'], cuttingtypes) then
			keyvalues['bridge'] = 'cutting'
		end
	end

	if keyvalues['sidewalk'] == 'none' then
		keyvalues['sidewalk'] = 'no'
	elseif (keyvalues['sidewalk:left'] == 'yes') or (keyvalues['sidewalk:right'] == 'yes') then
		keyvalues['sidewalk'] = 'yes'
	end
	-- Flag if verges present. This will disable a road being flagged as dangerous for walking
	if (keyvalues['verge'] ~= 'no') and (keyvalues['verge'] ~= nil) and (keyvalues['sidewalk'] == 'no') then
		keyvalues['sidewalk'] = 'verge'
	end
	
	-- Kill remaining designation tags to simplify rendering
	if keyvalues['designation'] and not isPROW then
		keyvalues['designation'] = nil
	end
	
	-- For highway types where oneway:foot could be different, use oneway:foot 
	if (keyvalues['oneway:foot'] ~= nil) and ((keyvalues['highway'] == 'pedestrian') or (keyvalues['highway'] == 'cycleway')) then
		keyvalues['oneway'] = keyvalues['oneway:foot']
	end
	
	-- Kill ref tags on bridges to stop shields appearing
	if keyvalues['bridge'] then
		keyvalues['ref'] = nil
	end
	
	-- Kill off lit tags unless on roads of interest
	if keyvalues['lit'] and not is_in(keyvalues['highway'], allow_lit) then
		keyvalues['lit'] = nil
	end
	
	return 0, keyvalues
end

local religionbuilding_tags = { 'church', 'mosque' }
local lightrail_tags = { 'miniature', 'tram', 'funicular', 'light_rail', 'narrow_gauge'}
local gate_tags = { 'wicket_gate', 'hampshire_gate', 'lych_gate' }

-- Filtering on ways
function filter_tags_way (keyvalues, numberofkeys)
    local filter = 0  -- Will object be filtered out?
    local polygon = 0 -- Will object be treated as polygon?

    -- Filter out objects that are filtered out by filter_tags_generic
    filter, keyvalues = filter_tags_generic(keyvalues)
    if filter == 1 then
        return filter, keyvalues, polygon, roads
    end
	
    -- Normalise leisure=horse_riding on way to sports_centre + equestrian
	if keyvalues['leisure'] == 'horse_riding' then
		keyvalues['leisure'] = 'sports_centre'
		keyvalues['sport'] = 'equestrian'
	end
	
-- Stop wall being rendered if sheepfold symbol used (not ideal for complex structures)
	if keyvalues['man_made'] == 'sheepfold' then
		keyvalues['barrier'] = nil
	end
	
	if keyvalues['tourism'] == 'holiday_park' then
		keyvalues['landuse'] = 'residential'
	end

	-- Consolidate name:left / right
	-- Probably don't need this for walking map
	if (keyvalues['name'] == nil) and (keyvalues['name:left'] ~= nil) and (keyvalues['name:right'] ~= nil) then
		keyvalues['name'] = keyvalues['name:left'] .. " / " .. keyvalues['name:right']
	end

-- Note AJT-style uses pathnarrow
	if (keyvalues['highway'] == nil) and ((keyvalues['golf'] == 'path') or (keyvalues['golf'] == 'cartpath')) then
		keyvalues['highway'] = 'path'
	end
	
-- A bridge is a bridge is a bridge ...
	if keyvalues['bridge'] then
		keyvalues['bridge'] = 'yes'
	end
	
	-- In the absence of specific icons, at least render leisure=bandstand etc. as buildings
	if (keyvalues['leisure'] == 'bandstand') or (keyvalues['animal'] == 'horse_walker') then
		keyvalues['building'] = 'roof'
	end
		
	-- Consolidated highway = rest_area with roadside parking
	if keyvalues['highway'] then
		if keyvalues['highway'] == 'rest_area' then
			keyvalues['highway'] = nil
			keyvalues['amenity'] = 'parking'
		else
			filter, keyvalues = filter_highway(keyvalues)
			if filter == 1 then
				return filter, keyvalues, polygon, roads(keyvalues)
			end
		end
	end
	
	if (keyvalues["man_made"] == "goods_conveyor") then
		keyvalues["railway"] = "miniature"
    end
   
	if keyvalues['natural'] == 'tree_group' then
		keyvalues['natural'] = 'wood'
	end

-- Don't render railway bridges.
-- Note that paths on dismantled railways are handled as highways
-- Note that disused:railway etc. not handled, since these all seem to be dual-tagged with railway=disused
	local railwaytype = keyvalues['railway']
	if railwaytype then
		keyvalues['bridge'] = nil
	-- Consolidate railway types
		if railwaytype == 'abandoned' then
			keyvalues['railway'] = 'dismantled'
		elseif (railwaytype == 'monorail') or (railwaytype == 'preserved') then
			keyvalues['railway'] = 'rail'
	-- Consolidate on tram as this is handled as special case
		elseif is_in(railwaytype, lightrail_tags) then
			keyvalues['railway'] = 'tram'
		end
	-- Consolidate tunnels
		if keyvalues['tunnel'] or (keyvalues['covered'] == 'yes') then
			keyvalues['tunnel'] = 'yes'
		end
	end
	
	-- Consolidate church buildings so can filter out small (active) churches at low zoom
	if keyvalues['building'] == 'chapel' then
		keyvalues['building'] = 'church'
	end
	if (keyvalues['building'] == 'yes') and (keyvalues['amenity'] == 'place_of_worship') then
		if keyvalues['religion'] == 'christian' then
			keyvalues['building'] = 'church'
		elseif keyvalues['religion'] == 'muslim' then
			keyvalues['building'] = 'mosque'		
		end
	elseif is_in(keyvalues['building'], religionbuilding_tags) and (keyvalues['amenity'] ~= 'place_of_worship') then
	-- Hide religious buildings that are not active i.e. will not be tagged with place of worship
		keyvalues['building'] = 'yes'
	end
	
	-- Remove building tag for ways with other formatting that would be otherwise obscured (NB leisure now handled differently)
	if keyvalues['building'] and (keyvalues['power'] == 'substation') then
		keyvalues['building'] = nil
	end
	
	-- Retag courtyards or squares into pedestrian areas
	if ((keyvalues['place'] == 'square') or (keyvalues['man_made'] == 'courtyard')) and (keyvalues['highway'] == nil) then
		keyvalues['highway'] = 'pedestrian'
		keyvalues['area'] = 'yes'
	end
		
	-- Promote bridge/tunnel:name if possible
	if keyvalues['bridge:name'] and (keyvalues['name'] == nil) then
		keyvalues['name'] = keyvalues['bridge:name']
	end
	-- Since there is no man_made=tunnel rendering, give high priority to tunnel:name
	if keyvalues['tunnel'] and keyvalues['tunnel:name'] then
		keyvalues['name'] = keyvalues['tunnel:name']
	end
	
	if (keyvalues['ruins:historic'] == 'citywalls') or (keyvalues['ruins:barrier'] == 'city_wall') then
	-- Note this will squash any existing (modern) barrier, which is the Right Thing
		keyvalues['barrier'] = 'ruined_city_wall'
	elseif keyvalues['historic'] == 'citywalls' then
		keyvalues['historic'] = nil
		keyvalues['barrier'] = 'city_wall'
	end
	
--	if keyvalues['barrier'] == 'jersey_barrier' then
--		keyvalues['barrier'] = 'wall'
	if keyvalues['barrier'] == 'haha' then
		keyvalues['barrier'] = 'retaining_wall'
	-- Promote castle walls to 'city_wall' for thicker rendering
	elseif (keyvalues['barrier'] == 'wall') and (keyvalues['wall'] == 'castle_wall') then
		keyvalues['barrier'] = 'city_wall'
	end
	if (keyvalues['barrier'] == 'city_wall') and (keyvalues['ruins'] == 'yes') then
		keyvalues['barrier'] = 'ruined_city_wall'
	-- Introduce general category of ruined barrier, after having considered special case for ruins of city wall
	elseif keyvalues['abandoned:barrier'] or keyvalues['ruins:barrier'] or (keyvalues['barrier'] and (keyvalues['ruins'] == 'yes')) then
		keyvalues['barrier'] = 'ruins'
	end 
	
	-- OK, the vallum on Hadrian's Wall is a bit more than a ditch, but still useful!
	if keyvalues['historic'] == 'vallum' then
		keyvalues['barrier'] = 'ditch'
	end
		
	-- Normalise residential caravan site to new landuse type
	if (keyvalues['landuse'] == "residential") and (keyvalues['residential'] == 'trailer_park') then
		keyvalues['landuse'] = 'trailer_park'
	elseif ((keyvalues['tourism'] == 'caravan_site') and (keyvalues['static_caravans'] == 'only')) or (keyvalues['tourism'] == 'holiday_park') then
		keyvalues['landuse'] = 'trailer_park'
		keyvalues['tourism'] = nil
	end
	
	-- Treat narrow canal-like waterways as stream
	if (keyvalues["waterway"] == "spillway") or (keyvalues["waterway"] == "fish_pass") or
       ((keyvalues["waterway"] == "canal") and ((keyvalues["usage"] == "headrace") or (keyvalues["usage"] == "tailrace") or (keyvalues["usage"] == "spillway"))) then
		keyvalues["waterway"] = "stream"
	end
	
	if keyvalues['man_made'] == 'gasometer' then
		keyvalues['building'] = 'industrial'
	end
	
	-- render barrier=ditch as intermittent waterway=ditch
    if keyvalues["barrier"] == "ditch" then
       keyvalues["waterway"] = "ditch"
	   keyvalues["intermittent"] = "yes"
       keyvalues["barrier"] = nil
    elseif is_in(keyvalues["barrier"], gate_tags) then
		keyvalues["barrier"] = "gate"
	end
	
	-- render hollow_way as cutting
	if (keyvalues['historic'] == 'hollow_way') and (keyvalues['cutting'] == nil) then
		keyvalues['historic'] = nil
		keyvalues['cutting'] = 'yes'
	end
		
	-- render abandoned graveyards still as graveyards
	if keyvalues['abandoned:amenity'] == 'grave_yard' then
		keyvalues['amenity'] = 'grave_yard'
		keyvalues['abandoned:amenity'] = nil
	end
	
	local natural = keyvalues['natural']
	local wetland = keyvalues['wetland']
	local tidal = keyvalues['tidal']
	
	if natural then
	-- Rationalise beach to sand, mud or shingle (coarse) 
		if (natural == 'beach') or (natural == 'shoal') or (keyvalues['wetland'] == 'tidalflat') then
			if (keyvalues['surface'] == 'sand') or (keyvalues['surface'] == nil) then
				keyvalues['natural'] = 'sand'
			elseif keyvalues['surface'] == 'mud' then
				keyvalues['natural'] = 'mud'
			else
				keyvalues['natural'] = 'shingle'
			end
			if natural ~= 'beach' then
				keyvalues['wetland'] = 'partial'
			end
	-- Try to merge natural = wetland into existing natural types overprinted with partial / fully wet symbols
		elseif natural == 'wetland' then
			if (wetland == 'marsh') or (wetland == 'saltmarsh') then
				if tidal == 'yes' then
					keyvalues['wetland'] = 'partial'					
				else
					keyvalues['wetland'] = 'yes'
				end
				if (wetland == 'marsh') or (tidal == 'yes') then
					keyvalues['natural'] = 'scrub'
				end
			elseif wetland == 'reedbed' then
				keyvalues['wetland'] = 'yes'
			elseif wetland == 'wet_meadow' then
				keyvalues['natural'] = nil
				keyvalues['landuse'] = 'meadow'
				keyvalues['wetland'] = 'partial'
				keyvalues['pasture'] = nil
			elseif (wetland == 'swamp') or (wetland == 'mangrove') then
				keyvalues['natural'] = 'wood'
				keyvalues['wetland'] = 'yes'
			elseif (wetland == 'bog') or (wetland == 'fen') then
				keyvalues['wetland'] = 'partial'
				keyvalues['natural'] = 'heath'
			elseif wetland == 'stringbog' then
				keyvalues['wetland'] = 'yes'
				keyvalues['natural'] = 'scrub'
			end
		elseif natural == 'mud' then
			keyvalues['wetland'] = 'partial'
		end
		
		if natural == 'earth_bank' then
			keyvalues['man_made'] = 'embankment'
			keyvalues['natural'] = nil
		end
	end
	
    polygon = isarea(keyvalues)
	
    -- Add z_order column
    keyvalues["z_order"] = z_order(keyvalues)

    return filter, keyvalues, polygon, roads(keyvalues)
end

local major_walking_tags = { 'iwn', 'nwn', 'rwn' }

-- Rather crude. Should break on ; and check components 
function contains(str, test)
	return string.find(str, test)
end


--- Handling for relation members and multipolygon generation
-- @param keyvalues OSM tags, after processing by relation transform
-- @param keyvaluemembers OSM tags of relation members, after processing by way transform
-- @param roles OSM roles of relation members
-- @param membercount number of members
-- @return filter, cols, member_superseded, boundary, polygon, roads
function filter_tags_relation_member (keyvalues, keyvaluemembers, roles, membercount)
    local members_superseded = {}

    -- Start by assuming that this not an old-style MP
    for i = 1, membercount do
        members_superseded[i] = 0
    end

    local type = keyvalues["type"]

    -- Remove type key
    keyvalues["type"] = nil

    -- Filter out relations with just a type tag or no tags
    if next(keyvalues) == nil then
        return 1, keyvalues, members_superseded, 0, 0, 0
    end

    if type == "boundary" or (type == "multipolygon" and keyvalues["boundary"]) then
        keyvalues.z_order = z_order(keyvalues)
        return 0, keyvalues, members_superseded, 1, 0, roads(keyvalues)
    -- For multipolygons...
    elseif (type == "multipolygon") then
        -- Multipolygons by definition are polygons, so we know roads = linestring = 0, polygon = 1
        keyvalues.z_order = z_order(keyvalues)
        return 0, keyvalues, members_superseded, 0, 1, 0
    elseif type == "route" then
	
	-- Find walking routes and add fake highway tag so they are picked out
		local network = keyvalues['network']
		if network ~= nil then
			if contains(network, 'lwn') then
				keyvalues['highway'] = 'lwn'
			else
				for _, major_walking in ipairs(major_walking_tags) do
					if contains(network, major_walking) then
						keyvalues['highway'] = 'rwn'
						break
					end
				end
			end
			if (keyvalues['name'] == nil) and keyvalues['ref'] then
				keyvalues['name'] = keyvalues['ref']
			end
		end

		local osmc = keyvalues['osmc:symbol']
		-- Use colour from osmc:symbol if none supplied
		if osmc and (keyvalues['colour'] == nil) then
				i, _ = string.find(osmc, ":")
				if i and (i > 1) then
					keyvalues['colour'] = string.sub(osmc, 1, i-1)
				end
		end
			
        keyvalues.z_order = z_order(keyvalues)
	-- Should add members to line database
        return 0, keyvalues, members_superseded, 1, 0, roads(keyvalues)
    end

    -- Unknown type of relation or no type tag
    return 1, keyvalues, members_superseded, 0, 0, 0
end

--- Check if an object with given tags should be treated as polygon
-- @param tags OSM tags
-- @return 1 if area, 0 if linear
function isarea (tags)
    -- Treat objects tagged as area=yes polygon, other area as no
    if tags["area"] then
        return tags["area"] == "yes" and 1 or 0
    end

   -- Search through object's tags
    for k, v in pairs(tags) do
        -- Check if it has a polygon key and not a linestring override, or a polygon k=v
        for _, ptag in ipairs(polygon_keys) do
            if k == ptag and v ~= "no" and not (linestring_values[k] and linestring_values[k][v]) then
                return 1
            end
        end

        if (polygon_values[k] and polygon_values[k][v]) then
            return 1
        end
    end
    return 0
end

function is_in (needle, haystack)
-- Short-curcuit
	if needle == nil then
		return false
	end
    for index, value in ipairs (haystack) do
        if value == needle then
            return true
        end
    end
    return false
end

--- Normalizes layer tags
-- @param v The layer tag value
-- @return An integer for the layer tag
function layer (v)
    return v and string.find(v, "^-?%d+$") and tonumber(v) < 100 and tonumber(v) > -100 and v or nil
end
