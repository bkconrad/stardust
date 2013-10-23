-- Autosnap
-- Subtract all selected PolyWalls from all selected Zones
-- This work is released into the public domain
--
-- Authored by kaen

require("stardust")

function getArgsMenu()
	return "AutoSnap", "Automatically snap zones to PolyWalls", "Ctrl+Shift+["
end

function main()

	local walls = sd.keep(plugin:getSelectedObjects(), PolyWall)
	local zones = sd.filter(plugin:getSelectedObjects(), sd.isZone)

	print(#walls)
	print(#zones)

	-- Make sure we have valid inputs
	if (#walls == 0) or (#zones == 0) then
		plugin:showMessage("You must select at least one PolyWall and one Zone", false)
		return
	end

	-- Create our geometry tables and remove all zones from the game
	local wallGeoms = sd.map(sd.copy(walls), function (x) return x:getGeom() end)
	local zoneGeoms = sd.map(sd.copy(zones), function (x) return x:getGeom() end)
	sd.each(zones, function(x) x:removeFromGame() end)

	-- Perform the operation
	local results = Geom.clipPolygons(ClipType.Difference, zoneGeoms, wallGeoms, true)

	-- Only proceed if the operation succeeded
	if type(results) == "table" then

		-- Deselect all objects
		sd.each(plugin:getSelectedObjects(), function(x) x:setSelected(false) end)

		-- Create the output Zones and select them
		sd.each(results, function(x)
			local zone = Zone.new(x)
			bf:addItem(zone)
			zone:setSelected(true)
		end)

		-- Let the user know how it went
		plugin:showMessage("Created " .. sd.plural(#results, "zone"), true)
	else
		plugin:showMessage("Operation failed", false)
	end
end

