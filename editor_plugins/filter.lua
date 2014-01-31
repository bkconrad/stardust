-- Filter Selection
--
-- Reduce selection to objects of a certain type
--
-- This work is released into the public domain
-- Authored by kaen

local sd = require('stardust')

function getArgsMenu()

  -- Limit options to types of items currently selected
  local selectedTypes = {}

  for _, obj in pairs(plugin:getSelectedObjects()) do
    for _, typeName in ipairs(sd.VALID_TYPES) do
      if ObjType[typeName] == obj:getObjType() then
        table.insert(selectedTypes, typeName)
      end
    end
  end

  local options = sd.uniqueValues(selectedTypes)
  table.sort(options)

  local menu = { }
  if #options > 0 then
    menu[1] = ToggleMenuItem.new("Filter by Type:", options, 1, "The desired object type")
  end
  
  actions = {"Keep", "Deselect"}
  menu[2] = ToggleMenuItem.new("Action:", actions, 1, "The action to perform")

  return "Filter Selection", "Deselect or keep the specified object type", "Ctrl+Shift+F", menu
end

function main()

  local objects = plugin:getSelectedObjects()
  if #objects == 0 then
    plugin:showMessage('No known objects selected', false)
    return
  end

  local objectType = table.remove(arg, 1)
  local action = table.remove(arg, 1)

  if action == "Keep" then
    for _, obj in pairs(objects) do
      if obj:getObjType() ~= ObjType[objectType] then
        obj:setSelected(false)
      end
    end
  elseif action == "Deselect" then
    for _, obj in pairs(objects) do
      if obj:getObjType() == ObjType[objectType] then
        obj:setSelected(false)
      end
    end
  end
end   

