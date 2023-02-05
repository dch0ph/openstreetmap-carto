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
    'comment',
    'fixme',
	'FIXME',
    -- Tags generally dropped by editors, not otherwise covered
    'created_by',
    'odbl',
    -- Lots of import tags
    -- EUROSHA (Various countries)
    'project:eurosha_2012',

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
-- Note that living_street, road, track and footway are redistributed to other highway types
        living_street   = {z = 320, roads = false},
        pedestrian      = {z = 310, roads = false},
        raceway         = {z = 300, roads = false},
-- Boost link roads otherwise appear underneath pedestrian
        motorway_link   = {z = 335, roads = true},
        trunk_link      = {z = 335, roads = true},
        primary_link    = {z = 335, roads = true},
        secondary_link  = {z = 325, roads = true},
        tertiary_link   = {z = 325, roads = false},
        service         = {z = 150, roads = false},
        track           = {z = 110, roads = false},
-- Fake highway types created from route relations
		rwn             = {z = 110, roads = false},
		lwn             = {z = 110, roads = false},
        path            = {z = 100, roads = false},
        footway         = {z = 100, roads = false},
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
local mine_tags = { 'mine', 'mine_shaft', 'mineshaft', 'adit' }

--- If tagged with disused, turn into 'historic=yes'

--- Generic filtering of OSM tags
-- @param tags Raw OSM tags
-- @return Filtered OSM tags
function filter_tags_generic(tags)
    -- Short-circuit for untagged objects
    if next(tags) == nil then
        return 1, {}
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

   -- Filter out objects that have no tags after deleting
    if next(tags) == nil then
        return 1, {}
    end

	--- Fudge disused status into historic = yes
	--- Combine mine, mineshaft and adit (often poorly distinguished)
	if tags['disused:man_made'] then
		tags['man_made'] = tags['disused:man_made']
		tags['historic'] = 'yes'
	elseif tags['disused:landuse'] then
		tags['landuse'] = tags['disused:landuse']
		tags['historic'] = 'yes'
	end
	if tags['man_made'] == 'adit' then
		tags['man_made'] = 'mineshaft'
	end
	if tags['disused'] == 'yes' then
		tags['historic'] = 'yes'
	end
	if is_in(tags['historic'], mine_tags) then
		tags['man_made'] = 'mineshaft'
		tags['historic'] = 'yes'
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
		if tags['leaf_type'] ~= nil then
			tags['leaf_type'] = 'needleleaved'  
		elseif tags['leaf_type'] == 'broadleaved' then
			tags['landuse'] = nil
			tags['natural'] = 'wood'
		end
	end
	if (tags['landuse'] == 'meadow') and (tags['meadow'] == 'pasture') then
	-- Fake new landuse to distinguish animal grazing
		tags['landuse'] = 'pasture'
	end
	if (tags['natural'] == 'wood') and (tags['leaf_type'] == 'needleleaved') then
		tags['natural'] = nil
		tags['landuse'] = 'forest'
	end
	
	-- Merge hospital
	if tags['healthcare'] == 'hospital' then
		tags['amenity'] = 'hospital'
	end

-- Bodge lack of rendering of dedicated sports hall
	if tags['leisure'] == 'sports_hall' then
		tags['leisure'] = 'sports_centre'
	end

    -- Convert layer to an integer
    tags['layer'] = layer(tags['layer'])

	-- If name does not exist but name:en does, use it.	
    if (tags['name'] == nil) and (tags['name:en'] ~= nil ) then
		tags['name'] = tags['name:en']
    end
	

