-- AutoMirror
-- This work is released into the public domain
-- Authored by kaen

local sd = require('stardust')

function getArgsMenu()

	local ext = sd.mergeExtents(plugin:getSelectedObjects())
	autoFlipX = ext.minx * ext.maxx >= 0
	autoFlipY = ext.miny * ext.maxy >= 0
	local menu = { }

	if not (autoFlipY or autoFlipX) then
		menu[1] = ToggleMenuItem.new("Axis", { "X", "Y" }, 1, "Axis to mirror across")
	end

	return "AutoMirror", "Mirror selection across axes", "Ctrl+Shift+\\", menu
end

function main()
	local objects = plugin:getSelectedObjects()
	local flipX = arg[1] == 'X' or autoFlipX
	local flipY = arg[1] == 'Y' or autoFlipY

	for _, obj in pairs(objects) do

		if flipX then
			local new = sd.clone(obj)
			new:setGeom(Geom.flip(obj:getGeom(), true))
			bf:addItem(new)
		end

		if flipY then
			local new = sd.clone(obj)
			new:setGeom(Geom.flip(obj:getGeom(), false))
			bf:addItem(new)
		end

		if flipY and flipX then
			local new = sd.clone(obj)
			new:setGeom(Geom.flip(Geom.flip(obj:getGeom(), false), true))
			bf:addItem(new)
		end
	end
end   

