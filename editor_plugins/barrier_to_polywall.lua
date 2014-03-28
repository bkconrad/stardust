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
		local segments = { }

		for i = 1,#geom-1 do
			table.insert(segments, extrudeSegment(geom[i], geom[i+1], width, i == 1, i == #geom-1))
		end

		results = Geom.clipPolygons(ClipType.Union, { }, segments)
		for k,geom in ipairs(results) do
			bf:addItem(PolyWall.new(geom))
		end

	end)
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

function normalize(p)
	local length = point.length(p)
	return point.new(p.x/length, p.y/length)
end