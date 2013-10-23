-- Polygon Boolean Operations
-- Perform polygon boolean operations (a.k.a. clipping) on selected polygons
-- This work is released into the public domain
--
-- Authored by kaen

require("stardust")

function getArgsMenu()

	menu = 	{
		ToggleMenuItem.new("Operation: ",{ "Union", "Intersection", "Xor", "Difference" }, 4, true, "Clipping operation to perform"),
		ToggleMenuItem.new("First Object Is: ",{ "Subject", "Clip" }, 1, true, "Use first selected object as subject or clip"),
		YesNoMenuItem.new("Merge Triangles: ",1, "Merge triangles into convex polygons when holes are created")
	}

	return "Clip Polygons", "Perform polygon boolean operations", "Ctrl+Shift+3", menu
end

function hasPolyGeom(object)
	return type(object.getGeom) == "function" and type(object:getGeom()) == "table"
end

function main()
	local operation      = table.remove(arg, 1)
	local firstIsSubject = table.remove(arg, 1) == "Subject"
	local mergeTriangles = table.remove(arg, 1) == "Yes"
	local objects        = plugin:getSelectedObjects()
	local subjects       = { }
	local clips          = { }
	local firstGeom      = nil

	-- Find first valid polygonal object
	while (firstGeom == nil) and (#objects > 0) do
		local object = table.remove(objects, 1)
		if hasPolyGeom(object) then
			firstGeom = object:getGeom()
			object:removeFromGame()

			if firstIsSubject then
				subjects[1] = firstGeom
			else
				clips[1] = firstGeom
			end
		end
	end

	-- Remove objects without polygon geometry
	sd.filter(objects, hasPolyGeom)

	-- Make sure we have valid inputs
	if (firstGeom == nil) or (#objects < 1) then
		plugin:showMessage("You must select at least two polygon objects", false)
		return
	end

	-- Process the other objects
	for _, object in ipairs(objects) do
		if firstIsSubject then
			table.insert(clips, object:getGeom())
		else
			table.insert(subjects, object:getGeom())
		end
		object:removeFromGame()
	end

	-- Perform the operation
	local result = Geom.clipPolygons(ClipType[operation], subjects, clips, mergeTriangles)

	-- Only proceed if the operation succeeded
	if type(result) == "table" then

		-- Create the output PolyWalls
		for _, poly in ipairs(result) do
			bf:addItem(PolyWall.new(poly))
		end

		plugin:showMessage(#objects + 1 .." polygons processed", true)
	else
		plugin:showMessage("Operation failed", false)
	end
end

