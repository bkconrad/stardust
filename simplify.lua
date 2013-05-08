-- Polygon simplification
-- Simplify (a.k.a smooth) polygons using midpoint reduction
-- This work is released into the public domain
-- Authored by kaen

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
			result = poly[i - #poly + 1]
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
	for i = start, start+n-1 do
		table.insert(points, getPoint(poly, i))
	end
	return points
end

function simplify(poly)
	if not poly then
		return
	end

	-- true if the polygon's start and end are equal
	local inputClosed = false
	if poly[1] == poly[#poly] then
		inputClosed = true
	end

	local newPoly = { }

	if not inputClosed then
		table.insert(newPoly, poly[1])
	end

	for i = 1, #poly - 1 do
		local points = getPoints(poly, i, 2)
		table.insert(newPoly, midPoint(points[1], points[2]))
	end

	if not inputClosed then
		table.insert(newPoly, poly[#poly])
	end

	-- if the input poly was closed, then close the new poly
	if inputClosed then
		table.insert(newPoly, midPoint(poly[1], poly[2]))
	end

	return newPoly
end

function main()

	local objects = plugin:getSelectedObjects()

	for k, v in pairs(objects) do
		if type(v:getGeom()) == "table" then
			newGeom = simplify(v:getGeom())
			v:setGeom(newGeom)
		end
	end
end   

