-- Distribute
-- This work is released into the public domain
-- Authored by kaen

function getArgsMenu()
	menu = 	{
		ToggleMenuItem.new("Distribution Axis", {"x", "y"}, 1, "Axis to distribute over")
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

-- distribute objects across the specified axis (either "x" or "y")
function distribute(objects, axis)
	local ext = mergeExtents(objects)
	local hstep = (ext.maxx - ext.minx) / #objects
	local vstep = (ext.maxy - ext.miny) / #objects

	local midpointsTable = { }
	for _, obj in ipairs(objects) do
		local mid = midpoint(obj)
		table.insert(midpointsTable, { x = mid.x, y = mid.y, obj = obj })
	end

	local sortedTable = sortTableListByProperty(midpointsTable, axis)

	for i, obj in pairs(sortedTable) do
		local mid = midpoint(obj.obj)
		if axis == "x" then
			center(obj.obj, point.new(ext.minx + (i - 1) * hstep, mid.y))
		else
			center(obj.obj, point.new(mid.x, ext.miny + (i - 1) * vstep))
		end
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

