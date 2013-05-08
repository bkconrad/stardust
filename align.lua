-- Align
-- This work is released into the public domain
-- Authored by kaen

function getArgsMenu()

	menu = 	{
		ToggleMenuItem.new("Horizontal Alignment", {"Left", "Center", "Right", "Top", "Middle", "Bottom"})
	}

	return "Alignment", menu
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
		local r

		-- check if the object has getRad
		if object.getRad then
			r = object:getRad()
		else
			r = 0
		end

		minx = points.x - r
		maxx = points.x + r
		miny = points.y - r
		maxy = points.y + r
	end

	return { minx = minx, miny = miny, maxx = maxx, maxy = maxy }
end

function mergeExtents(objects)
	local minx = math.huge
	local miny = math.huge
	local maxx = -math.huge
	local maxy = -math.huge

	for k, obj in ipairs(objects) do
		local ext = extents(obj)
		minx = math.min(minx, ext.minx)
		miny = math.min(miny, ext.miny)
		maxx = math.max(maxx, ext.maxx)
		maxy = math.max(maxy, ext.maxy)
	end

	return { minx = minx, miny = miny, maxx = maxx, maxy = maxy }
end

-- get the object's midpoint
function midpoint(obj)
	local ext = extents(obj)
	return point.new(ext.minx + (ext.maxx - ext.minx) / 2, ext.miny + (ext.maxy - ext.miny) / 2)
end

-- set the object's midpoint
function center(object, pos)
	local geom = object:getGeom()
	if type(geom) == "table" then
		local half = halfSize(object)
		local translation = pos - midpoint(object)

		local newGeom = { }
		for i, p in ipairs(geom) do
			table.insert(newGeom, p + translation)
		end
		object:setGeom(newGeom)
	else
		object:setLoc(pos)
	end
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

function align(object, alignment, base)
	local mid = midpoint(object)
	local half = halfSize(object)
	if alignment == "Left" then
		center(object, point.new(base.minx + half.x, mid.y))
	elseif alignment == "Right" then
		center(object, point.new(base.maxx - half.x, mid.y))
	elseif alignment == "Center" then
		center(object, point.new(base.minx + (base.maxx - base.minx) / 2, mid.y))
	elseif alignment == "Top" then
		center(object, point.new(mid.x, base.miny + half.y))
	elseif alignment == "Bottom" then
		center(object, point.new(mid.x, base.maxy - half.y))
	elseif alignment == "Middle" then
		center(object, point.new(mid.x, base.miny + (base.maxy - base.miny) / 2))
	end
end

function main()
	local alignment = table.remove(arg, 1)

	local objects = plugin:getSelectedObjects()

	if #objects < 1 then
		return
	end

	local ext = mergeExtents(objects)

	for k, obj in pairs(objects) do
		align(obj, alignment, ext)
	end
end   

