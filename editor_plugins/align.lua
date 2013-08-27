-- Align
-- This work is released into the public domain
-- Authored by kaen

require('stardust')

function getArgsMenu()
	menu = 	{
		ToggleMenuItem.new("Align on", {"Left", "Center", "Right", "Top", "Middle", "Bottom"})
	}

	return "Align Objects", menu
end

function main()
	local alignment = table.remove(arg, 1)
	local objects = plugin:getSelectedObjects()

	sd.align(objects, alignment)
end   

