local IMPLICITLY_CLOSED_CLASS_IDS = {
	[ObjType.GoalZone] = true,
	[ObjType.LoadoutZone] = true,
	[ObjType.PolyWall] = true,
	[ObjType.Zone] = true
}

-- adds every element of t2 on to t1:
-- 
-- append({1, 2}, {3, 4})
-- > {1, 2, 3, 4}
local function append(t1, t2)
	for _, v in pairs(t2) do
		table.insert(t1, v)
	end
end

-- return the extents of the given object
local function extents(object)
	local minx = math.huge
	local miny = math.huge
	local maxx = -math.huge
	local maxy = -math.huge
	local geom = object:getGeom()

	if type(geom) == "table" then
		for i, p in ipairs(geom) do
			minx = math.min(minx, p.x)
			miny = math.min(miny, p.y)
			maxx = math.max(maxx, p.x)
			maxy = math.max(maxy, p.y)
		end
	elseif type(geom) == "point" then
	    local r = 0

	    -- Try to get the radius, but don't worry if you can't
	    pcall(function()
	      r = object:getRad()
	    end)

		minx = geom.x - r
		maxx = geom.x + r
		miny = geom.y - r
		maxy = geom.y + r
	end

	return { minx = minx, miny = miny, maxx = maxx, maxy = maxy }
end

local function halfSize(object)
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

local function midPoint(p1, p2)
	return point.new((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)
end

-- returns a point equal to the average of the supplied points
-- accepts any number of arguments as long as they are points
-- or first-order tables of points
local function average(...)
	local points = {}

	for _, v in pairs(...) do
		if type(v) == 'point' then
			table.insert(points, v)
		elseif type(v) == 'table' then
			append(points, v)
		end
	end

	local sum = point.new(0,0)
	for i, v in ipairs(points) do
		sum = sum + v
	end
	return sum / #points
end

-- returns true if the object has polygon geometry i.e. it is
-- always rendered as a closed polygon (Zones and polywalls)
local function implicitlyClosed(obj)
	return not not IMPLICITLY_CLOSED_CLASS_IDS[obj:getClassId()]
end

-- get the object's center point
local function center(obj)
	local ext = extents(obj)
	return point.new(ext.minx + (ext.maxx - ext.minx) / 2, ext.miny + (ext.maxy - ext.miny) / 2)
end

-- set the object's center point
local function centerOn(object, pos)
	local geom = object:getGeom()
	if type(geom) == "table" then
		local half = halfSize(object)
		local translation = pos - center(object)

		local newGeom = { }
		for i, p in ipairs(geom) do
			table.insert(newGeom, p + translation)
		end
		object:setGeom(newGeom)
	else
		object:setLoc(pos)
	end
end

local function mergeExtents(objects)
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

local function align(objects, alignment)
	local ext = mergeExtents(objects)
	for k, obj in pairs(objects) do
		local c = center(obj)
		local h = halfSize(obj)
		if alignment == "Left" then
			centerOn(obj, point.new(ext.minx + h.x, c.y))
		elseif alignment == "Right" then
			centerOn(obj, point.new(ext.maxx - h.x, c.y))
		elseif alignment == "c" then
			centerOn(obj, point.new(ext.minx + (ext.maxx - ext.minx) / 2, c.y))
		elseif alignment == "Top" then
			centerOn(obj, point.new(c.x, ext.miny + h.y))
		elseif alignment == "Bottom" then
			centerOn(obj, point.new(c.x, ext.maxy - h.y))
		elseif alignment == "Middle" then
			centerOn(obj, point.new(c.x, ext.miny + (ext.maxy - ext.miny) / 2))
		else
			print('Unknown alignment ' .. alignment)
		end
	end
end

-- returns point evaluating a cubic bezier at time t
local function evaluateCubicBezier(points, t, power)
  local meana = ((points[2] - points[1]) + (points[3] - points[2])) / 2
  local meanb = ((points[4] - points[3]) + (points[3] - points[2])) / 2

  local pa = points[2]
  local pb = points[2] + point.normalize(meana) * point.distanceTo(points[2], points[3]) * power
  local pc = points[3] - point.normalize(meanb) * point.distanceTo(points[2], points[3]) * power
  local pd = points[3]

  local a = 1 - t
  local b = t
  local x = pa.x*a*a*a + 3*pb.x*a*a*b + 3*pc.x*a*b*b + pd.x*b*b*b
  local y = pa.y*a*a*a + 3*pb.y*a*a*b + 3*pc.y*a*b*b + pd.y*b*b*b

  return point.new(x, y)
end

-- return point i from poly, handling bounds crossing appropriately depending
-- on whether the polygon is closed or not
local function getPoint(poly, i)
  local result
  local closed = false

  if poly[1] == poly[#poly] then
    closed = true
  end

  if i < 1 then
    if closed then
      result = poly[#poly + i - 1]
    else
      result = poly[#poly + i]
    end
  elseif i > #poly then
    if closed then
      result = poly[i - #poly + 1]
    else
      result = poly[i - #poly]
    end
  else
    result = poly[i]
  end
  return result
end

local function getPoints(poly, start, n)
  local points = { }
  for i = start, start+n do
    table.insert(points, getPoint(poly, i))
  end
  return points
end

local function lengthOf(poly)
  local result = 0
  for k, v in ipairs(poly) do
    if k > 1 then
      result = result + point.length(poly[k] - poly[k-1])
    end
  end
  return result
end

-- Find the segment of `poly` at distance `d` along the polyline
--
-- Traverses `poly` until it gets to the segment which contains the 
-- point at distance `d` along the line, then returns the one-based
-- index of the segment. `d` is a number between 0.0 and 1.0 inclusive
--
-- returns segment, segmentStart, segmentEnd
-- where segment is the index, and segmentStart/End are the distance along
-- the line where this segment starts and ends
local function segmentAt(poly, d)
	local totalLength = lengthOf(poly)
    local segment, segmentStart, segmentEnd
    local traversedLength = 0
    for k = 2, #poly do
      segmentStart = traversedLength / totalLength
      traversedLength = traversedLength + point.length(poly[k] - poly[k - 1])
      segmentEnd = traversedLength / totalLength
      if (traversedLength / totalLength) >= d then
        segment = k - 1
        break
      end
    end

    return segment, segmentStart, segmentEnd
end

local stardust = {
	align = align,
	append = append,
	average = average,
	center = center,
	centerOn = centerOn,
	extents = extents,
	evaluateCubicBezier = evaluateCubicBezier,
	getPoint = getPoint,
	getPoints = getPoints,
	halfSize = halfSize,
	implicitlyClosed = implicitlyClosed,
	lengthOf = lengthOf,
	mergeExtents = mergeExtents,
	midPoint = midPoint,
	segmentAt = segmentAt,
}

_G["sd"] = stardust