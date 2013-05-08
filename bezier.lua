-- Bezier curve fitter
-- Adaptations are released into the public domain
-- Authored by kaen

function getArgsMenu()

	menu = 	{
		CounterMenuItem.new("Subdivisions",  32, 1,       1,    0xFFFF, "", "", "Number of points in the generated objects"),
		CounterMenuItem.new("Bezier Power",  20, 1,       1,    0xFF, "", "No Bezier fitting", "Strength of Bezier curve fitting"),
	}
	return "Bezier curve fitter", menu
end

function midPoint(p1, p2)
	return point.new((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)
end

-- returns a point p3 such that (p3 - p2) == (p2 - p1)
function extrude(p1, p2)
	return p2 + p2 - p1
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
			result = poly[#poly + i]
		else
			result = poly[1] - (poly[2] - poly[1])
		end
	elseif i > #poly then
		if closed then
			result = poly[i - #poly]
		else
			result = poly[#poly] - (poly[#poly] - poly[#poly-1])
		end
	else
		result = poly[i]
	end
	logprint(result)
	return result
end

function getPoints(poly, start, n)
	logprint("getting " .. n .. " points starting at " .. start)
	local points = { }
	for i = start, start+n do
		table.insert(points, getPoint(poly, i))
	end
	return points
end

-- returns point evaluating a cubic bezier at time t
function evaluateCubicBezier(poly, start, t, power)
	local pa, pb, pc, pd, x, y, a, b, i1, i2, i3, meana, meanb

	local points = getPoints(poly, start - 1, 4)

	meana = ((points[2] - points[1]) + (points[3] - points[2])) / 2
	meanb = ((points[4] - points[3]) + (points[3] - points[2])) / 2

	pa = points[2]
	pb = points[2] + point.normalize(meana) * point.distanceTo(points[2], points[3]) * power
	pc = points[3] - point.normalize(meanb) * point.distanceTo(points[2], points[3]) * power
	pd = points[3]

	a = 1 - t
	b = t
	x = pa.x*a*a*a + 3*pb.x*a*a*b + 3*pc.x*a*b*b + pd.x*b*b*b
	y = pa.y*a*a*a + 3*pb.y*a*a*b + 3*pc.y*a*b*b + pd.y*b*b*b

	return point.new(x, y)
end

function modulatePolyline(poly, subdivisions, power)
	if not poly then
		return
	end

	-- true if the polygon's start and end are equal
	local inputClosed = false
	if poly[1] == poly[#poly] then
		inputClosed = true
	end

	local newPoly = {}
	local totalLength = 0
	for k, v in ipairs(poly) do
		if k > 1 then
			totalLength = totalLength + point.length(poly[k] - poly[k-1])
		end
	end

	local t = 0.0
	while t < 1.0 do

		-- find the segment in which t lies
		local segment, segmentStart, segmentEnd
		local traversedLength = 0
		for k = 2, #poly do
			segmentStart = traversedLength / totalLength
			traversedLength = traversedLength + point.length(poly[k] - poly[k - 1])
			segmentEnd = traversedLength / totalLength
			if (traversedLength / totalLength) >= t then
				segment = k - 1
				break
			end
		end

		local segment_t = (t - segmentStart) / (segmentEnd - segmentStart)
		local newPoint = evaluateCubicBezier(poly, segment, segment_t, power)
		table.insert(newPoly, newPoint)

		t = t + (1.0/subdivisions)
	end

	-- if the input poly is closed, close the output poly
	if poly[1] == poly[#poly] then
		table.insert(newPoly, newPoly[1])
	end

	return newPoly
end

function main()
	-- arg table will include values from menu items above, in order

	local gridsize = plugin:getGridSize()

	local scriptName = arg[0]
	local subdivisions = table.remove(arg, 1)
	local power = table.remove(arg, 1) / 100

	local objects = plugin:getSelectedObjects()

	for k, v in pairs(objects) do
		newGeom = modulatePolyline(v:getGeom(), subdivisions, power)
		v:setGeom(newGeom)
	end
end   

