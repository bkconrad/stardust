-- Parametric object modulator
-- Modulate objects using math!
-- Adapted from the work of _k, raptor, and watusimoto.
-- Adaptations are released into the public domain
-- Authored by kaen

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
		TextEntryMenuItem.new("Equation",   "sin(t*TAU*pow(2,i-1))*a/pow(2,i-1)*(RAND-0.5)", "", 256, "Offset perpendicular to each vertex as a function of t"),
		CounterMenuItem.new("Iterations",  1, 1,       1,    0xFF, "", "", "Additive iterations of the specified function"),
	}

	for index, var in ipairs(CONVENIENCE_VARIABLES) do
		table.insert(menu, 
			TextEntryMenuItem.new(var,   "1", "1", 256, "Value of convenience variable " .. var)
		)
	end
	return "Modulate Polygon", menu
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
	return result
end

function getPoints(poly, start, n)
	local points = { }
	for i = start, start+n do
		table.insert(points, getPoint(poly, i))
	end
	return points
end


function modulatePolyline(poly, equation, iterations)
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

	for i, p in ipairs(poly) do
		-- find the segment in which t lies
		local segment, segmentStart, segmentEnd
		local traversedLength = 0
		for k = 2, #poly do
			traversedLength = traversedLength + point.length(poly[k] - poly[k - 1])
			if k == i then
				break
			end
		end
		t = traversedLength / totalLength

		local tangent = findSlope(poly, i)
		local inverseTangent = point.normalize(point.new(tangent.y, -tangent.x))

		local newPoint = p
		for i = 1, iterations do
			EVALUATE_CONTEXT["RAND"] = randoms[i]
			newPoint = newPoint + inverseTangent * evaluate(equation, t, i)
		end

		table.insert(newPoly, newPoint)
	end

	-- if the input poly is closed, close the output poly
	if poly[1] == poly[#poly] then
		table.insert(newPoly, newPoly[1])
	end

	return newPoly
end

-- returns the average slope for vertex i
function findSlope(poly, i)
	local points = getPoints(poly, i - 1, 3)
	return ((points[2] - points[1]) + (points[3] - points[2])) / 2
end

function main()
	-- arg table will include values from menu items above, in order

	local gridsize = plugin:getGridSize()

	local scriptName = arg[0]
	local equation = table.remove(arg, 1)
	local iterations = table.remove(arg, 1)

	-- copy the specified convenience variables into the evaluation context
	for index, var in ipairs(CONVENIENCE_VARIABLES) do
		EVALUATE_CONTEXT[var] = table.remove(arg, 1)
	end

	local gridSize = plugin:getGridSize()

	local objects = plugin:getSelectedObjects()

	for k, v in pairs(objects) do
		newGeom = modulatePolyline(v:getGeom(), equation, iterations)
		v:setGeom(newGeom)
	end
end   

