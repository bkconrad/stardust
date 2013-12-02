-- Scatter
-- This work is released into the public domain
-- Authored by kaen

local sd = require('stardust')

function getArgsMenu()

	menu = 	{
		ToggleMenuItem.new("Axis", { "X", "Y" }, 1, "Axis to mirror across"),
	}

	return "AutoMirror", "Mirror selection across axes", "Ctrl+Shift+\\", menu
end

function main()
	local objects = plugin:getSelectedObjects()
	local horizontal = arg[1] == 'X'

	for _, obj in pairs(objects) do
		local new = sd.clone(obj)
		local oldGeom = obj:getGeom()
		local newGeom = Geom.flip(oldGeom, horizontal)

		new:setGeom(newGeom)
		bf:addItem(new)
	end
end   

