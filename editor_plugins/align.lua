-- Align
-- This work is released into the public domain
-- Authored by kaen

local sd = require('stardust')

function getArgsMenu()
	menu = 	{
		ToggleMenuItem.new("Align on", {"Left", "Center", "Right", "Top", "Middle", "Bottom"})
	}

	return "Align Objects", "Align objects using specified reference point", "Ctrl+Shift+;", menu
end

function main()
	local alignment = table.remove(arg, 1)
	local objects = plugin:getSelectedObjects()

	sd.align(objects, alignment)
end   

