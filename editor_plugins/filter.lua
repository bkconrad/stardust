-- Filter Selection
--
-- Reduce selection to objects of a certain type
--
-- This work is released into the public domain
-- Authored by kaen

require('stardust')

function getArgsMenu()

  -- Limit options to types of items currently selected
  local selectedTypes = {}

  for _, obj in pairs(plugin:getSelectedObjects()) do
    for _, typeName in ipairs(sd.VALID_TYPES) do
      if ObjType[typeName] == obj:getClassId() then
        table.insert(selectedTypes, typeName)
      end
    end
  end

  local options = sd.uniqueValues(selectedTypes)
  table.sort(options)

  if #options == 0 then
    table.insert(options, '<No known objects selected>')
  end

	menu = 	{
		ToggleMenuItem.new("Filter by Type:", options, 1, "The desired object type")
	}

	return "Filter Selection", menu
end

function main()
  local objectType = table.remove(arg, 1)

  local objects = plugin:getSelectedObjects()

  for _, obj in pairs(objects) do
    if obj:getClassId() ~= ObjType[objectType] then
      obj:setSelected(false)
    end
  end
end   

