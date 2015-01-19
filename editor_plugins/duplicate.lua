-- Duplicate
-- This work is released into the public domain
-- Authored by kaen

local sd = require('stardust')

function getArgsMenu()

	local menu = { }
	return "Duplice", "Duplicate all selected objects", "Ctrl+D", menu

end

function main()
	local objects = plugin:getSelectedObjects()

	if #objects == 0 then
		plugin:showMessage('Please select at least one object', false)
		return
	end

	for _, obj in pairs(objects) do
    local new = sd.clone(obj)
    bf:addItem(new)
    obj:setSelected(false)
    new:setSelected(true)
	end

  plugin:showMessage('Created ' .. sd.plural(#objects, 'object', 'objects', true), true)
end   