-- Render national parks and AONBs as such no matter how they are tagged.
	if (( tags["boundary"]      == "protected_area"                      ) and
       (( tags["designation"]   == "national_park"                      )  or 
        ( tags["designation"]   == "area_of_outstanding_natural_beauty" )  or
        ( tags["designation"]   == "Area of Outstanding Natural Beauty" )  or
        ( tags["protect_class"] == "5"                                  ))) then
      tags["boundary"] = "national_park"
   end

	-- Normalise use of common
	if (tags['designation'] == 'common') and (tags['leisure'] ~= nil) then
		tags['leisure'] = 'common'
		tags['amenity'] = nil
	end

	if tags['ruins:building'] or tags['abandoned:building'] then
		tags['building'] = 'ruins'
	elseif tags['building'] and ((tags['ruined'] == 'yes') or (tags['ruins'] == 'yes')) then
		tags['building'] = 'ruins'
	end
	
	-- Create place=farm if farmyard is named. Creates a higher priority (and uniform) label for farms
	if (tags['landuse'] == 'farmyard') and (tags['name'] ~= nil) then
		tags['place'] = 'farm'
	end
	
	-- Try to strip leading The from pub/cafe names if results has >1 word
	-- e.g. will shorten to "Rat and Ratchet" but not change "The Rat"
	if ((tags['amenity'] == 'pub') or (tags['amenity'] == 'cafe')) and tags['name'] then
		stripname = string.match(tags['name'], "^The (.*)")
		if stripname and string.find(stripname, " ") then
			tags['name'] = stripname
		end
	end
		
    return 0, tags
end

-- Filtering on nodes
function filter_tags_node (keyvalues, numberofkeys)

-- Move filter_tags_generic to top for consistency with ways and relations
    local filter, keyvalues = filter_tags_generic(keyvalues)
    if filter == 1 then
        return 1, keyvalues
    end

-- Suppress cairn if coincides with peak
	if (keyvalues['natural'] == 'peak') and (keyvalues['man_made'] == 'cairn') then
		keyvalues['man_made'] = nil
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

-- Mark transitions, including distribution transformers, with larger pole
	if keyvalues['power'] == 'pole' then
		if (keyvalues['location:transition'] == 'yes') or (keyvalues['transformer'] == 'distribution') then
			keyvalues['power'] = 'transitionpole'
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
-- service or unclassified road with these surface tags will be demoted to track
local bad_surface_tags = { 'dirt', 'earth' }
local hardunsealed_surface_tags = {  'unpaved', 'compacted', 'fine_gravel', 'cobblestone' }
-- excellent is defined for walking rather than cycling!
local excellent_surface_tags = { 'asphalt', 'concrete', 'paved', 'paving_stones', 'sett' }
local private_access_tags = { 'private', 'permit', 'delivery', 'forestry', 'military' }
--- Note not trying to distinguish between restricted_byway and byway
--- Also treating ORPAs as BOATs
local BOAT_alternative_tags = { 'byway', 'public_byway', 'orpa', 'unclassified_country_road', 'unclassified_county_road', 'restricted_byway', 'unclassified_highway' }
local PRoW_designation_tags = { 'byway_open_to_all_traffic', 'public_footpath', 'public_bridleway'}
--local keepbridges = { 'cycleway', 'path', 'bridleway' }
local access_tags = { 'foot', 'horse', 'bicycle' }
local pathtypes = { 'cycleway', 'path', 'bridleway' }
--local bridges = { 'cantilever', 'movable', 'trestle', 'viaduct' }
-- Note that customers and private have been rationalised to destination and private respectively
local isprivate_keys = { 'no', 'destination' }

-- Specific filtering on highways
function filter_highway (keyvalues)

-- Suppress generic road and living_street
	if keyvalues['highway'] == 'living_street' then
		keyvalues['highway'] = 'residential'
	elseif keyvalues['highway'] == 'road' then
		keyvalues['highway'] = 'unclassified'
	end
-- Demote narrow unclassified road to service road 
	if (keyvalues['highway'] == 'unclassified') and (keyvalues['lanes'] == 1) then
		keyvalues['highway'] = 'service'
