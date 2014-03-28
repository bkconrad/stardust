-- AutoBorder
-- Draw lines around polygons
-- This work is released into the public domain
--
-- Authored by kaen

local sd = require('stardust')

function getArgsMenu()
	return "Polywallify", "Convert Barriers to Polywalls (for real)", "Ctrl+Shift+P"
end

function main()

	-- keep all selected WallItems (barriers), ignore the rest, and for each barrier:
	sd.each(sd.keep(plugin:getSelectedObjects(), WallItem), function(barrier)

		if barrier == nil then
			return
		end

		-- get the barrier's skeleton
		local geom = barrier:getGeom()
		local width = barrier:getWidth() / 2

		-- make a pairs of tables to hold the result. one for each side
		-- we'll fill the right side up front to back, and the left side up from
		-- back to front. when we get to the end of just one pass, we'll be able
		-- to string them end to end for our result.
		local leftResult, rightResult = { }, { }

		-- we'll also need to keep track of the angle of the last segment, for
		-- bisecting the angles below
		local lastAngle = nil

		-- and also keep track of whether the last segment had a cutout on the
		-- left or right side
		local cutLeft, cutRight = false, false

		-- for each segment (note that this is the number of points - 1)
		for i = 1,#geom-1 do

			-- get the points in this segment
			p1, p2 = geom[i], geom[i+1]

			-- find the angle of this segment
			local thisAngle = math.atan2(p2.y - p1.y, p2.x - p1.x)

			-- if there was a segment before this one
			if lastAngle ~= nil then

				-- bisect the angle (cut it in half)
				local halfAngle = angularDistance(thisAngle + math.pi, lastAngle) / 2 + thisAngle
				local normal = point.new(math.cos(halfAngle), math.sin(halfAngle))

				-- extrude the segment's geometry
				local segmentGeom = extrudeSegment(p1, p2, width, i == 1, i == #geom - 1)
				local rightIntersections, rightSegments = findIntersections(p1, p1 - normal * width * width, segmentGeom)
				local leftIntersections, leftSegments = findIntersections(p1, p1 + normal * width * width, segmentGeom)

				-- handle cutouts
				if cutRight == true then
					table.insert(rightResult, segmentGeom[1])
				end

				if cutLeft == true then
					table.insert(leftResult, segmentGeom[4])
				end

				-- if the "head" segment was hit, we'll add the corner points 
				-- to make a v-like cut out for walls with sharp corners
				for k,v in pairs(rightSegments) do
					print(k,v)
				end
				if rightSegments[2] == 2 then
					table.insert(rightResult, segmentGeom[2])
					cutRight = true
				end
				table.insert(rightResult, rightIntersections[1])

				if leftSegments[2] == 2 then
					table.insert(leftResult, segmentGeom[3])
					cutLeft = true
				end
				table.insert(leftResult, leftIntersections[1])

				bf:addItem(LineItem.new(segmentGeom))
				bf:addItem(LineItem.new(p1, p1 + normal * width))
				bf:addItem(LineItem.new(p1, p1 - normal * width))

				-- if #rightIntersections > 0 then
				-- 	for i,p in ipairs(rightIntersections) do
				-- 		print(p)
				-- 		bf:addItem(Mine.new(p))
				-- 	end
				-- end

				-- if #leftIntersections > 0 then
				-- 	for i,p in ipairs(leftIntersections) do
				-- 		print(p)
				-- 		bf:addItem(Mine.new(p))
				-- 	end
				-- end

			end

			-- prepare for next segment
			p1 = p2
			lastAngle = thisAngle
			cutLeft, cutRight = false, false

		end

		sd.append(rightResult, sd.reverse(leftResult))
		bf:addItem(PolyWall.new(unpack(rightResult)))

	end)
end

-- Find the angular distance (between 0 and pi) of theta1 and theta2, in radians
function angularDistance(theta1, theta2)
	return math.fmod(math.fmod(theta2, math.tau) - math.fmod(theta1, math.tau), math.tau)
end

-- Gets the extrusion of the segment in the order { p1r, p2r, p2l, p1l }
function extrudeSegment(p1, p2, width, isFirst, isLast)

	-- a vector point along the segment with length one
	local unit = normalize(p2 - p1)

	-- a unit vector perpendicular to the segment (pointing right)
	local normal = point.new(-unit.y, unit.x)

	-- factors used to account for segments at the start and end of a barrier
	-- not getting padded past the geom's endpoint
	local headFactor, tailFactor = 1.0, 1.0

	if isFirst then
		tailFactor = 0
	end

	if isLast then
		headFactor = 0
	end

	return {
		p1 + width * normal - .5 * width * unit * tailFactor,
		p2 + width * normal + .5 * width * unit * headFactor,
		p2 - width * normal + .5 * width * unit * headFactor,
		p1 - width * normal - .5 * width * unit * tailFactor
	}

end

-- find all intersections between 
function findIntersections(p1, p2, geom)
	local result = { }
	local segments = { }
	for i = 1,#geom do
		local j = i + 1
		if i == #geom then
			j = 1
		end

		local intersectionPoint = intersection(p1, p2, geom[i], geom[j])
		if intersectionPoint ~= nil then
			table.insert(result, intersectionPoint)
			table.insert(segments, i)
		end
	end

	return result, segments
end

function cross(p, q)
	return p.x * q.y - p.y * q.x
end

function intersection(p, p2, q, q2)
	local r = p2 - p
	local s = q2 - q
	local t = cross(q - p, s) / cross(r, s)
	local u = cross(q - p, r) / cross(r, s)

	-- If r × s = 0 and (q − p) × r = 0, then the two lines are collinear. If in
	-- addition, either 0 ≤ (q − p) · r ≤ r · r or 0 ≤ (p − q) · s ≤ s · s, then
	-- the two lines are overlapping.
	if cross(r,s) == 0 then
		if cross(q-p, r) == 0 then
			-- If r × s = 0 and (q − p) × r = 0, but neither 0 ≤ (q − p) · r ≤ r · r
			-- nor 0 ≤ (p − q) · s ≤ s · s, then the two lines are collinear but
			-- disjoint.
			if not ((0 <= point.dot(q-p, r) and point.dot(q-p, r) < point.dot(r, r)) or (0 <= point.dot(p-q, s) and point.dot(p-q, s) < point.dot(s, s)) ) then
				print('collinear')
				return nil
			end
		else
			-- If r × s = 0 and (q − p) × r ≠ 0, then the two lines are parallel and non-intersecting.
			print('parallel')
			return nil
		end
	end

	-- If r × s ≠ 0 and 0 ≤ t ≤ 1 and 0 ≤ u ≤ 1, the two line segments meet at the point p + t r = q + u s.
	if cross(r, s) ~= 0 and 0 <= t and t <= 1 and 0 <= u and u <= 1 then
		return q + u * s
	end

	-- Otherwise, the two line segments are not parallel but do not intersect.
	print('non intersecting')

	return nil
end

function normalize(p)
	local length = point.length(p)
	return point.new(p.x/length, p.y/length)
end