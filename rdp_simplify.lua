-- Polygon simplification
-- Simplify (a.k.a smooth) polylines using the Ramer-Douglas-Peucker algorithm
-- This work is released into the public domain
-- Authored by kaen

function midPoint(p1, p2)
	return point.new((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)
end

function getArgsMenu()

	menu = 	{
		TextEntryMenuItem.new("Epsilon: ", "2.0", "2.0", "Maximum variation to allow"),
	}

	return "Simplify", menu
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

-- returns the minimum distance from the line containing the first two elements
-- of `line` to the point `p`
function minimumDistance(line, p)
	local a, n
	-- beginning of the line segment
	a = line[1]
	-- unit vector from 1 to 2
	n = point.normalize(line[2] - line[1])

	return point.length((a - p) - point.dot(a - p, n) * n)
end

function table_slice (values,i1,i2)
	local res = {}
	local n = #values
	-- default values for range
	i1 = i1 or 1
	i2 = i2 or n
	if i2 < 0 then
		i2 = n + i2 + 1
	elseif i2 > n then
		i2 = n
	end
	if i1 < 1 or i1 > n then
		return {}
	end
	local k = 1
	for i = i1,i2 do
		res[k] = values[i]
		k = k + 1
	end
	return res
end

function dump(t)
	for k, v in pairs(t) do
		logprint(v)
	end
end

-- return the indices of the polygon representing the RDP simplification of
-- `poly` using `epsilon`
function rdp_simplify(poly, epsilon)
	logprint('called with: ')
	dump(poly)
	if #poly == 2 then
		logprint('base case: ')
		dump(poly)
		return poly
	end

	local worstDistance = 0
	local worstIndex
	for i = 2,#poly-1 do
		local d = minimumDistance({poly[1], poly[#poly]}, poly[i])
		if d > worstDistance then
			worstDistance = d
			worstIndex = i
		end
	end

	if worstDistance < epsilon then
		logprint('below epsilon')
		dump({poly[1], poly[#poly]})
		return {poly[1], poly[#poly]}
	end

	-- recurse
	logprint('recursing')
	local first, second
	first = rdp_simplify(table_slice(poly, 1, worstIndex), epsilon)
	second = rdp_simplify(table_slice(poly, worstIndex, #poly), epsilon)
	local result = { }
	for i = 1, #first do
		table.insert(result, first[i])
	end
	for i = 2, #second do
		table.insert(result, second[i])
	end
	dump(result)
	return result
end

function main()

	local epsilon = table.remove(arg, 1) + 0
	local objects = plugin:getSelectedObjects()

	for k, v in pairs(objects) do
		if type(v:getGeom()) == "table" then
			local geom = v:getGeom()
			local closed = false
			if geom[1] == geom[#geom] then
				table.remove(geom, #geom)
				closed = true
			end
			newGeom = rdp_simplify(geom, epsilon)
			if closed then
				newGeom[#newGeom] = newGeom[1]
			end

			logprint('geom')
			dump(newGeom)
			v:setGeom(newGeom)
		end
	end
end   