-- Mark driveways as private if reasonable
	elseif (keyvalues['service'] == 'driveway') and (keyvalues['designation'] == nil) and (keyvalues['access'] == nil) then
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
-- Keep permissive for time being. Merge customers -> destination
	if keyvalues['access'] == 'designated' then
		keyvalues['access'] = nil
	elseif keyvalues['access'] ~= nil then
		if is_in(keyvalues['access'], private_access_tags) then
			keyvalues['access'] = 'private'
		elseif keyvalues['access'] == 'customers' then
			keyvalues['access'] = 'destination'
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
	local isPROW = is_in(keyvalues['designation'], PRoW_designation_tags)
	
	-- This is a bodge to keep the XML size under 10 Mb. Force overall access = permissive for foot = permissive to be rendered
	if (keyvalues['foot'] == 'permissive') and (keyvalues['designation'] == nil) then
		keyvalues['designation'] = 'permissive_footpath'
	end
	
	-- Filter out driveways unless designated
	if (keyvalues['service'] == 'driveway') and (keyvalues['designation'] ~=nil) then
		return 1, {}
	end
		
	-- Very difficult to render highways that overlap with (disused) railways. Kill railway tag
	keyvalues['railway'] = nil

    -- Prioritise any explicit footway surface
	if keyvalues['footway:surface'] then
		keyvalues['surface'] = keyvalues['footway:surface']
	end
	
	local surface = keyvalues['surface']
	if surface then
		if (surface == 'cobblestone:flattened') or (surface == 'unhewn_cobblestone') then
			surface = 'cobblestone'
		elseif (surface == 'concrete:plates') or (surface == 'concrete:lanes') then
			surface = 'concrete'
		end
	end
	-- local surface = keyvalues['surface']
	local isbadsurface = is_in(surface, bad_surface_tags)
	local isexcellentsurface = is_in(surface, excellent_surface_tags)
	local ishardunsealedsurface = is_in(surface, hardunsealed_surface_tags)
	
	-- assume footway = surface or adopted_footway has excellent surface
	-- Remove name from footway=sidewalk (we expect it to be rendered via the road that this is a sidewalk for).
	if ((keyvalues['footway'] == 'sidewalk') or (keyvalues['designation'] == 'adopted_footway')) and (surface == nil) then
		isexcellentsurface = true
	end
	if keyvalues['footway'] == 'sidewalk' then			
		keyvalues['name'] = nil
	end

		
	local width = tonumber(keyvalues['width']) or 0
	if keyvalues['trail_visibility'] ~= nil then
		if width >= 2 then	
			keyvalues['trail_visibility'] = 'excellent'
		elseif keyvalues['informal'] == 'yes' then
			keyvalues['trail_visibility'] = 'bad'
		end
	end
	
	-- Create a tracktype based on surface if none exists
	-- Default tracktype is 3 for track, and 1 for service
	if keyvalues['tracktype'] == nil then
		if isbadsurface or (keyvalues['trail_visibility'] == 'bad') then
			keyvalues['tracktype'] = 'grade5'
		elseif (keyvalues['highway'] == 'service') or (keyvalues['highway'] == 'cycleway') or isexcellentsurface then
	-- In the absence of other evidence, assume service roads and cycleways are asphalt
			keyvalues['tracktype'] = 'grade1'
		elseif ishardunsealedsurface or (keyvalues['trail_visibility'] == 'excellent') then
			keyvalues['tracktype'] = 'grade2'
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
 
   -- Remove private access if PRoW and not explicitly tagged with foot=no
   -- Does not affect access = no (which generally means way is barred)
   if ((keyvalues['access'] == 'private') or (keyvalues['access'] == 'destination')) and isPROW and (keyvalues['foot'] ~= 'no') then
		keyvalues['access'] = nil
	end
	
	-- Kill off track and extend service to include tracktype
	if keyvalues['highway'] == 'track' then
		keyvalues['highway'] = 'service'
		-- Kill any sidewalk tag from tracks
		keyvalues['sidewalk'] = nil
	-- Kill off footway and treat as minor service road if decent surface present or path if not
	-- In the absence of contrary surface information, highway=footway will be promoted to highway=pedestrian
	elseif keyvalues['highway'] == 'footway' then
		--if ((keyvalues['tracktype'] == 'grade1') or (keyvalues['designation'] == 'adopted_footway')) and not is_in(keyvalues['access'], isprivate_keys) then
		if keyvalues['tracktype'] == 'grade1' then
			keyvalues['highway'] = 'pedestrian'
	-- For pedestrian routes, ignore shared cycleway
			keyvalues['bicycle'] = nil
		else
			keyvalues['highway'] = 'path'
		end
	end
	
	-- Explicitly set foot = no if accessed blocked (to avoid multiple checks when styling)
	if keyvalues['access'] == 'no' then
		keyvalues['foot'] = 'no'
	end
	if keyvalues['highway'] == 'path' then
	-- Upgrade paths with cycle access
		if keyvalues['bicycle'] == 'yes' then
			keyvalues['highway'] = 'cycleway'
		elseif (keyvalues['designation'] == 'public_bridleway') or (keyvalues['designation'] == 'public_bridleway') then
			keyvalues['highway'] = 'bridleway'
		end
	-- Normalise access tagging (destination only access is effectively foot = private)
		if keyvalues['access'] == 'destination' then
			keyvalues['foot'] = 'private'
		end
	end
	
	if is_in(keyvalues['highway'], pathtypes) then
		if keyvalues['embankment'] == 'yes' then
			keyvalues['bridge'] = 'embankment'
		elseif keyvalues['cutting'] == 'yes' then
			keyvalues['bridge'] = 'cutting'
		end
	end

	if keyvalues['sidewalk'] == 'none' then
		keyvalues['sidewalk'] = 'no'
	end
	-- Flag if verges present. This will disable a road being flagged as dangerous for walking
	if (keyvalues['verge'] ~= 'no') and (keyvalues['verge'] ~= nil) and (keyvalues['sidewalk'] == 'no') then
		keyvalues['sidewalk'] = 'verge'
	end
	
	-- Retagging for renderer!
	if keyvalues['man_made'] == 'pumping_station' then
		keyvalues['made_made'] = 'wastewater_plant'
	end
		
	if keyvalues['made_made'] == 'spillway' then
		keyvalues['natural'] = 'water'
	end
	
	return 0, keyvalues
