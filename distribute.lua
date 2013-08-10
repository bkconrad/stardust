-- Distribute
-- This work is released into the public domain
-- Authored by kaen

-- A map of edge names to functions which retrieve that edge from the objects
-- extents
EDGE_MAP = {
  Left   = function(obj) return   extents(obj).minx end,
  Center = function(obj) return ( extents(obj).minx + extents(obj).maxx) / 2 end,
  Right  = function(obj) return   extents(obj).maxx end,
  Bottom = function(obj) return   extents(obj).miny end,
  Middle = function(obj) return ( extents(obj).miny + extents(obj).maxy) / 2 end,
  Top    = function(obj) return   extents(obj).maxy end
}

EDGES = {
}

for k, v in pairs(EDGE_MAP) do
  table.insert(EDGES, k)
end

AXIS_MAP = {
  Left   = "x",
  Center = "x",
  Right  = "x",
  Bottom = "y",
  Middle = "y",
  Top    = "y"
}

function getArgsMenu()
	menu = 	{
		ToggleMenuItem.new("Distribute By", {"Left", "Center", "Right", "Bottom", "Middle", "Top"}, 1, "The relative position of the objects to distribute by")
	}
	return "Distribute", menu
end

-- return the extents of the given object
function extents(object)
	local minx = math.huge
	local miny = math.huge
	local maxx = -math.huge
	local maxy = -math.huge
	local points = object:getGeom()

	if type(points) == "table" then
		for i, p in ipairs(points) do
			minx = math.min(minx, p.x)
			miny = math.min(miny, p.y)
			maxx = math.max(maxx, p.x)
			maxy = math.max(maxy, p.y)
		end
	elseif type(points) == "point" then
    local r = 0

    -- Try to get the radius, but don't worry if you can't
    pcall(function()
      r = object:getRad()
    end)

		minx = points.x - r
		maxx = points.x + r
		miny = points.y - r
		maxy = points.y + r
	end

	return { minx = minx, miny = miny, maxx = maxx, maxy = maxy }
end

-- returns the minimum and maximum position of the given edge for all objects
function edgeExtents(objects, edge)
	local min = math.huge
	local max = -math.huge

	for k, obj in ipairs(objects) do

    -- Call the appropriate function on obj to get the edge position
		local pos = EDGE_MAP[edge](obj)
		min = math.min(min, pos)
		max = math.max(max, pos)
	end

	return { min = min, max = max }
end

-- get the object's midpoint
function midpoint(obj)
	local ext = extents(obj)
	return point.new(ext.minx + (ext.maxx - ext.minx) / 2, ext.miny + (ext.maxy - ext.miny) / 2)
end

function align(obj, pos, edge)
  local offset = pos - EDGE_MAP[edge](obj)
  local axis = AXIS_MAP[edge]
  local geom = obj:getGeom()

  if axis == "x" then
    geom = Geom.translate(geom, offset, 0)
  elseif axis == "y" then
    geom = Geom.translate(geom, 0, offset)
  end

  obj:setGeom(geom)
end

-- get a point representing the object's x and y size
function size(obj)
  local ext = extents(obj)
  return point.new(ext.maxx - ext.minx, ext.maxy - ext.miny)
end

function halfSize(object)
	local geom = object:getGeom()
	local result = point.new(0, 0)
	if type(geom) == "table" then
		local ext = extents(object)
		result = point.new((ext.maxx - ext.minx) / 2, (ext.maxy - ext.miny) / 2)
	elseif type(geom) == "point" then
		local r
		-- check if the object has getRad
		if object.getRad then
			r = object:getRad()
		else
			r = 0
		end
		result = point.new(r, r)
	end
	return result
end

-- returns a sorted table of tables (something like: "{ { ... }, ... }")
-- in order by the specified property. 
function sortTableListByProperty(list, property)
	local result = { list[1] }
	for item, t in ipairs(list) do
		if item ~= 1 then
			local inserted = false
			for i, u in ipairs(result) do
				if u[property] > t[property] then
					table.insert(result, i, t)
					inserted = true
					break
				end
			end
			if not inserted then
				table.insert(result, t)
			end
		end
	end
	return result
end

-- distribute objects using the specified edge
function distribute(objects, edge)
	local ext = edgeExtents(objects, edge)
  local step = (ext.max - ext.min) / (#objects - 1)

	local midpointsTable = { }
	for _, obj in ipairs(objects) do
		local mid = midpoint(obj)
		table.insert(midpointsTable, { x = mid.x, y = mid.y, obj = obj })
	end

  local axis = AXIS_MAP[edge]

	local sortedTable = sortTableListByProperty(midpointsTable, axis)

	for i = 2, #sortedTable - 1 do
    local obj = sortedTable[i].obj
    local pos = ext.min + (i - 1) * step
    align(obj, pos, edge)
	end
end

function main()
	local axis = table.remove(arg, 1)

	local objects = plugin:getSelectedObjects()

	if #objects < 1 then
		return
	end

	distribute(objects, axis)
end   

