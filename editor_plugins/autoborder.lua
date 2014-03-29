-- AutoBorder
-- Draw lines around polygons
-- This work is released into the public domain
--
-- Authored by kaen

local sd = require('stardust')

function getArgsMenu()
	return "AutoBorder", "Create LineItems on the edges of polygons", "Ctrl+Shift+B"
end

function createLines(t, skip)
	if not skip then
		local line = LineItem.new()

		-- Repeat the first vertex
		table.insert(t.points, t.points[1])

		line:setGeom(t.points)
		line:setSelected(true)
		bf:addItem(line)
	end

	sd.each(t.children, createLines)
end

function main()
	local geoms = sd.map(sd.filter(plugin:getSelectedObjects(), sd.hasPolyGeom), function(x) return x:getGeom() end)
	if #geoms == 0 then
		plugin:showMessage('Please select at least one polygon', false)
		return
	end

	local ext = sd.mergeExtents(sd.filter(plugin:getSelectedObjects(), sd.hasPolyGeom))

	-- Deselect all objects
	sd.each(plugin:getSelectedObjects(), function(x) x:setSelected(false) end)


	local OUTLINE_PADDING = 50
	local outline = {
		point.new(ext.minx - OUTLINE_PADDING, ext.miny - OUTLINE_PADDING),
		point.new(ext.maxx + OUTLINE_PADDING, ext.miny - OUTLINE_PADDING),
		point.new(ext.maxx + OUTLINE_PADDING, ext.maxy + OUTLINE_PADDING),
		point.new(ext.minx - OUTLINE_PADDING, ext.maxy + OUTLINE_PADDING)
	}

	-- Merge polygons to get outlines and holes
	local results = Geom.clipPolygonsAsTree(ClipType.Xor, { outline }, geoms)

	-- Make the lines
	createLines(results, true)
end