end

local religionbuilding_tags = { 'church', 'mosque' }
local lightrail_tags = { 'miniature', 'tram', 'funicular', 'light_rail', 'narrow_gauge'}

-- Filtering on ways
function filter_tags_way (keyvalues, numberofkeys)
    local filter = 0  -- Will object be filtered out?
    local polygon = 0 -- Will object be treated as polygon?

    -- Filter out objects that are filtered out by filter_tags_generic
    filter, keyvalues = filter_tags_generic(keyvalues)
    if filter == 1 then
        return filter, keyvalues, polygon, roads
    end

-- Stop wall being rendered if sheepfold symbol used (not ideal for complex structures)
	if keyvalues['man_made'] == 'sheepfold' then
		keyvalues['barrier'] = nil
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

	if keyvalues['highway'] then
		filter, keyvalues = filter_highway(keyvalues)
		if filter == 1 then
			return filter, keyvalues, polygon, roads(keyvalues)
		end
	end

-- Don't render railway bridges.
-- Note that paths on dismantled railways are handled as highways
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
	
	-- Remove building tag for ways with other formatting that would be otherwise obscured
	if keyvalues['building'] then
		if (keyvalues['leisure'] == 'sports_centre') or (keyvalues['power'] == 'substation') then
			keyvalues['building'] = nil
		end
	end
		
	-- Promote bridge/tunnel:name if possible
	if (keyvalues['bridge:name'] ~= nil) and (keyvalues['name'] == nil) then
		keyvalues['name'] = keyvalues['bridge:name']
	end
	if (keyvalues['tunnel:name'] ~= nil) and (keyvalues['name'] == nil) then
		keyvalues['name'] = keyvalues['tunnel:name']
	end
	
	-- Introduce general category of ruined barrier
	if keyvalues['abandoned:barrier'] or (keyvalues['barrier'] == 'ruins') or ((keyvalues['barrier'] == 'wall') and (keyvalues['ruins'] == 'yes')) then
		keyvalues['barrier'] = 'ruined'
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
			if is_in(network, major_walking_tags) then
				keyvalues['highway'] = 'rwn'
			elseif contains(network, 'lwn') then
				keyvalues['highway'] = 'lwn'
			end
			if (keyvalues['name'] == nil) and (keyvalues['ref'] ~= nil) then
				keyvalues['name'] = keyvalues['ref']
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
