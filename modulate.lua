-- Parametric object modulator
-- Modulate objects using math!
-- Adapted from the work of _k, raptor, and watusimoto.
-- Adaptations are released into the public domain
-- Authored by kaen

--
-- If this function exists, it should return a list of menu items that can be used to build an options menu
-- If this function is not implemented, or returns nil, the menu will not be displayed, and main() will be
-- run without args
--
-- For a full list of the menu widgets available, see the Bitfighter wiki on bitfighter.org
--
CONVENIENCE_VARIABLES = {
	"a",
	"b",
	"c",
	"d"
}

CONVENIENCE_DICTIONARY = { }

-- set up a convenient context for entering lua equations into
-- imports all of math's members (and some added constants) to the context for
-- use as "sin(TAU)" etc.
EVALUATE_CONTEXT = { TAU=6.28, PI=3.14}
for key, value in pairs(math) do
	EVALUATE_CONTEXT[key] = math[key]
end

-- evaluates str in terms of t and i
function evaluate(str, t, i)
	EVALUATE_CONTEXT["t"] = t
	EVALUATE_CONTEXT["i"] = i
	f = loadstring('return ' .. str)
	setfenv(f, EVALUATE_CONTEXT)
	return f()
end

function getArgsMenu()

	menu = 	{
		TextEntryMenuItem.new("Equation",   "sin(t*TAU*pow(2,i-1))*a/pow(2,i-1)*(RAND-0.5)", "", 256, "offset tangent to each vertex"),
		CounterMenuItem.new("subdivisions",  32, 1,       1,    0xFFFF, "", "", "Number of points in the generated objects"),
		CounterMenuItem.new("iterations",  1, 1,       1,    0xFF, "", "", "Width of wall if BarrierMaker is selected below"),
		CounterMenuItem.new("power",  20, 1,       1,    0xFF, "", "", "Width of wall if BarrierMaker is selected below"),
	}

	for index, var in ipairs(CONVENIENCE_VARIABLES) do
		table.insert(menu, 
			TextEntryMenuItem.new(var,   "1", "1", 256, "Value of convenience variable " .. var)
		)
	end
	return "Function to Polygon", menu
end

function valueOf(str)
	return loadstring('return ' .. str)()
end

function typeName(classId)
	for k, v in ipairs(ObjType) do
		if v == classId then
			return k
		end
	end
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
	local pa, pb, pc, pd, x, y, a, b, i1, i2, i3

	local points = getPoints(poly, start - 1, 4)

	pa = points[2]
	pb = points[2] + point.normalize(points[2] - points[1]) * point.distanceTo(points[2], points[3]) * power
	pc = points[3] + point.normalize(points[3] - points[4]) * point.distanceTo(points[2], points[3]) * power
	pd = points[3]

	a = 1 - t
	b = t
	x = pa.x*a*a*a + 3*pb.x*a*a*b + 3*pc.x*a*b*b + pd.x*b*b*b
	y = pa.y*a*a*a + 3*pb.y*a*a*b + 3*pc.y*a*b*b + pd.y*b*b*b

	return point.new(x, y)
end

-- returns a 2D vector representing the tangent of the given curve at point t
-- (using a secant between points with small offsets from t)
function findBezierTangent(poly, start, t, power)
	local p1, p2
	local EPSILON = .0001
	p1 = evaluateCubicBezier(poly, start, t - EPSILON, power)
	p2 = evaluateCubicBezier(poly, start, t + EPSILON, power)
	return p2 - p1
end

-- modulates the polyline using the specified equation. t is a value from 0 to
-- 1.0 representing the proportion of the length which has been interpolated.
-- Interpolation is performed so the center of each line segment is congruent
-- to some point on the generated arc
function modulatePolyline(poly, equation, subdivisions, iterations, power)
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

	-- set up per-iteration level random values
	local randoms = { }
	for i = 1, iterations do
		table.insert(randoms, math.random(0, 100) / 100)
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
		local basePoint = evaluateCubicBezier(poly, segment, segment_t, power)
		local tangent = findBezierTangent(poly, segment, segment_t, power)
		local inverseTangent = point.normalize(point.new(tangent.y, -tangent.x))

		local newPoint = basePoint
		for i = 1, iterations do
			EVALUATE_CONTEXT["RAND"] = randoms[i]
			newPoint = newPoint + inverseTangent * evaluate(equation, t, i)
		end

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
	local equation = table.remove(arg, 1)
	local subdivisions = table.remove(arg, 1)
	local iterations = table.remove(arg, 1)
	local power = table.remove(arg, 1) / 100

	-- copy the specified convenience variables into the evaluation context
	for index, var in ipairs(CONVENIENCE_VARIABLES) do
		EVALUATE_CONTEXT[var] = table.remove(arg, 1)
	end

	local gridSize = plugin:getGridSize()

	local objects = plugin:getSelectedObjects()

	for k, v in pairs(objects) do
		newGeom = modulatePolyline(v:getGeom(), equation, subdivisions, iterations, power)
		v:setGeom(newGeom)
	end
end   

