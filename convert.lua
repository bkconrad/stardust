-- Convert Objects
-- Converts selected polygonal objects in to the specified type, keeping the
-- same geometry
--
-- This work is released into the public domain
-- Authored by kaen

function getArgsMenu()

	menu = 	{
		ToggleMenuItem.new("Max Distance", {"WallItem", "PolyWall", "Zone", "LoadoutZone", "GoalZone", "LineItem"}, 1, "Object type to convert to")
	}

	return "Covert Objects", menu
end

-- map of object types to default arguments
OBJECT_MAP = {
}

function main()
	local objectType = table.remove(arg, 1)

	local objects = plugin:getSelectedObjects()

	for _, obj in pairs(objects) do
		local geom = obj:getGeom()
		if type(geom) == "table" then
			local constructor = loadstring("return " .. objectType .. ".new")()
			local newObj = constructor()
			newObj:setGeom(geom)
			plugin:addItem(newObj)
		end
	end
end   

