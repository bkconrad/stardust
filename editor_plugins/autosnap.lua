-- Autosnap
-- Subtract all selected PolyWalls from all selected Zones
-- This work is released into the public domain
--
-- Authored by kaen

local sd = require('stardust')

function getArgsMenu()
	return "AutoSnap", "Automatically snap zones to PolyWalls", "Ctrl+Shift+["
end

function main()

	local walls = sd.keep(plugin:getSelectedObjects(), PolyWall)
	local zones = sd.filter(plugin:getSelectedObjects(), sd.isZone)

	-- Make sure we have valid inputs
	if (#walls == 0) or (#zones == 0) then
		plugin:showMessage("You must select at least one PolyWall and one Zone", false)
		return
	end

	-- Deselect all objects
	sd.each(plugin:getSelectedObjects(), function(x) x:setSelected(false) end)

	-- Get the wall geometries
	local wallGeoms = sd.map(sd.copy(walls), function (x) return x:getGeom() end)

	local totalResults = 0
	sd.each(zones, function(oldZone)
		-- Perform the operation
		local zoneGeom = oldZone:getGeom()
		local results = Geom.clipPolygons(ClipType.Difference, { zoneGeom }, wallGeoms, true)

		-- Create the output zones and select them
		sd.each(results, function(result)
			local newZone = sd.clone(oldZone)
			newZone:setGeom(result)
			bf:addItem(newZone)
			newZone:setSelected(true)
		end)

		totalResults = totalResults + #results

		oldZone:removeFromGame()
	end)

	-- Let the user know how it went
	plugin:showMessage("Created " .. sd.plural(totalResults, "zone"), true)
end

