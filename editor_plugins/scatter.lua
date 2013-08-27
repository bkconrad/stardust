-- Scatter
-- This work is released into the public domain
-- Authored by kaen

function getArgsMenu()

	menu = 	{
		CounterMenuItem.new("Max Distance", 128, 1, 0, 0xFFFF, "grid units", "", "Maximum distance to scatter")
	}

	return "Scatter Objects", menu
end

function main()
	local maxDistance = table.remove(arg, 1)

	local objects = plugin:getSelectedObjects()

	for _, obj in pairs(objects) do
		local oldGeom = obj:getGeom()
		local newGeom
		local distance = math.random(0, maxDistance)
		local translation = point.normalize(point.new(math.random(0, 10) - 5, math.random(0, 10) - 5)) * distance

		if type(oldGeom) == "table" then
			newGeom = { }
			for _, p in ipairs(oldGeom) do
				table.insert(newGeom, p + translation)
			end
		else
			newGeom = oldGeom + translation
		end
		obj:setGeom(newGeom)
	end
end   

