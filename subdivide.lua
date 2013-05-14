-- Polygon subdivision
-- Subdivide (a.k.a round) polygons using multi-pass fixed midpoint vertex
-- insertion and gaussian first-order vertex smoothing
-- This work is released into the public domain
-- Authored by kaen

function getArgsMenu()

	menu = 	{
		CounterMenuItem.new("Size Threshold: ",  32, 1,       1,    0xFFFF, "", "", "max distance between points"),
		CounterMenuItem.new("Smoothing: ",  0, 1,       0,    100, "%", "No Smoothing", "Amount of smoothing to perform"),
		YesNoMenuItem.new("Subdivide Completely? ",  2, "Divide until all segments are below size threshold"),
	}

	return "Subdivide", menu
end

function midPoint(p1, p2)
	return point.new((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)
end

-- return point i from poly, handling bounds crossing appropriately depending
-- on whether the polygon is closed or not
function getPoint(poly, i)
	local result
	local closed = false

	if poly[1] == poly[#poly] then
		closed = true
	end

	if i < 1 then
		if closed then
			result = poly[#poly + i - 1]
		else
			result = poly[1]
		end
	elseif i > #poly then
		if closed then
			result = poly[i - #poly + 1]
		else
			result = poly[#poly]
		end
	else
		result = poly[i]
	end
	return result
end

function getPoints(poly, start, n)
	local points = { }
	for i = start, start+n-1 do
		table.insert(points, getPoint(poly, i))
	end
	return points
end

-- returns a point equal to the average of the supplied points
function average(points)
	local sum = point.new(0,0)
	for i, v in ipairs(points) do
		sum = sum + v
	end
	return sum / #points
end

-- Returns a polyline which is a subdivision of the edges of the given poly
-- using the following algorithm:
-- 	- For each segment of the poly line:
--		- Output a vertex equal to the weighted average of the first
--		  vertex of this segment with the two adjacent midpoints
--		  controlled by `smoothing`
--		- If this segment's old length was greater than maxDistance:
--			- Output a vertex at the old midpoint of the segment
--	- If do_completely is true, and any subdivisions occured this pass:
--		- Set the output geometry as input geometry and repeat
function subdividePolyline(poly, maxDistance, smoothing, do_completely)
	if not poly then
		return
	end

	-- true if the polygon's start and end are equal
	local inputClosed = false
	if poly[1] == poly[#poly] then
		inputClosed = true
	end

	local done = false
	local newPoly
	while not done do
		newPoly = { }
		done = true
		for i = 1, #poly do
			-- output the weighted average of the current point and
			-- the two adjacent midpoints
			local points = getPoints(poly, i - 1, 3)
			if not (inputClosed and i == 0) then
				local smoothedPoint = average({midPoint(points[1],points[2]),points[2],midPoint(points[2],points[3])}) * smoothing + points[2] * (1 - smoothing)
				table.insert(newPoly, smoothedPoint)
			end

			-- split this segment if needed
			if (i ~= #poly) and point.distanceTo(points[2], points[3]) > maxDistance then
				logprint("subdividing points", points[2], points[3])
				logprint("Distance = " .. point.distanceTo(points[2], points[3]))
				table.insert(newPoly, midPoint(points[2], points[3]))
				if do_completely then
					done = false
				end
			end
		end
		poly = newPoly
	end

	return newPoly
end

function main()
	-- arg table will include values from menu items above, in order

	local gridsize = plugin:getGridSize()

	local scriptName = arg[0]
	local maxDistance = table.remove(arg, 1) + 0
	local smoothing = table.remove(arg, 1) / 100
	local completely = table.remove(arg, 1)

	local gridSize = plugin:getGridSize()

	local objects = plugin:getSelectedObjects()

	for k, v in pairs(objects) do
		if type(v:getGeom()) == "table" then
			newGeom = subdividePolyline(v:getGeom(), maxDistance, smoothing, completely == "Yes")
			v:setGeom(newGeom)
		end
	end
end   

