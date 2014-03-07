-- AutoBorder
-- Draw lines around polygons
-- This work is released into the public domain
--
-- Authored by kaen

local sd = require('stardust')

function getArgsMenu()
	return "AutoBorder", "Create LineItems on the edges of polygons", "Ctrl+Shift+B"
end

function createLines(t)
	local line = LineItem.new()

	-- Repeat the first vertex
	table.insert(t.points, t.points[1])

	line:setGeom(t.points)
	line:setSelected(true)
	bf:addItem(line)

	sd.each(t.children, createLines)
end

function main()
	local geoms = sd.map(sd.filter(plugin:getSelectedObjects(), sd.hasPolyGeom), function(x) return x:getGeom() end)

	-- Deselect all objects
	sd.each(plugin:getSelectedObjects(), function(x) x:setSelected(false) end)

	-- Merge polygons to get outlines and holes
	local results = Geom.clipPolygonsAsTree(ClipType.Union, { }, geoms)

	-- Make the lines
	createLines(results)
end